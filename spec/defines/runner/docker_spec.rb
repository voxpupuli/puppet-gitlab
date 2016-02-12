require 'spec_helper'

describe 'gitlab::runner::docker' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'docker_runner' }

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
	  # coordinator: :undef,
	  # pick_untagged: :undef,
	  # lock_to_project: :undef,
	  # tags: :undef,
	  # host: :undef,
	  # cert_path: :undef,
	  # tlsverify: :undef,
	  # hostname: :undef,
	  # image: :undef,
	  # cpuset_cpus: :undef,
	  # cpus: :undef,
	  # dns: :undef,
	  # dns_search: :undef,
	  # privileged: :undef,
	  # userns: :undef,
	  # cap_add: :undef,
	  # cap_drop: :undef,
	  # security_opt: :undef,
	  # devices: :undef,
	  # disable_cache: :undef,
	  # volumes: :undef,
	  # volume_driver: :undef,
	  # cache_dir: :undef,
	  # extra_hosts: :undef,
	  # volumes_from: :undef,
	  # network_mode: :undef,
	  # links: :undef,
	  # services: :undef,
	  # wait_for_services_timeout: :undef,
	  # allowed_images: :undef,
	  # allowed_services: :undef,
	  # pull_policy: :undef,
	  # shm_size: :undef,

	}
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  let (:pre_condition) { "class {'::gitlab::cirunner': }" }

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
        it do
          is_expected.to contain_exec("Register_runner_#{title}").with(
            command: %r{/usr/bin/gitlab-ci-multi-runner register --executor docker --registration-token TOKEN --url https://gitlab.com -n docker_#{title} --run-untagged\s+--docker-image ubuntu_trusty\s+},
            unless:  "/bin/grep docker_#{title} /etc/gitlab-runner/config.toml",
          )
        end
      end
      describe 'Change Defaults' do
        context "gitlab::cirunner::run_untagged: true" do
          let (:pre_condition) do
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
        context "gitlab::cirunner::docker::run_untagged: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
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
        context "run_untagged: true" do
          before { params.merge!(run_untagged: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--run-untagged})
          end
        end
        context "gitlab::cirunner::run_untagged: false" do
          let (:pre_condition) do
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
        context "gitlab::cirunner::docker::run_untagged: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
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
        context "run_untagged: false" do
          before { params.merge!(run_untagged: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--run-untagged)})
          end
        end
        context "gitlab::cirunner::locked: true" do
          let (:pre_condition) do
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
        context "gitlab::cirunner::docker::locked: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
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
        context "locked: true" do
          before { params.merge!(locked: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--locked})
          end
        end
        context "gitlab::cirunner::locked: false" do
          let (:pre_condition) do
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
        context "gitlab::cirunner::docker::locked: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
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
        context "locked: false" do
          before { params.merge!(locked: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--locked)})
          end
        end
        context "gitlab::cirunner::tags: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner':
            default_tags => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--tags foo,bar})
          end
        end
        context "gitlab::cirunner::docker::tags: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_tags => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--tags foo,bar})
          end
        end
        context "tags: ['foo', 'bar']" do
          before { params.merge!(tags: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--tags foo,bar})
          end
        end
        context "gitlab::cirunner::docker::host: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_host => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-host foobar})
          end
        end
        context "host: 'foobar'" do
          before { params.merge!(host: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-host foobar})
          end
        end
        context "gitlab::cirunner::docker::tlsverify: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_tlsverify => true
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-tlsverify})
          end
        end
        context "tlsverify: true" do
          before { params.merge!(tlsverify: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-tlsverify})
          end
        end
        context "gitlab::cirunner::docker::tlsverify: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_tlsverify => false
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-tlsverify)})
          end
        end
        context "tlsverify: false" do
          before { params.merge!(tlsverify: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-tlsverify)})
          end
        end
        context "gitlab::cirunner::docker::hostname: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_hostname => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-hostname foobar})
          end
        end
        context "hostname: 'foobar'" do
          before { params.merge!(hostname: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-hostname foobar})
          end
        end
        context "gitlab::cirunner::docker::image: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_image => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-image foobar})
          end
        end
        context "image: 'foobar'" do
          before { params.merge!(image: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-image foobar})
          end
        end
        context "gitlab::cirunner::docker::cpuset_cpus: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_cpuset_cpus => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-cpuset-cpus foobar})
          end
        end
        context "cpuset_cpus: 'foobar'" do
          before { params.merge!(cpuset_cpus: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-cpuset-cpus foobar})
          end
        end
        context "gitlab::cirunner::docker::cpus: 42" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_cpus => 42
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-cpus 42})
          end
        end
        context "cpus: 42" do
          before { params.merge!(cpus: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-cpus 42})
          end
        end
        context "gitlab::cirunner::docker::dns: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_dns => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-dns foo,bar})
          end
        end
        context "dns: ['foo', 'bar']" do
          before { params.merge!(dns: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-dns foo,bar})
          end
        end
        context "gitlab::cirunner::docker::dns_search: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_dns_search => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-dns-search foo,bar})
          end
        end
        context "dns_search: ['foo', 'bar']" do
          before { params.merge!(dns_search: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-dns-search foo,bar})
          end
        end
        context "gitlab::cirunner::docker::privileged: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_privileged => true
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-privileged})
          end
        end
        context "privileged: true" do
          before { params.merge!(privileged: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-privileged})
          end
        end
        context "gitlab::cirunner::docker::privileged: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_privileged => false
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-privileged)})
          end
        end
        context "privileged: false" do
          before { params.merge!(privileged: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-privileged)})
          end
        end
        context "gitlab::cirunner::docker::userns: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_userns => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-userns foobar})
          end
        end
        context "userns: 'foobar'" do
          before { params.merge!(userns: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-userns foobar})
          end
        end
        context "gitlab::cirunner::docker::cap_add: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_cap_add => true
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-cap-add})
          end
        end
        context "cap_add: true" do
          before { params.merge!(cap_add: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-cap-add})
          end
        end
        context "gitlab::cirunner::docker::cap_add: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_cap_add => false
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-cap-add)})
          end
        end
        context "cap_add: false" do
          before { params.merge!(cap_add: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-cap-add)})
          end
        end
        context "gitlab::cirunner::docker::cap_drop: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_cap_drop => true
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-cap-drop})
          end
        end
        context "cap_drop: true" do
          before { params.merge!(cap_drop: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-cap-drop})
          end
        end
        context "gitlab::cirunner::docker::cap_drop: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_cap_drop => false
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-cap-drop)})
          end
        end
        context "cap_drop: false" do
          before { params.merge!(cap_drop: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-cap-drop)})
          end
        end
        context "gitlab::cirunner::docker::security_opt: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_security_opt => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-security-opt foobar})
          end
        end
        context "security_opt: 'foobar'" do
          before { params.merge!(security_opt: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-security-opt foobar})
          end
        end
        context "gitlab::cirunner::docker::devices: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_devices => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-devices foobar})
          end
        end
        context "devices: 'foobar'" do
          before { params.merge!(devices: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-devices foobar})
          end
        end
        context "gitlab::cirunner::docker::disable_cache: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_disable_cache => true
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-disable-cache})
          end
        end
        context "disable_cache: true" do
          before { params.merge!(disable_cache: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-disable-cache})
          end
        end
        context "gitlab::cirunner::docker::disable_cache: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_disable_cache => false
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-disable-cache)})
          end
        end
        context "disable_cache: false" do
          before { params.merge!(disable_cache: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--docker-disable-cache)})
          end
        end
        context "gitlab::cirunner::docker::volume_driver: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_volume_driver => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-volume-driver foobar})
          end
        end
        context "volume_driver: 'foobar'" do
          before { params.merge!(volume_driver: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-volume-driver foobar})
          end
        end
        context "gitlab::cirunner::docker::extra_hosts: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_extra_hosts => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-extra-hosts foobar})
          end
        end
        context "extra_hosts: 'foobar'" do
          before { params.merge!(extra_hosts: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-extra-hosts foobar})
          end
        end
        context "gitlab::cirunner::docker::volumes_from: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_volumes_from => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-volumes-from foo,bar})
          end
        end
        context "volumes_from: ['foo', 'bar']" do
          before { params.merge!(volumes_from: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-volumes-from foo,bar})
          end
        end
        context "gitlab::cirunner::docker::network_mode: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_network_mode => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-network-mode foobar})
          end
        end
        context "network_mode: 'foobar'" do
          before { params.merge!(network_mode: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-network-mode foobar})
          end
        end
        context "gitlab::cirunner::docker::links: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_links => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-links foo,bar})
          end
        end
        context "links: ['foo', 'bar']" do
          before { params.merge!(links: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-links foo,bar})
          end
        end
        context "gitlab::cirunner::docker::services: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_services => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-services foo,bar})
          end
        end
        context "services: ['foo', 'bar']" do
          before { params.merge!(services: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-services foo,bar})
          end
        end
        context "gitlab::cirunner::docker::wait_for_services_timeout: 42" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_wait_for_services_timeout => 42
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-wait-for-services-timeout 42})
          end
        end
        context "wait_for_services_timeout: 42" do
          before { params.merge!(wait_for_services_timeout: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-wait-for-services-timeout 42})
          end
        end
        context "gitlab::cirunner::docker::allowed_images: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_allowed_images => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-allowed-images foo,bar})
          end
        end
        context "allowed_images: ['foo', 'bar']" do
          before { params.merge!(allowed_images: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-allowed-images foo,bar})
          end
        end
        context "gitlab::cirunner::docker::allowed_services: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_allowed_services => ['foo', 'bar']
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-allowed-services foo,bar})
          end
        end
        context "allowed_services: ['foo', 'bar']" do
          before { params.merge!(allowed_services: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-allowed-services foo,bar})
          end
        end
        context "gitlab::cirunner::docker::pull_policy: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_pull_policy => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-pull-policy foobar})
          end
        end
        context "pull_policy: 'foobar'" do
          before { params.merge!(pull_policy: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-pull-policy foobar})
          end
        end
        context "gitlab::cirunner::docker::shm_size: 42" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::docker':
            default_shm_size => 42
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-shm-size 42})
          end
        end
        context "shm_size: 42" do
          before { params.merge!(shm_size: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--docker-shm-size 42})
          end
        end
      end
		describe 'check bad type' do
		context 'token' do
		  before { params.merge!(token: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'coordinator' do
		  before { params.merge!(coordinator: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'run_untagged' do
		  before { params.merge!(run_untagged: 'foobar') }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'locked' do
		  before { params.merge!(lock_to_project: 'foobar') }
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
		context 'cert_path' do
		  before { params.merge!(cert_path: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'tlsverify' do
		  before { params.merge!(tlsverify: 'foobar') }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'hostname' do
		  before { params.merge!(hostname: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'image' do
		  before { params.merge!(image: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'cpuset_cpus' do
		  before { params.merge!(cpuset_cpus: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'cpus' do
		  before { params.merge!(cpus: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'dns' do
		  before { params.merge!(dns: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'dns_search' do
		  before { params.merge!(dns_search: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'privileged' do
		  before { params.merge!(privileged: 'foobar') }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'userns' do
		  before { params.merge!(userns: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'cap_add' do
		  before { params.merge!(cap_add: 'foobar') }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'cap_drop' do
		  before { params.merge!(cap_drop: 'foobar') }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'security_opt' do
		  before { params.merge!(security_opt: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'devices' do
		  before { params.merge!(devices: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'disable_cache' do
		  before { params.merge!(disable_cache: 'foobar') }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'volumes' do
		  before { params.merge!(volumes: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'volume_driver' do
		  before { params.merge!(volume_driver: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'cache_dir' do
		  before { params.merge!(cache_dir: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'extra_hosts' do
		  before { params.merge!(extra_hosts: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'volumes_from' do
		  before { params.merge!(volumes_from: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'network_mode' do
		  before { params.merge!(network_mode: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'links' do
		  before { params.merge!(links: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'services' do
		  before { params.merge!(services: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'wait_for_services_timeout' do
		  before { params.merge!(wait_for_services_timeout: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'allowed_images' do
		  before { params.merge!(allowed_images: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'allowed_services' do
		  before { params.merge!(allowed_services: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'pull_policy' do
		  before { params.merge!(pull_policy: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'shm_size' do
		  before { params.merge!(shm_size: true) }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
	  end
	end
  end
end
