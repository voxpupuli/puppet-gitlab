require 'spec_helper'

describe 'gitlab::custom_hook' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera

  let(:title) { 'test_hook' }

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
      namespace: 'test_name',
      project: 'test_project',
      type: 'update',
      content: 'exit'
      # source: :undef,
      # repos_path: :undef,

    }
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  let(:pre_condition) { "class {'::gitlab': }" }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file(
            '/var/opt/gitlab/git-data/repositories/test_name/test_project.git/custom_hooks'
          ).with_ensure('directory')
        end
        it do
          is_expected.to contain_file(
            '/var/opt/gitlab/git-data/repositories/test_name/test_project.git/custom_hooks/update'
          ).with(
            ensure: 'present',
            content: 'exit'
          )
        end
      end
      describe 'Change Defaults' do
        context 'namespace' do
          before { params.merge!(namespace: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/var/opt/gitlab/git-data/repositories/foobar/test_project.git/custom_hooks'
            ).with_ensure('directory')
          end
          it do
            is_expected.to contain_file(
              '/var/opt/gitlab/git-data/repositories/foobar/test_project.git/custom_hooks/update'
            ).with(
              ensure: 'present',
              content: 'exit'
            )
          end
        end
        context 'project' do
          before { params.merge!(project: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/var/opt/gitlab/git-data/repositories/test_name/foobar.git/custom_hooks'
            ).with_ensure('directory')
          end
          it do
            is_expected.to contain_file(
              '/var/opt/gitlab/git-data/repositories/test_name/foobar.git/custom_hooks/update'
            ).with(
              ensure: 'present',
              content: 'exit'
            )
          end
        end
        context 'type' do
          before { params.merge!(type: 'pre-receive') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/var/opt/gitlab/git-data/repositories/test_name/test_project.git/custom_hooks/pre-receive'
            ).with(
              ensure: 'present',
              content: 'exit'
            )
          end
        end
        context 'content' do
          before { params.merge!(content: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/var/opt/gitlab/git-data/repositories/test_name/test_project.git/custom_hooks/update'
            ).with(
              ensure: 'present',
              content: 'foobar'
            )
          end
        end
        context 'source' do
          before { params.merge!(source: 'puppet:///foobar', content: :undef) }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_file(
              '/var/opt/gitlab/git-data/repositories/test_name/test_project.git/custom_hooks'
            ).with_ensure('directory')
          end
          it do
            is_expected.to contain_file(
              '/var/opt/gitlab/git-data/repositories/test_name/test_project.git/custom_hooks/update'
            ).with(
              ensure: 'present',
              source: 'puppet:///foobar'
            )
          end
        end
        context 'repos_path' do
          before { params.merge!(repos_path: '/foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/foobar/test_name/test_project.git/custom_hooks'
            ).with_ensure('directory')
          end
          it do
            is_expected.to contain_file(
              '/foobar/test_name/test_project.git/custom_hooks/update'
            ).with(
              ensure: 'present',
              content: 'exit'
            )
          end
        end
      end
      describe 'check bad type' do
        context 'namespace' do
          before { params.merge!(namespace: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'project' do
          before { params.merge!(project: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'type' do
          before { params.merge!(type: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'type bad string' do
          before { params.merge!(type: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'source' do
          before { params.merge!(source: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'repos_path' do
          before { params.merge!(repos_path: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
