require 'spec_helper'

describe 'gitlab' do
  context 'supported operating systems' do
    describe "gitlab class without any parameters on Debian (Jessie)" do
      let(:params) {{ }}
      let(:facts) {{
        :osfamily => 'debian',
        :lsbdistid => 'debian',
        :lsbdistcodename => 'jessie',
      }}

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('gitlab::params') }
      it { is_expected.to contain_class('gitlab::install').that_comes_before('gitlab::config') }
      it { is_expected.to contain_class('gitlab::config') }
      it { is_expected.to contain_class('gitlab::service').that_subscribes_to('gitlab::config') }
      it { is_expected.to contain_apt__source('gitlab_official') }
      it { is_expected.to contain_exec('gitlab_reconfigure') }
      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') }

      it { is_expected.to contain_service('gitlab-runsvdir') }
      it { is_expected.to contain_package('gitlab-ce').with_ensure('installed') }
      it { is_expected.to contain_class('gitlab') }
    end
    describe "gitlab class without any parameters on RedHat (CentOS)" do
      let(:params) {{ }}
      let(:facts) {{
        :osfamily => 'redhat',
      }}

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('gitlab::params') }
      it { is_expected.to contain_class('gitlab::install').that_comes_before('gitlab::config') }
      it { is_expected.to contain_class('gitlab::config') }
      it { is_expected.to contain_class('gitlab::service').that_subscribes_to('gitlab::config') }
      it { is_expected.to contain_yumrepo('gitlab_official') }

      it { is_expected.to contain_service('gitlab-runsvdir') }
      it { is_expected.to contain_package('gitlab-ce').with_ensure('installed') }
    end
  end

  context 'unsupported operating system' do
    describe 'gitlab class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('gitlab') }.to raise_error(Puppet::Error, /OS family Solaris not supported/) }
    end
  end
end
