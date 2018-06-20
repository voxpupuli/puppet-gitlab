require 'spec_helper'

describe 'gitlab::runner::kubernetes' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera

  let(:title) { 'test_kubernetes' }

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
      token: 'TOKEN',
      # description: :undef,
      # coordinator: :undef,
      # pick_untagged: :undef,
      # lock_to_project: :undef,
      # tags: :undef,
      # host: :undef,
      # cert_file: :undef,
      # key_file: :undef,
      # ca_file: :undef,
      # image: :undef,
      # namespace: :undef,
      # namespace_overwrite_allowed: :undef,
      # privileged: :undef,
      # cpu_limit: :undef,
      # memory_limit: :undef,
      # service_cpu_limit: :undef,
      # service_memory_limit: :undef,
      # helper_cpu_limit: :undef,
      # helper_memory_limit: :undef,
      # cpu_request: :undef,
      # memory_request: :undef,
      # service_cpu_request: :undef,
      # service_memory_request: :undef,
      # helper_cpu_request: :undef,
      # helper_memory_request: :undef,
      # pull_policy: :undef,
      # node_selector: :undef,
      # image_pull_secrets: :undef,
      # helper_image: :undef,
      # termination_grace_period: :undef,
      # poll_interval: :undef,
      # poll_timeout: :undef,
      # pod_labels: :undef,
      # service_account: :undef,
      # service_account_overwrite_allowed: :undef,

    }
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  let(:pre_condition) { "class {'::gitlab::cirunner::kubernetes': }" }

  test_on = {
    hardwaremodels: ['x86_64'],
    supported_os: [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['7']
      }
    ]
  }
  on_supported_os(test_on).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'check default config' do
        it do
          is_expected.to contain_exec("Register_runner_#{title}").with(
            command: %r{/usr/bin/gitlab-ci-multi-runner register --executor kubernetes --registration-token TOKEN --url https://gitlab.com -n --name kubernetes_#{title} --run-untagged\s+$},
            unless:  "/bin/grep kubernetes_#{title} /etc/gitlab-runner/config.toml"
          )
        end
      end
      describe 'Change Defaults' do
        context 'gitlab::cirunner::run_untagged: true' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner':
            default_run_untagged => true
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--run-untagged})
          end
        end
        context 'gitlab::cirunner::kubernetes::run_untagged: true' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_run_untagged => true
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--run-untagged})
          end
        end
        context 'run_untagged: true' do
          before { params.merge!(run_untagged: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--run-untagged})
          end
        end
        context 'gitlab::cirunner::run_untagged: false' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner':
            default_run_untagged => false
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--run-untagged)})
          end
        end
        context 'gitlab::cirunner::kubernetes::run_untagged: false' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_run_untagged => false
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--run-untagged)})
          end
        end
        context 'run_untagged: false' do
          before { params.merge!(run_untagged: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--run-untagged)})
          end
        end
        context 'gitlab::cirunner::locked: true' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner':
            default_locked => true
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--locked})
          end
        end
        context 'gitlab::cirunner::kubernetes::locked: true' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_locked => true
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--locked})
          end
        end
        context 'locked: true' do
          before { params.merge!(locked: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--locked})
          end
        end
        context 'gitlab::cirunner::locked: false' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner':
            default_locked => false
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--locked)})
          end
        end
        context 'gitlab::cirunner::kubernetes::locked: false' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_locked => false
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--locked)})
          end
        end
        context 'locked: false' do
          before { params.merge!(locked: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--locked)})
          end
        end
        context 'gitlab::cirunner::tags: %w[foo bar]' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner':
            default_tags => ['foo', 'bar']
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--tag-list foo,bar})
          end
        end
        context 'gitlab::cirunner::kubernetes::tags: %w[foo bar]' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_tags => ['foo', 'bar']
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--tag-list foo,bar})
          end
        end
        context 'tags: %w[foo bar]' do
          before { params.merge!(tags: %w[foo bar]) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--tag-list foo,bar})
          end
        end
        context "gitlab::cirunner::kubernetes::host: 'foobar'" do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_host => 'foobar'
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-host foobar})
          end
        end
        context "host: 'foobar'" do
          before { params.merge!(host: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-host foobar})
          end
        end
        context "gitlab::cirunner::kubernetes::image: 'foobar'" do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_image => 'foobar'
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-image foobar})
          end
        end
        context "image: 'foobar'" do
          before { params.merge!(image: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-image foobar})
          end
        end
        context "gitlab::cirunner::kubernetes::namespace: 'foobar'" do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_namespace => 'foobar'
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-namespace foobar})
          end
        end
        context "namespace: 'foobar'" do
          before { params.merge!(namespace: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-namespace foobar})
          end
        end
        context "gitlab::cirunner::kubernetes::namespace_overwrite_allowed: 'foobar'" do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_namespace_overwrite_allowed => 'foobar'
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-namespace_overwrite_allowed foobar})
          end
        end
        context "namespace_overwrite_allowed: 'foobar'" do
          before { params.merge!(namespace_overwrite_allowed: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-namespace_overwrite_allowed foobar})
          end
        end
        context 'gitlab::cirunner::kubernetes::privileged: true' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_privileged => true
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-privileged})
          end
        end
        context 'privileged: true' do
          before { params.merge!(privileged: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-privileged})
          end
        end
        context 'gitlab::cirunner::kubernetes::privileged: false' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_privileged => false
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--kubernetes-privileged)})
          end
        end
        context 'privileged: false' do
          before { params.merge!(privileged: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--kubernetes-privileged)})
          end
        end
        context 'gitlab::cirunner::kubernetes::cpu_limit: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_cpu_limit => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-cpu-limit 42})
          end
        end
        context 'cpu_limit: 42' do
          before { params.merge!(cpu_limit: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-cpu-limit 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::memory_limit: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_memory_limit => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-memory-limit 42})
          end
        end
        context 'memory_limit: 42' do
          before { params.merge!(memory_limit: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-memory-limit 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::service_cpu_limit: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_service_cpu_limit => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-cpu-limit 42})
          end
        end
        context 'service_cpu_limit: 42' do
          before { params.merge!(service_cpu_limit: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-cpu-limit 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::service_memory_limit: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_service_memory_limit => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-memory-limit 42})
          end
        end
        context 'service_memory_limit: 42' do
          before { params.merge!(service_memory_limit: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-memory-limit 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::helper_cpu_limit: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_helper_cpu_limit => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-cpu-limit 42})
          end
        end
        context 'helper_cpu_limit: 42' do
          before { params.merge!(helper_cpu_limit: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-cpu-limit 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::helper_memory_limit: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_helper_memory_limit => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-memory-limit 42})
          end
        end
        context 'helper_memory_limit: 42' do
          before { params.merge!(helper_memory_limit: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-memory-limit 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::cpu_request: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_cpu_request => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-cpu-request 42})
          end
        end
        context 'cpu_request: 42' do
          before { params.merge!(cpu_request: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-cpu-request 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::memory_request: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_memory_request => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-memory-request 42})
          end
        end
        context 'memory_request: 42' do
          before { params.merge!(memory_request: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-memory-request 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::service_cpu_request: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_service_cpu_request => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-cpu-request 42})
          end
        end
        context 'service_cpu_request: 42' do
          before { params.merge!(service_cpu_request: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-cpu-request 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::service_memory_request: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_service_memory_request => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-memory-request 42})
          end
        end
        context 'service_memory_request: 42' do
          before { params.merge!(service_memory_request: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-memory-request 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::helper_cpu_request: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_helper_cpu_request => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-cpu-request 42})
          end
        end
        context 'helper_cpu_request: 42' do
          before { params.merge!(helper_cpu_request: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-cpu-request 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::helper_memory_request: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_helper_memory_request => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-memory-request 42})
          end
        end
        context 'helper_memory_request: 42' do
          before { params.merge!(helper_memory_request: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-memory-request 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::pull_policy: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_pull_policy => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-pull-policy 42})
          end
        end
        context 'pull_policy: 42' do
          before { params.merge!(pull_policy: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-pull-policy 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::node_selector: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_node_selector => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-node-selector 42})
          end
        end
        context 'node_selector: 42' do
          before { params.merge!(node_selector: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-node-selector 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::image_pull_secrets: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_image_pull_secrets => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-image-pull-secrets 42})
          end
        end
        context 'image_pull_secrets: 42' do
          before { params.merge!(image_pull_secrets: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-image-pull-secrets 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::helper_image: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_helper_image => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-image 42})
          end
        end
        context 'helper_image: 42' do
          before { params.merge!(helper_image: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-helper-image 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::termination_grace_period: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_termination_grace_period => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-terminationGracePeriodSeconds 42})
          end
        end
        context 'termination_grace_period: 42' do
          before { params.merge!(termination_grace_period: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-terminationGracePeriodSeconds 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::poll_interval: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_poll_interval => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-poll-interval 42})
          end
        end
        context 'poll_interval: 42' do
          before { params.merge!(poll_interval: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-poll-interval 42})
          end
        end
        context 'gitlab::cirunner::kubernetes::poll_timeout: 42' do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_poll_timeout => 42
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-poll-timeout 42})
          end
        end
        context 'poll_timeout: 42' do
          before { params.merge!(poll_timeout: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-poll-timeout 42})
          end
        end
        context "gitlab::cirunner::kubernetes::pod_labels: 'foobar'" do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_pod_labels => 'foobar'
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-pod-labels foobar})
          end
        end
        context "pod_labels: 'foobar'" do
          before { params.merge!(pod_labels: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-pod-labels foobar})
          end
        end
        context "gitlab::cirunner::kubernetes::service_account: 'foobar'" do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_service_account => 'foobar'
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-account foobar})
          end
        end
        context "service_account: 'foobar'" do
          before { params.merge!(service_account: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service-account foobar})
          end
        end
        context "gitlab::cirunner::kubernetes::service_account_overwrite_allowed: 'foobar'" do
          let(:pre_condition) do
            "class {'::gitlab::cirunner::kubernetes':
            default_service_account_overwrite_allowed => 'foobar'
          }"
          end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service_account_overwrite_allowed foobar})
          end
        end
        context "service_account_overwrite_allowed: 'foobar'" do
          before { params.merge!(service_account_overwrite_allowed: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--kubernetes-service_account_overwrite_allowed foobar})
          end
        end
      end
      describe 'check bad type' do
        context 'token' do
          before { params.merge!(token: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'run_untagged' do
          before { params.merge!(run_untagged: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'locked' do
          before { params.merge!(locked: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tags' do
          before { params.merge!(tags: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'host' do
          before { params.merge!(host: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'cert_file' do
          before { params.merge!(cert_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'key_file' do
          before { params.merge!(key_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ca_file' do
          before { params.merge!(ca_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'image' do
          before { params.merge!(image: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'namespace' do
          before { params.merge!(namespace: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'namespace_overwrite_allowed' do
          before { params.merge!(namespace_overwrite_allowed: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'privileged' do
          before { params.merge!(privileged: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'cpu_limit' do
          before { params.merge!(cpu_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'memory_limit' do
          before { params.merge!(memory_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'service_cpu_limit' do
          before { params.merge!(service_cpu_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'service_memory_limit' do
          before { params.merge!(service_memory_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'helper_cpu_limit' do
          before { params.merge!(helper_cpu_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'helper_memory_limit' do
          before { params.merge!(helper_memory_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'cpu_request' do
          before { params.merge!(cpu_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'memory_request' do
          before { params.merge!(memory_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'service_cpu_request' do
          before { params.merge!(service_cpu_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'service_memory_request' do
          before { params.merge!(service_memory_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'helper_cpu_request' do
          before { params.merge!(helper_cpu_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'helper_memory_request' do
          before { params.merge!(helper_memory_request: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'pull_policy' do
          before { params.merge!(pull_policy: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'node_selector' do
          before { params.merge!(node_selector: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'image_pull_secrets' do
          before { params.merge!(image_pull_secrets: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'helper_image' do
          before { params.merge!(helper_image: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'termination_grace_period' do
          before { params.merge!(termination_grace_period: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'poll_interval' do
          before { params.merge!(poll_interval: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'poll_timeout' do
          before { params.merge!(poll_timeout: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'pod_labels' do
          before { params.merge!(pod_labels: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'service_account' do
          before { params.merge!(service_account: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'service_account_overwrite_allowed' do
          before { params.merge!(service_account_overwrite_allowed: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
