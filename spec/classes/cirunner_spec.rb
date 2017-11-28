require 'spec_helper'

describe 'gitlab::cirunner' do
  context 'supported operating systems' do
    package_name = 'gitlab-runner'

    describe "gitlab::cirunner class without any parameters on Ubuntu Trusty" do
      let(:params) {{ }}
      let(:facts) {{
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Debian',
        :operatingsystemmajrelease => 'jessie/sid',
        :kernelrelease => '3.13.0-71-generic',
      }}

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('docker') }
      it { is_expected.to contain_class('docker::images') }
      it { is_expected.to contain_apt__source('apt_gitlabci') }

      it { is_expected.to contain_package(package_name).with_ensure('installed') }
    end
    describe "gitlab::cirunner class without any parameters on RedHat (CentOS)" do
      let(:params) {{ }}
      let(:facts) {{
        :osfamily => 'redhat',
        :operatingsystem => 'CentOS',
        :operatingsystemmajrelease => '6',
        :os              => {
          :architecture => "x86_64",
          :family => "RedHat",
          :hardware => "x86_64",
          :name => "CentOS",
          :release => {
            :full => "6.7",
            :major => "6",
            :minor => "7"
          },
          :selinux => {
            :enabled => false
          }
        },
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '6',
        :operatingsystemrelease => '6.5',
        :kernelversion => '2.6.32',
        :kernelrelease => '2.6.32-573.8.1.el6.x86_64'
      }}

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('docker') }
      it { is_expected.to contain_class('docker::images') }
      it { is_expected.to contain_yumrepo("runner_#{package_name}").with_baseurl("https://packages.gitlab.com/runner/#{package_name}/el/6/$basearch") }

      it { is_expected.to contain_package(package_name).with_ensure('installed') }
    end
    describe "gitlab::cirunner class OS-independent behavior" do
      let(:facts) {{
        :osfamily => 'redhat',
        :operatingsystem => 'CentOS',
        :operatingsystemmajrelease => '6',
        :os              => {
          :architecture => "x86_64",
          :family => "RedHat",
          :hardware => "x86_64",
          :name => "CentOS",
          :release => {
            :full => "6.7",
            :major => "6",
            :minor => "7"
          },
          :selinux => {
            :enabled => false
          }
        },
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '6',
        :operatingsystemrelease => '6.5',
        :kernelversion => '2.6.32',
        :kernelrelease => '2.6.32-573.8.1.el6.x86_64'
      }}

      context 'with default parameters' do
        it { should contain_exec('gitlab-runner-restart').that_requires("Package[#{package_name}]") }
        it do
          should contain_exec('gitlab-runner-restart').with({
            'command'     => "/usr/bin/#{package_name} restart",
            'refreshonly' => true,
          })
        end
        it { should contain_gitlab__runner('test_runner').that_requires('Exec[gitlab-runner-restart]') }
        it { should_not contain_file_line('gitlab-runner-concurrent') }
        it { should_not contain_file_line('gitlab-runner-metrics-server') }
      end

      context 'with concurrent => 10' do
        let(:params) { { :concurrent => 10 } }
        it { should contain_file_line('gitlab-runner-concurrent').that_requires("Package[#{package_name}]") }
        it { should contain_file_line('gitlab-runner-concurrent').that_notifies('Exec[gitlab-runner-restart]') }
        it do
          should contain_file_line('gitlab-runner-concurrent').with({
            'path'  => '/etc/gitlab-runner/config.toml',
            'line'  => 'concurrent = 10',
            'match' => '^concurrent = \d+',
          })
        end
      end

      context 'with metrics_server => localhost:9252' do
        let(:params) { { :metrics_server => 'localhost:9252' } }
        it { should contain_file_line('gitlab-runner-metrics-server').that_requires("Package[#{package_name}]") }
        it { should contain_file_line('gitlab-runner-metrics-server').that_notifies('Exec[gitlab-runner-restart]') }
        it do
          should contain_file_line('gitlab-runner-metrics-server').with({
            'path'  => '/etc/gitlab-runner/config.toml',
            'line'  => 'metrics_server = "localhost:9252"',
	    'match' => '^metrics_server = .+',
          })
        end
      end
    end
  end
  context 'unsupported operating systems' do
    describe "gitlab::cirunner class without any parameters on unsupported OS" do
      let(:params) {{ }}
      let(:facts) {{
         :osfamily => 'unsupported_os_family',
      }}
      it "should fail" do
        expect do
          catalogue
        end.to raise_error(Puppet::Error, /OS family unsupported_os_family is not supported. Only Debian and Redhat is suppported./)
      end
    end
  end

end
