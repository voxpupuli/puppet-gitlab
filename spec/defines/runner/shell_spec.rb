require 'spec_helper'

describe 'gitlab::runner::shell' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'test' }

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
      # shell: :undef,

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
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_exec('Register_runner_shell_test').with(
            command: '/usr/bin/gitlab-ci-multi-runner register --executor shell --registration-token TOKEN --url https://gitlab.com -n --name shell_test --run-untagged   --shell bash',
            unless:  '/bin/grep shell_test /etc/gitlab-runner/config.toml',
          )
        end
      end
      describe 'Change Defaults' do
        context 'token' do
          before { params.merge!(token: 'XXXchangemeXXX') }
          it { is_expected.to compile }
          # Add Check to validate change was successful
        end
      end
	  context 'gitlab::cirunner::run_untagged: true' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner':
		default_run_untagged => true
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{--run-untagged})
		end
	  end
	  context 'gitlab::cirunner::shell::run_untagged: true' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner::shell':
		default_run_untagged => true
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{--run-untagged})
		end
	  end
	  context 'run_untagged: true' do
		before { params.merge!(run_untagged: true) }
		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{--run-untagged})
		end
	  end
	  context 'gitlab::cirunner::run_untagged: false' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner':
		default_run_untagged => false
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{(?!--run-untagged)})
		end
	  end
	  context 'gitlab::cirunner::shell::run_untagged: false' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner::shell':
		default_run_untagged => false
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{(?!--run-untagged)})
		end
	  end
	  context 'run_untagged: false' do
		before { params.merge!(run_untagged: false) }
		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{(?!--run-untagged)})
		end
	  end
	  context 'gitlab::cirunner::locked: true' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner':
		default_locked => true
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{--locked})
		end
	  end
	  context 'gitlab::cirunner::shell::locked: true' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner::shell':
		default_locked => true
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{--locked})
		end
	  end
	  context 'locked: true' do
		before { params.merge!(locked: true) }
		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{--locked})
		end
	  end
	  context 'gitlab::cirunner::locked: false' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner':
		default_locked => false
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{(?!--locked)})
		end
	  end
	  context 'gitlab::cirunner::shell::locked: false' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner::shell':
		default_locked => false
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{(?!--locked)})
		end
	  end
	  context 'locked: false' do
		before { params.merge!(locked: false) }
		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{(?!--locked)})
		end
	  end
	  context 'gitlab::cirunner::shell::shell: foobar' do
		let (:pre_condition) do
		  "class {'::gitlab::cirunner::shell':
		default_shell => 'foobar'
	}"
		end

		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{--shell foobar})
		end
	  end
	  context 'shell: foobar' do
		before { params.merge!(shell: 'foobar') }
		it { is_expected.to compile }
		it do
		  is_expected.to contain_exec(
			'Register_runner_shell_test'
		  ).with_command(%r{--shell foobar})
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
		context 'pick_untagged' do
		  before { params.merge!(pick_untagged: 'foobar') }
		  it { expect { subject.call }.to raise_error(Puppet::Error) }
		end
		context 'lock_to_project' do
		  before { params.merge!(lock_to_project: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tags' do
          before { params.merge!(tags: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'shell' do
          before { params.merge!(shell: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
