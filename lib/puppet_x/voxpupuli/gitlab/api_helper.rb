# frozen_string_literal: true

require 'puppet_x'
require 'json'

module PuppetX::Gitlab
  class ApiHelper
    DEFAULT_CONFIG_FILE = '/etc/puppetlabs/gitlab_provider.json'

    def initialize
      creds = read_credentials
      @api_url = creds[:base_url]
      @token = creds[:token]
      @headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@token}",
      }
      @options = {
        include_system_store: true,
      }

      @http_client = Puppet.runtime[:http]
    end

    def read_credentials
      config_file = ENV.fetch('GITLAB_PROVIDER_CONFIG_PATH', nil)
      api_url = ENV.fetch('GITLAB_BASE_URL', nil)
      api_token = ENV.fetch('GITLAB_TOKEN', nil)

      if !config_file && api_url && api_token
        {
          base_url: api_url,
          token: api_token,
        }
      else
        JSON.load_file(config_file || DEFAULT_CONFIG_FILE, symbolize_names: true)
      end
    end

    # Generate useful methods
    %i[
      delete
      get
      head
    ].each do |method|
      define_method(method) do |endpoint, headers: {}, params: {}, options: {}|
        request(method, endpoint, headers: headers, params: params, options: options)
      end
      define_method("#{method}_json".to_sym) do |endpoint, headers: {}, params: {}, options: {}|
        request_json(method, endpoint, headers: headers, params: params, options: options)
      end
    end

    %i[
      post
      put
    ].each do |method|
      define_method(method) do |endpoint, body, headers: {}, params: {}, options: {}|
        request(method, endpoint, body: body, headers: headers, params: params, options: options)
      end
      define_method("#{method}_json".to_sym) do |endpoint, body, headers: {}, params: {}, options: {}|
        request_json(method, endpoint, body: body, headers: headers, params: params, options: options)
      end
    end

    def request(method, endpoint, body: nil, headers: {}, params: {}, options: {})
      mtd = method.downcase
      args = [mtd, URI("#{@api_url}#{endpoint}")]
      args << body if %i[post put].include?(mtd) # POST & PUT methods has 'body' positional argument

      resp = @http_client.send(*args, headers: @headers.merge(headers), params: params, options: @options.merge(options))
      raise Puppet::ResourceError, 'Unable to query Gitlab API' unless resp.success?

      resp.body
    end

    def request_json(method, endpoint, body: {}, headers: {}, params: {}, options: {})
      symbolize_names = options.delete(:symbolize_names) || false
      json_body = body&.to_json
      resp_body = request(method, endpoint, body: json_body, headers: headers, params: params, options: options)
      JSON.parse(resp_body, symbolize_names: symbolize_names)
    rescue JSON::ParserError
      raise Puppet::ResourceError, 'Unable to parse JSON response from Gitlab API'
    end
  end
end
