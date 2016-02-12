require 'spec_helper'

describe 'gitlab::cirunner::kubernetes' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'gitlab::cirunner::kubernetes.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      # runners: {},
      # default_coordinator: :undef,
      # default_run_untagged: :undef,
      # default_locked: :undef,
      # default_tags: :undef,
      # default_host: :undef,
      # default_cert_file: :undef,
      # default_key_file: :undef,
      # default_ca_file: :undef,
      # default_image: :undef,
      # default_namespace: :undef,
      # default_namespace_overwrite_allowed: :undef,
      # default_privileged: :undef,
      # default_cpu_limit: :undef,
      # default_memory_limit: :undef,
      # default_service_cpu_limit: :undef,
      # default_service_memory_limit: :undef,
      # default_helper_cpu_limit: :undef,
      # default_helper_memory_limit: :undef,
      # default_cpu_request: :undef,
      # default_memory_request: :undef,
      # default_service_cpu_request: :undef,
      # default_service_memory_request: :undef,
      # default_helper_cpu_request: :undef,
      # default_helper_memory_request: :undef,
      # default_pull_policy: :undef,
      # default_node_selector: :undef,
      # default_image_pull_secrets: :undef,
      # default_helper_image: :undef,
      # default_termination_grace_period: :undef,
      # default_poll_interval: :undef,
      # default_poll_timeout: :undef,
      # default_pod_labels: :undef,
      # default_service_account: :undef,
      # default_service_account_overwrite_allowed: :undef,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }

  test_on = {
    :hardwaremodels => ['x86_64'],
    :supported_os   => [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['7'],
      },
    ],
  }
  on_supported_os(test_on).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
      end
      describe 'check bad type' do
        context 'runners' do
          before { params.merge!(runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_coordinator' do
          before { params.merge!(default_coordinator: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_run_untagged' do
          before { params.merge!(default_run_untagged: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_locked' do
          before { params.merge!(default_locked: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_tags' do
          before { params.merge!(default_tags: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_host' do
          before { params.merge!(default_host: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cert_file' do
          before { params.merge!(default_cert_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_key_file' do
          before { params.merge!(default_key_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_ca_file' do
          before { params.merge!(default_ca_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_image' do
          before { params.merge!(default_image: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_namespace' do
          before { params.merge!(default_namespace: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_namespace_overwrite_allowed' do
          before { params.merge!(default_namespace_overwrite_allowed: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_privileged' do
          before { params.merge!(default_privileged: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cpu_limit' do
          before { params.merge!(default_cpu_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_memory_limit' do
          before { params.merge!(default_memory_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_service_cpu_limit' do
          before { params.merge!(default_service_cpu_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_service_memory_limit' do
          before { params.merge!(default_service_memory_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_helper_cpu_limit' do
          before { params.merge!(default_helper_cpu_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_helper_memory_limit' do
          before { params.merge!(default_helper_memory_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_cpu_request' do
          before { params.merge!(default_cpu_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_memory_request' do
          before { params.merge!(default_memory_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_service_cpu_request' do
          before { params.merge!(default_service_cpu_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_service_memory_request' do
          before { params.merge!(default_service_memory_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_helper_cpu_request' do
          before { params.merge!(default_helper_cpu_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_helper_memory_request' do
          before { params.merge!(default_helper_memory_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_pull_policy' do
          before { params.merge!(default_pull_policy: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_node_selector' do
          before { params.merge!(default_node_selector: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_image_pull_secrets' do
          before { params.merge!(default_image_pull_secrets: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_helper_image' do
          before { params.merge!(default_helper_image: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_termination_grace_period' do
          before { params.merge!(default_termination_grace_period: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_poll_interval' do
          before { params.merge!(default_poll_interval: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_poll_timeout' do
          before { params.merge!(default_poll_timeout: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_pod_labels' do
          before { params.merge!(default_pod_labels: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_service_account' do
          before { params.merge!(default_service_account: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'default_service_account_overwrite_allowed' do
          before { params.merge!(default_service_account_overwrite_allowed: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
