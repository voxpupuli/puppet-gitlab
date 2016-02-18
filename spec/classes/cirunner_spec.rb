require 'spec_helper'

describe 'gitlab::cirunner' do
  context 'supported operating systems' do
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

      it { is_expected.to contain_package('gitlab-ci-multi-runner').with_ensure('present') }
    end
    describe "gitlab class without any parameters on RedHat (CentOS)" do
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
      }}

      it { expect { is_expected.to contain_package('gitlab') }.to raise_error(Puppet::Error, /OS family redhat is not supported. Only Debian is suppported./) }
    end
  end

end
