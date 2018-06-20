require 'spec_helper'

describe 'gitlab::cirunner' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'gitlab_cirunner.example.com' }

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
      # concurrent: :undef,
      # manage_repo: true,
      # conf_file: '/etc/gitlab-runner/config.toml',
      # package_ensure: 'installed',
      # default_coordinator: 'https://gitlab.com',
      # default_run_untagged: true,
      # default_locked: false,
      # default_tags: :undef,
      # docker_runners: {},
      # shell_runners: {},
      # ssh_runners: {},
      # docker_ssh_runners: {},
      # parallels_runners: {},
      # virtualbox_runners: {},
      # kubernetes_runners: {},

    }
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('gitlab::cirunner') }
        if facts[:osfamily] == 'Debian'
          it { is_expected.to contain_package('apt-transport-https') }
          it { is_expected.to contain_class('apt') }
          it do
            is_expected.to contain_apt__source('apt_gitlabci').with(
              comment: 'GitlabCI Runner Repo',
              location: "https://packages.gitlab.com/runner/gitlab-runner/#{facts[:lsbdistid].downcase}/",
              release: facts[:lsbdistcodename],
              repos: 'main',
              key: {
                'id'     => '1A4C919DB987D435939638B914219A96E15E78F4',
                'server' => 'keys.gnupg.net'
              },
              include: {
                'src' => false,
                'deb' => true
              }
            )
          end
        elsif facts[:osfamily] == 'RedHat'
          it do
            is_expected.to contain_yumrepo('runner_gitlab-runner').with(
              ensure: 'present',
              baseurl: "https://packages.gitlab.com/runner/gitlab-runner/el/#{facts[:operatingsystemmajrelease]}/$basearch",
              descr: 'runner_gitlab-runner',
              enabled: '1',
              gpgcheck: '0',
              gpgkey: 'https://packages.gitlab.com/gpg.key',
              repo_gpgcheck: '1',
              sslcacert: '/etc/pki/tls/certs/ca-bundle.crt',
              sslverify: '1'
            )
          end
          it do
            is_expected.to contain_yumrepo('runner_gitlab-runner-source').with(
              ensure: 'present',
              baseurl: "https://packages.gitlab.com/runner/gitlab-runner/el/#{facts[:operatingsystemmajrelease]}/SRPMS",
              descr: 'runner_gitlab-runner-source',
              enabled: '1',
              gpgcheck: '0',
              gpgkey: 'https://packages.gitlab.com/gpg.key',
              repo_gpgcheck: '1',
              sslcacert: '/etc/pki/tls/certs/ca-bundle.crt',
              sslverify: '1'
            )
          end
        end
        it do
          is_expected.to contain_package('gitlab-runner').with_ensure(
            'installed'
          )
        end
        it { is_expected.not_to contain_file_line('gitlab-runner-concurrent') }
        it do
          is_expected.to contain_exec('gitlab-runner-restart').with(
            command: '/usr/bin/gitlab-runner restart',
            refreshonly: true,
            require: 'Package[gitlab-runner]'
          )
        end
        it { is_expected.not_to contain_class('::gitlab::cirunner::docker') }
        it { is_expected.not_to contain_class('::gitlab::cirunner::shell') }
        it { is_expected.not_to contain_class('::gitlab::cirunner::ssh') }
        it { is_expected.not_to contain_class('::gitlab::cirunner::docker_ssh') }
        it { is_expected.not_to contain_class('::gitlab::cirunner::parallels') }
        it { is_expected.not_to contain_class('::gitlab::cirunner::virtualbox') }
        it { is_expected.not_to contain_class('::gitlab::cirunner::kubernetes') }
      end
      describe 'Change Defaults' do
        context 'concurrent' do
          before { params.merge!(concurrent: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file_line('gitlab-runner-concurrent').with(
              path: '/etc/gitlab-runner/config.toml',
              line: 'concurrent = 42',
              match: '^concurrent = \d+',
              require: 'Package[gitlab-runner]',
              notify: 'Exec[gitlab-runner-restart]'
            )
          end
        end
        context 'manage_repo' do
          before { params.merge!(manage_repo: false) }
          it { is_expected.to compile }
          it { is_expected.not_to contain_class('apt') }
          it { is_expected.not_to contain_apt__source('apt_gitlabci') }
          it { is_expected.not_to contain_package('apt-transport-https') }
          it do
            is_expected.not_to contain_yumrepo('runner_gitlab-runner')
          end
          it do
            is_expected.not_to contain_yumrepo(
              'runner_gitlab-runner-source'
            )
          end
        end
        context 'conf_file' do
          before { params.merge!(conf_file: '/foo/bar', concurrent: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file_line('gitlab-runner-concurrent').with(
              path: '/foo/bar',
              line: 'concurrent = 42',
              match: '^concurrent = \d+',
              require: 'Package[gitlab-runner]',
              notify: 'Exec[gitlab-runner-restart]'
            )
          end
        end
        context 'package_ensure' do
          before { params.merge!(package_ensure: 'absent') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_package('gitlab-runner').with_ensure(
              'absent'
            )
          end
        end
      end
      describe 'check bad type' do
        context 'concurrent' do
          before { params.merge!(concurrent: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'manage_repo' do
          before { params.merge!(manage_repo: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'conf_file' do
          before { params.merge!(conf_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'package_ensure' do
          before { params.merge!(package_ensure: 'foobar') }
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
        context 'docker_runners' do
          before { params.merge!(docker_runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'shell_runners' do
          before { params.merge!(shell_runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ssh_runners' do
          before { params.merge!(ssh_runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'docker_ssh_runners' do
          before { params.merge!(docker_ssh_runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'parallels_runners' do
          before { params.merge!(parallels_runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'virtualbox_runners' do
          before { params.merge!(virtualbox_runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'kubernetes_runners' do
          before { params.merge!(kubernetes_runners: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
