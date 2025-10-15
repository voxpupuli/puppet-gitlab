# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../../lib/puppet_x/voxpupuli/gitlab/api_helper'

describe PuppetX::Gitlab::ApiHelper do
  let(:api_helper) { described_class.new }
  let(:puppet_http_client) { instance_double(Puppet::HTTP::Client) }
  let(:api_url) { 'http://gitlab.example.com/api/v4' }
  let(:token) { 'abcdefghijklmnopqrstuvwxyz0123456789' }
  let(:headers) do
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json',
    }
  end
  let(:options) { { include_system_store: true } }
  let(:params) { {} }
  let(:response_body) { '{"example_response": true}' }
  let(:endpoint) { '/test' }
  let(:url) { "#{api_url}#{endpoint}" }
  let(:response) do
    ok = Net::HTTPOK.new(url, 200, 'OK')
    allow(ok).to receive(:body).and_return(response_body)
    Puppet::HTTP::ResponseNetHTTP.new(url, ok)
  end

  before do
    allow(Puppet::HTTP::Client).to receive(:new).and_return(puppet_http_client)
    allow(ENV).to receive(:fetch).with('GITLAB_PROVIDER_CONFIG_PATH', nil).and_return(nil)
    allow(ENV).to receive(:fetch).with('GITLAB_BASE_URL', nil).and_return(api_url)
    allow(ENV).to receive(:fetch).with('GITLAB_TOKEN', nil).and_return(token)
  end

  describe '#initialize' do
    it { expect { api_helper }.not_to raise_error }
  end

  describe '#request' do
    let(:headers) { super().merge('Example-Header' => true) }
    let(:options) { super().merge(example_option: true) }
    let(:params) { super().merge('example_parameter' => true) }

    shared_examples 'gitlab api client' do |use_cfg_from: :env|
      it 'returns response body text' do
        request_body = "example\nstring\n"
        json_config = "{\"base_url\": \"#{api_url}\", \"token\": \"#{token}\"}"

        case use_cfg_from
        when :env
          # Nothing to do, already set by before hook above
        when :default_file
          allow(ENV).to receive(:fetch).with('GITLAB_PROVIDER_CONFIG_PATH', nil).and_return('/etc/puppetlabs/gitlab_provider.json')
          allow(ENV).to receive(:fetch).with('GITLAB_BASE_URL', nil).and_return(nil)
          allow(ENV).to receive(:fetch).with('GITLAB_TOKEN', nil).and_return(nil)
          allow(File).to receive(:read).with('/etc/puppetlabs/gitlab_provider.json', any_args).and_return(json_config)
        else
          allow(ENV).to receive(:fetch).with('GITLAB_PROVIDER_CONFIG_PATH', nil).and_return(use_cfg_from)
          allow(ENV).to receive(:fetch).with('GITLAB_BASE_URL', nil).and_return(nil)
          allow(ENV).to receive(:fetch).with('GITLAB_TOKEN', nil).and_return(nil)
          allow(File).to receive(:read).with(use_cfg_from, any_args).and_return(json_config)
        end

        allow(puppet_http_client).to receive(:post).
          with(URI(url), request_body, headers: headers, options: options, params: params).and_return(response)

        resp = api_helper.request(:POST, endpoint, body: request_body, headers: headers, params: params, options: options)
        expect(resp).to eq(response_body)
        expect(puppet_http_client).to have_received(:post).once
      end
    end

    it_behaves_like 'gitlab api client'

    context 'with default config file' do
      it_behaves_like 'gitlab api client', use_cfg_from: :default_file
    end

    context 'with custom config file' do
      it_behaves_like 'gitlab api client', use_cfg_from: '/etc/gitlab.json'
    end
  end

  describe '#request_json' do
    let(:headers) { super().merge('Example-Header' => true) }
    let(:options) { super().merge(example_option: true) }
    let(:params) { super().merge('example_parameter' => true) }

    context 'without symbolize_names option' do
      it 'returns Ruby hash' do
        request_body = { example_body: true }

        allow(puppet_http_client).to receive(:post).
          with(URI(url), request_body.to_json, headers: headers, options: options, params: params).and_return(response)

        resp = api_helper.request_json(:POST, endpoint, body: request_body, headers: headers, params: params, options: options)
        expect(resp).to eq(JSON.parse(response_body))
        expect(puppet_http_client).to have_received(:post).once
      end
    end

    context 'with symbolize_names option' do
      it 'returns Ruby hash' do
        request_body = { example_body: true }

        allow(puppet_http_client).to receive(:post).
          with(URI(url), request_body.to_json, headers: headers, options: options, params: params).and_return(response)

        resp = api_helper.request_json(:POST, endpoint, body: request_body, headers: headers, params: params, options: options.merge(symbolize_names: true))
        expect(resp).to eq(JSON.parse(response_body, symbolize_names: true))
        expect(puppet_http_client).to have_received(:post).once
      end
    end
  end

  shared_examples 'a Puppet::HTTP::Client' do |method|
    it "#{method}()" do
      args = [method, '/test']

      body = %i[post put].include?(method) ? 'something' : nil
      if body
        args << body
        allow(puppet_http_client).to receive(method).
          with(URI(url), body, headers: headers, options: options, params: params).and_return(response)
      else
        allow(puppet_http_client).to receive(method).
          with(URI(url), headers: headers, options: options, params: params).and_return(response)
      end

      api_helper.send(*args)
      expect(puppet_http_client).to have_received(method).once
    end
  end

  %i[delete get head post put].each do |method|
    describe "##{method}" do
      it_behaves_like 'a Puppet::HTTP::Client', method
    end
  end
end
