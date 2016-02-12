require 'spec_helper'

describe 'gitlab::runner::parallels' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'parallels_test' }

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
      # base_name: :undef,
      # template_name: :undef,
      # disable_snapshots: :undef,
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  let (:pre_condition) { "class {'::gitlab::cirunner::parallels': }" }

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
            command: %r{/usr/bin/gitlab-ci-multi-runner register --executor parallels --registration-token TOKEN --url https://gitlab.com -n parallels_#{title} --run-untagged\s+--parallels-disable-snapshots$},
            unless:  "/bin/grep parallels_#{title} /etc/gitlab-runner/config.toml",
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
        context "gitlab::cirunner::parallels::run_untagged: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
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
        context "gitlab::cirunner::parallels::run_untagged: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
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
        context "gitlab::cirunner::parallels::locked: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
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
        context "gitlab::cirunner::parallels::locked: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
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
        context "gitlab::cirunner::parallels::tags: ['foo', 'bar']" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
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
        context "gitlab::cirunner::parallels::base_name: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
            default_base_name => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--parallels-base-name foobar})
          end
        end
        context "base_name: 'foobar'" do
          before { params.merge!(base_name: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--parallels-base-name foobar})
          end
        end
        context "gitlab::cirunner::parallels::template_name: 'foobar'" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
            default_template_name => 'foobar'
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--parallels-template-name foobar})
          end
        end
        context "template_name: 'foobar'" do
          before { params.merge!(template_name: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--parallels-template-name foobar})
          end
        end
        context "gitlab::cirunner::parallels::disable_snapshots: true" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
            default_disable_snapshots => true
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--parallels-disable-snapshots})
          end
        end
        context "disable_snapshots: true" do
          before { params.merge!(disable_snapshots: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{--parallels-disable-snapshots})
          end
        end
        context "gitlab::cirunner::parallels::disable_snapshots: false" do
          let (:pre_condition) do
          "class {'::gitlab::cirunner::parallels':
            default_disable_snapshots => false
          }"
        end

          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--parallels-disable-snapshots)})
          end
        end
        context "disable_snapshots: false" do
          before { params.merge!(disable_snapshots: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_exec(
              "Register_runner_#{title}"
            ).with_command(%r{(?!--parallels-disable-snapshots)})
          end
        end
      end
      describe 'check bad type' do
        context 'token' do
          before { params.merge!(token: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'pick_untagged' do
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
        context 'base_name' do
          before { params.merge!(base_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'template_name' do
          before { params.merge!(template_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'disable_snapshots' do
          before { params.merge!(disable_snapshots: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
