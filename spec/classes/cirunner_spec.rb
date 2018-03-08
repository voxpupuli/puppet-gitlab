require 'spec_helper'

describe 'gitlab::cirunner' do
  package_name = 'gitlab-runner'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('docker') }
      it { is_expected.to contain_class('docker::images') }
      it { is_expected.to contain_package(package_name).with_ensure('installed') }

      case facts[:osfamily]
      when 'RedHat'
        it { is_expected.to contain_yumrepo("runner_#{package_name}").with_baseurl("https://packages.gitlab.com/runner/#{package_name}/el/$releasever/$basearch") }
      when 'Debian'
        it { is_expected.to contain_apt__source('apt_gitlabci') }
      end

      it { is_expected.to contain_exec('gitlab-runner-restart').that_requires("Package[#{package_name}]") }
      it do
        is_expected.to contain_exec('gitlab-runner-restart').with('command' => "/usr/bin/#{package_name} restart",
                                                                  'refreshonly' => true)
      end
      it { is_expected.to contain_gitlab__runner('test_runner').that_requires('Exec[gitlab-runner-restart]') }
      it { is_expected.not_to contain_file_line('gitlab-runner-concurrent') }
      it { is_expected.not_to contain_file_line('gitlab-runner-metrics-server') }
    end

    context "on #{os} with concurrent => 10" do
      let(:facts) do
        facts
      end

      let(:params) { { concurrent: 10 } }

      it { is_expected.to contain_file_line('gitlab-runner-concurrent').that_requires("Package[#{package_name}]") }
      it { is_expected.to contain_file_line('gitlab-runner-concurrent').that_notifies('Exec[gitlab-runner-restart]') }
      it do
        is_expected.to contain_file_line('gitlab-runner-concurrent').with('path' => '/etc/gitlab-runner/config.toml',
                                                                          'line'  => 'concurrent = 10',
                                                                          'match' => '^concurrent = \d+')
      end
    end

    context "on #{os} with metrics_server => localhost:9252" do
      let(:facts) do
        facts
      end

      let(:params) { { metrics_server: 'localhost:9252' } }

      it { is_expected.to contain_file_line('gitlab-runner-metrics-server').that_requires("Package[#{package_name}]") }
      it { is_expected.to contain_file_line('gitlab-runner-metrics-server').that_notifies('Exec[gitlab-runner-restart]') }
      it do
        is_expected.to contain_file_line('gitlab-runner-metrics-server').with('path' => '/etc/gitlab-runner/config.toml',
                                                                              'line'  => 'metrics_server = "localhost:9252"',
                                                                              'match' => '^metrics_server = .+')
      end
    end
  end

  context 'unsupported operating systems' do
    describe 'gitlab::cirunner class without any parameters on unsupported OS' do
      let(:params) { {} }
      let(:facts) do
        {
          osfamily: 'unsupported_os_family'
        }
      end

      it 'fails' do
        expect do
          catalogue
        end.to raise_error(Puppet::Error, %r{OS family unsupported_os_family is not supported. Only Debian and Redhat is supported.})
      end
    end
  end
end
