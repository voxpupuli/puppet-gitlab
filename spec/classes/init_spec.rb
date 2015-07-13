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

  context 'gitlab specific parameters' do
    let(:facts) {{
      :osfamily => 'debian',
      :lsbdistid => 'debian',
      :lsbdistcodename => 'jessie',
    }}
    it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') }
    describe 'edition = ce' do
      let(:params) { {:edition => 'ce'} }
      it { is_expected.to contain_package('gitlab-ce').with_ensure('installed') }
    end
    describe 'edition = ee' do
      let(:params) { {:edition => 'ee'} }
      it { is_expected.to contain_package('gitlab-ee').with_ensure('installed') }
    end
    describe 'external_url' do
      let(:params) { {:external_url => 'http://gitlab.mycompany.com/'} }
      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*external_url 'http:\/\/gitlab\.mycompany\.com\/'$/)
      }
    end
    describe 'ci_external_url' do
      let(:params) { {:ci_external_url => 'http://gitlabci.mycompany.com/'} }
      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*ci_external_url 'http:\/\/gitlabci\.mycompany\.com\/'$/)
      }
    end
    describe 'nginx' do
      let(:params) { {:nginx => {
        'enable' => true,
        'listen_port' => 80,
        }
      }}
      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*nginx\['enable'\] = true$/)
        .with_content(/^\s*nginx\['listen_port'\] = '80'$/)
      }
      describe 'and ci_nginx_eq_nginx = true' do
        let(:params) { {:nginx => {
          'enable' => true,
          'listen_port' => 80,
          },
          :ci_nginx_eq_nginx => true,
        }}
        it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
          .with_content(/^\s*nginx\['enable'\] = true$/)
          .with_content(/^\s*nginx\['listen_port'\] = '80'$/)
          .with_content(/^\s*ci_nginx\['enable'\] = true$/)
          .with_content(/^\s*ci_nginx\['listen_port'\] = '80'$/)
        }
      end
    end
  end
end
