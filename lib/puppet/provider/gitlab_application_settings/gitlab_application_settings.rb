# frozen_string_literal: true

require 'puppet/resource_api'
require_relative '../../../puppet_x/voxpupuli/gitlab/api_helper'

# Implementation for the gitlab_settings type using the Resource API.
class Puppet::Provider::GitlabApplicationSettings::GitlabApplicationSettings
  def initialize
    super
    @known_settings = JSON.load_file(File.join(__dir__, 'attributes.json'), symbolize_names: true)
    @api_helper = PuppetX::Gitlab::ApiHelper.new
  end

  def get(context)
    current_settings = @api_helper.get_json('/application/settings').transform_keys(&:to_sym)

    unknown_settings = current_settings.keys - @known_settings.keys - [:id]
    context.debug("Unknown settings: #{unknown_settings.to_json}") unless unknown_settings.empty?

    final_settings = current_settings.filter { |x| @known_settings.include?(x) }

    [
      { name: 'gitlab' }.merge(final_settings)
    ]
  end

  def set(context, changes, noop: false)
    changes.each do |name, change|
      should = change[:should]
      context.debug("changes to apply: #{should}")
      data = should.reject { |k, _v| k == :name }

      context.updating(name) do
        @api_helper.put_json('/application/settings', data) unless noop
      end
    end

    nil
  end
end
