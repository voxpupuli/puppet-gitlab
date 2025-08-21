# frozen_string_literal: true

require 'spec_helper'

module Puppet::Provider::GitlabApplicationSettings; end
require 'puppet/provider/gitlab_application_settings/gitlab_application_settings'

describe Puppet::Provider::GitlabApplicationSettings::GitlabApplicationSettings do
  subject(:provider) { described_class.new }

  let(:api_helper) { instance_double(PuppetX::Gitlab::ApiHelper) }
  let(:context) do
    c = instance_double(Puppet::ResourceApi::BaseContext, 'context')
    allow(c).to receive(:debug)

    # Call the original block in the provider `set()` implementation
    allow(c).to receive(:updating) do |name, &block|
      block.call(name)
    end

    c
  end

  before do
    allow(PuppetX::Gitlab::ApiHelper).to receive(:new).and_return(api_helper)
  end

  describe '#initialize' do
    it { expect { provider }.not_to raise_error }
  end

  describe '#get' do
    it do
      allow(api_helper).to receive(:get_json).with('/application/settings').and_return({ signup_enabled: true })
      result = provider.get(context)
      expect(result).to eq([{ name: 'gitlab', signup_enabled: true }])
    end
  end

  describe '#set' do
    it do
      allow(api_helper).to receive(:put_json).with('/application/settings', { signup_enabled: false }).and_return({})
      result = provider.set(
        context,
        {
          'gitlab' => {
            should: {
              name: 'gitlab',
              signup_enabled: false,
            }
          }
        }
      )
      expect(result).to be_nil
    end
  end
end
