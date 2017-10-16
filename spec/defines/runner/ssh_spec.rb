require 'spec_helper'

describe 'gitlab::runner::ssh' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'ssh_test' }

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
      # ssh_user: :undef,
      # ssh_password: :undef,
      # ssh_host: :undef,
      # ssh_port: :undef,
      # ssh_identity_file: :undef,

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
            command: %r{/usr/bin/gitlab-ci-multi-runner register --executor ssh --registration-token TOKEN --url https://gitlab.com -n ssh_#{title} --run-untagged\s+$},
            unless:  "/bin/grep ssh_#{title} /etc/gitlab-runner/config.toml",
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
        context "gitlab::cirunner::ssh::run_untagged: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
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
        context "gitlab::cirunner::ssh::run_untagged: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
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
        context "gitlab::cirunner::ssh::locked: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
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
        context "gitlab::cirunner::ssh::locked: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
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
            ).with_command(%r{--tag-list foo,bar})
          end
        end
        context "gitlab::cirunner::ssh::tags: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
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
        context "tags: ['foo', 'bar']" do
          before { params.merge!(tags: ['foo', 'bar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--tag-list foo,bar})
          end
        end
        context "gitlab::cirunner::ssh::ssh_user: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
            default_ssh_user => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-user foobar})
          end
        end
        context "ssh_user: 'foobar'" do
          before { params.merge!(ssh_user: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-user foobar})
          end
        end
        context "gitlab::cirunner::ssh::ssh_password: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
            default_ssh_password => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-password foobar})
          end
        end
        context "ssh_password: 'foobar'" do
          before { params.merge!(ssh_password: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-password foobar})
          end
        end
        context "gitlab::cirunner::ssh::ssh_host: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
            default_ssh_host => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-host foobar})
          end
        end
        context "ssh_host: 'foobar'" do
          before { params.merge!(ssh_host: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-host foobar})
          end
        end
        context "gitlab::cirunner::ssh::ssh_port: 42" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
            default_ssh_port => 42
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-port 42})
          end
        end
        context "ssh_port: 42" do
          before { params.merge!(ssh_port: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-port 42})
          end
        end
        context "gitlab::cirunner::ssh::ssh_identity_file: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::ssh':
            default_ssh_identity_file => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-identity-file foobar})
          end
        end
        context "ssh_identity_file: 'foobar'" do
          before { params.merge!(ssh_identity_file: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--ssh-identity-file foobar})
          end
        end
      end
      describe 'check bad type' do
        context 'token' do
          before { params.merge!(token: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'description' do
          before { params.merge!(description: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'coordinator' do
          before { params.merge!(coordinator: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'pick_untagged' do
          before { params.merge!(pick_untagged: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'lock_to_project' do
          before { params.merge!(lock_to_project: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tags' do
          before { params.merge!(tags: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ssh_user' do
          before { params.merge!(ssh_user: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ssh_password' do
          before { params.merge!(ssh_password: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ssh_host' do
          before { params.merge!(ssh_host: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ssh_port' do
          before { params.merge!(ssh_port: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ssh_identity_file' do
          before { params.merge!(ssh_identity_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
