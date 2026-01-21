# frozen_string_literal: true

# How to update type & provider?
#
# Do the following:
# ```bash
# bundle exec rake gitlab:application_settings:fetch_from_docs
# bundle exec rake gitlab:application_settings:generate
# ```
#
# If you want to check how big is the difference between documented settings
# and real settings from a Gitlab instance, there is something for you also.
# The command below uses docker CLI to run Gitlab container. Exact image may be
# specified as the rake task argument.
# ```bash
# bundle exec rake gitlab:application_settings:fetch_from_docker
# bundle exec rake gitlab:application_settings:compare
# ```
#
# To cleanup all those json leftovers run this task
# ```bash
# bundle exec rake gitlab:application_settings:compare
# ```

require 'erb'
require 'json'
require 'yaml'
require 'uri'

namespace :gitlab do
  namespace :application_settings do
    desc 'Cleanup'
    task :cleanup do
      files = [
        'application_settings_parsed.json',
        'application_settings_attrs.json',
        'application_settings_real.json',
      ].map { |filename| File.join(__dir__, filename) }
      warn "Deleting files: #{files}..."
      FileUtils.rm(files, force: true)
    end

    desc 'Fetch the API document and parse it to a json file'
    task :fetch_from_docs do
      parsed_settings_file = File.join(__dir__, 'application_settings_parsed.json').freeze

      if File.exist?(parsed_settings_file)
        warn "Not fetching as file #{parsed_settings_file} is present..."
        next
      end

      warn 'Fetching and parsing Application settings API docs...'
      content = URI.open('https://gitlab.com/gitlab-org/gitlab/-/raw/master/doc/api/settings.md').read
      lines = content.lines

      # Find start of the '## Available settings section'
      start_index = lines.find_index { |line| line.start_with?('## Available settings') }
      return '{}' unless start_index

      # Find the start of the table
      table_start_index = lines[start_index..].find_index { |line| line =~ %r{^\|.*\|$} }
      return '{}' unless table_start_index

      table_start_index += start_index

      # Collect all lines that belong to the table
      table_lines = []
      i = table_start_index
      while i < lines.size && !(lines[i].strip.empty? || lines[i].start_with?('#'))
        current_line = lines[i]
        i += 1

        next if current_line.start_with?('|-') # Skip delimiter line
        next unless current_line.start_with?('| ')

        table_lines << current_line
      end

      # Parse headers
      headers = table_lines[0].split('|').map(&:strip)[1..-2]
      raise "Expected 4 columns in table, but found: #{headers.size}" unless headers.size == 4

      # Parse rows
      rows = table_lines[1..].map do |line|
        line.split('|').map(&:strip)[1..-2]
      end

      # Build the hash
      settings_hash = rows.each_with_object({}) do |row, hash|
        name = row[0].gsub('`', '').strip
        type = row[1].gsub(%r{<[^>]+>}, '').strip
        required = row[2].gsub(%r{<[^>]+>}, '').strip
        description = row[3].gsub(%r{<[^>]+>}, '').
                      gsub(%r{\[([^\]]+)\]\([^)]+\)}, '\1').
                      gsub(%r{\*\*}, '').
                      strip

        hash[name] = {
          type: type,
          required: required,
          description: description,
        }
      end
      json_text = JSON.pretty_generate(settings_hash)
      File.write(parsed_settings_file, json_text)
    end

    desc 'Run Gitlab in Docker and fetch settings from it'
    task :fetch_from_docker, [:image] do |_task, args|
      real_settings_file = File.join(__dir__, 'application_settings_real.json').freeze

      if File.exist?(real_settings_file)
        warn "Not fetching as file #{real_settings_file} is present..."
        next
      end

      require 'open3'
      require 'securerandom'

      image = args[:image] || 'docker.io/gitlab/gitlab-ce:latest'
      host_port = '127.0.0.1:51280'

      begin
        warn 'Starting the Gitlab container...'
        cmd = %w[docker run --rm --detach --name gitlab --publish] << "#{host_port}:80" << image
        _, err, status = Open3.capture3(*cmd)
        raise "Failed to create the Gitlab container: #{err}" unless status.success?

        $stderr.printf 'Waiting for Gitlab to become healthy...'
        inspect_cmd = %w[docker container inspect gitlab]
        loop do
          sleep 15
          out, err, status = Open3.capture3(*inspect_cmd)
          raise "Failed to inspect the Gitlab container: #{err}" unless status.success?

          data = JSON.parse(out)
          break if data[0]['State']['Health']['Status'] == 'healthy'

          $stderr.printf '.'
        end
        $stderr.puts

        warn 'Creating a token...'
        my_token = SecureRandom.alphanumeric(32)
        gitlab_rails_cmd = <<~RAILS
          root = User.find(1);
          token = root.personal_access_tokens.create(scopes: [:api], name: "Automation", expires_at: Date.today + 1);
          token.set_token('#{my_token}');
          token.save!
        RAILS

        cmd = %w[docker exec gitlab gitlab-rails runner] << gitlab_rails_cmd
        _, err, status = Open3.capture3(*cmd)
        raise "Failed to create the token: #{err}" unless status.success?

        warn 'Querying settings...'
        settings_text = Net::HTTP.get(
          URI("http://#{host_port}/api/v4/application/settings"),
          {
            'Authorization' => "Bearer #{my_token}",
            'Content-Type'  => 'application/json',
          }
        )
        settings = JSON.parse(settings_text)
        File.write(real_settings_file, settings)
      ensure
        # Ensure container is stopped
        warn 'Stopping the Gitlab container...'
        cmd = %w[docker stop gitlab]
        _, err, status = Open3.capture3(*cmd)
        raise "Failed to stop the Gitlab container: #{err}" unless status.success?
      end
    end

    desc 'Compare parsed and real setting names'
    task compare: %i[fetch_from_docs fetch_from_docker] do
      parsed = JSON.parse(File.read(File.join(__dir__, 'application_settings_parsed.json')), symbolize_names: true)
      real = JSON.parse(File.read(File.join(__dir__, 'application_settings_real.json')), symbolize_names: true)

      parsed_keys = parsed.keys.sort
      real_keys = real.keys.sort

      warn '=== Settings present in real, but absent in parsed'
      puts real_keys - parsed_keys - [:id]
    end

    desc 'Generate gitlab_application_settings type & provider'
    task generate: %i[generate:type generate:provider]

    namespace :generate do
      desc 'Generate attributes JSON file to be used with the type & provider'
      task :attributes do
        warn 'Generating attributes from the Application settings API docs...'

        # Map a type from the available settings table to the matching Puppet type
        # To be adjusted with gitlab_settings_modifiers.yaml data
        types_map = {
          'string' => 'Optional[String]',
          'text' => 'Optional[String]',
          'integer' => 'Optional[Integer[0]]',
          'boolean' => 'Optional[Boolean]',
          'float' => 'Optional[Float]',
          'object' => 'Optional[Hash]',
          'hash' => 'Optional[Hash]',
          'array of strings' => 'Optional[Array[String[1]]]',
          'string or array of strings' => 'Optional[Variant[String[1], Array[String[1]]]]',
          'array of integers' => 'Optional[Array[Integer[0]]]',
          'hash of strings to integers' => 'Optional[Hash[String[1], Integer[0]]]',
        }.freeze

        settings_modifiers = YAML.safe_load(File.read(File.join(__dir__, 'application_settings_modifiers.yaml')), symbolize_names: true)
        original_settings = JSON.parse(File.read(File.join(__dir__, 'application_settings_parsed.json')), symbolize_names: true)
        # Delete unusable attributes first
        settings_hash = original_settings.except(settings_modifiers.fetch(:delete, []))

        # Convert settings data to attributes
        attributes_hash = {}
        settings_hash.each do |key, v|
          type = if key.end_with?('_url')
                   'Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]'
                 elsif key.end_with?('_hostname')
                   "Optional[Variant[Stdlib::FQDN, Enum['']]]"
                 elsif key.end_with?('_enabled')
                   'Optional[Boolean]'
                 else
                   types_map.fetch(v[:type], v[:type])
                 end
          required_maybe = v[:required] == 'no' ? '' : " #{v[:required].capitalize}"

          attributes_hash[key] = {
            type: type,
            desc: "#{v[:description]}#{required_maybe}"
          }
        end

        result_hash = attributes_hash.deep_merge(settings_modifiers.fetch(:merge, {}))

        json_text = JSON.pretty_generate(result_hash.sort.to_h)
        File.write(File.join(__dir__, 'application_settings_attrs.json'), json_text)
      end

      desc 'Generate the gitlab_application_settings type'
      task type: :attributes do
        warn 'Generating gitlab_application_settings type...'
        attributes = JSON.parse(File.read(File.join(__dir__, 'application_settings_attrs.json')), symbolize_names: true)

        type_erb = ERB.new(File.read(File.join([__dir__] + %w[.. templates gitlab_application_settings_type.erb])), trim_mode: '-')
        type_erb_content = type_erb.result_with_hash(attributes: attributes)
        File.write(File.join([__dir__] + %w[.. lib puppet type gitlab_application_settings.rb]), type_erb_content)
      end

      desc 'Generate the gitlab_application_settings provider'
      task provider: :attributes do
        warn 'Generating gitlab_application_settings provider...'
        attributes = JSON.parse(File.read(File.join(__dir__, 'application_settings_attrs.json')), symbolize_names: true)

        provider_data = attributes.transform_values! { |x| x.except(:type, :desc) }

        File.write(File.join([__dir__] + %w[.. lib puppet provider gitlab_application_settings attributes.json]), JSON.pretty_generate(provider_data))
      end
    end
  end
end
