require 'spec_helper'

describe 'gitlab' do
  context 'supported operating systems' do
    describe "gitlab class without any parameters on Debian (Jessie)" do
      let(:params) {{ }}
      let(:facts) {{
        :gitlab_systemd  => false,
        :osfamily => 'debian',
        :lsbdistid => 'debian',
        :lsbdistcodename => 'jessie',
        :operatingsystem => 'Debian',
      }}

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('gitlab::params') }
      it { is_expected.to contain_class('gitlab::install').that_comes_before('Class[gitlab::config]') }
      it { is_expected.to contain_class('gitlab::config') }
      it { is_expected.to contain_class('gitlab::service').that_subscribes_to('Class[gitlab::config]') }
      it { is_expected.to contain_apt__source('gitlab_official_ce') }
      it { is_expected.to contain_exec('gitlab_reconfigure') }
      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') }

      it { is_expected.to contain_service('gitlab-runsvdir') }
      it { is_expected.to contain_package('gitlab-ce').with_ensure('installed') }
      it { is_expected.to contain_class('gitlab') }
    end
    describe "gitlab class without any parameters on RedHat (CentOS)" do
      let(:params) {{ }}
      let(:facts) {{
        :gitlab_systemd  => false,
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

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('gitlab::params') }
      it { is_expected.to contain_class('gitlab::install').that_comes_before('Class[gitlab::config]') }
      it { is_expected.to contain_class('gitlab::config') }
      it { is_expected.to contain_class('gitlab::service').that_subscribes_to('Class[gitlab::config]') }
      it { is_expected.to contain_yumrepo('gitlab_official_ce') }

      it { is_expected.to contain_service('gitlab-runsvdir') }
      it { is_expected.to contain_package('gitlab-ce').with_ensure('installed') }
    end
  end

  context 'unsupported operating system' do
    describe 'gitlab class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :gitlab_systemd  => false,
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('gitlab') }.to raise_error(Puppet::Error, /OS family Solaris not supported/) }
    end
  end

  context 'linking init script on non-systemd' do
    describe 'gitlab class on a non-systemd machine' do
      let(:facts) {{
        :gitlab_systemd => false,
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

      it { is_expected.to contain_file('/etc/init.d/gitlab-runsvdir').with_ensure('link') }
    end

    describe 'gitlab class on a systemd machine' do
      let(:facts) {{
        :gitlab_systemd => true,
        :osfamily => 'redhat',
        :operatingsystem => 'CentOS',
        :operatingsystemmajrelease => '6',
        :os              => {
          :architecture => "x86_64",
          :family => "RedHat",
          :hardware => "x86_64",
          :name => "CentOS",
          :release => {
            :full => "7.2",
            :major => "7",
            :minor => "2"
          },
          :selinux => {
            :enabled => false
          }
        },
      }}

      it { is_expected.to contain_file('/etc/init.d/gitlab-runsvdir').with_ensure('absent') }
    end
  end

  context 'gitlab specific parameters' do
    let(:facts) {{
      :gitlab_systemd  => false,
      :osfamily => 'debian',
      :lsbdistid => 'debian',
      :lsbdistcodename => 'jessie',
      :operatingsystem => 'Debian',
    }}

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
    describe 'external_port' do
      let(:params) { {:external_port => 987654} }
      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*external_port '987654'$/)
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
        .with_content(/^\s*nginx\['listen_port'\] = ('|)80('|)$/)
      }
    end
    describe 'secrets' do
      let(:params) { {:secrets => {
        'gitlab_shell' => {
          'secret_token' => 'mysupersecrettoken1',
        },
        'gitlab_rails' => {
          'secret_token' => 'mysupersecrettoken2',
        },
        'gitlab_ci' => {
          'secret_token' => 'null',
          'secret_key_base' => 'mysupersecrettoken3',
          'db_key_base' => 'mysupersecrettoken4',
        },
      }}}
      it { is_expected.to contain_file('/etc/gitlab/gitlab-secrets.json') \
        .with_content(/{\n  \"gitlab_shell\": {\n    \"secret_token\": \"mysupersecrettoken1\"\n  },\n  \"gitlab_rails\": {\n    \"secret_token\": \"mysupersecrettoken2\"\n  },\n  \"gitlab_ci\": {\n    \"secret_token\": \"null\",\n    \"secret_key_base\": \"mysupersecrettoken3\",\n    \"db_key_base\": \"mysupersecrettoken4\"\n  }\n}\n/m)
      }
    end
    describe 'gitlab_rails with hash value' do
      let(:params) { {:gitlab_rails => {
        'ldap_enabled' => true,
        'ldap_servers' => {
          'main' => {
            'label' => 'LDAP',
            'host' => '_your_ldap_server',
            'port' => 389,
            'uid' => 'sAMAccountName',
            'method' => 'plain',
            'bind_dn' => '_the_full_dn_of_the_user_you_will_bind_with',
            'password' => '_the_password_of_the_bind_user',
            'active_directory' => true,
            'allow_username_or_email_login' => false,
            'block_auto_created_users' => false,
            'base' => '',
            'user_filter' => '',
          }
        },
        'omniauth_providers' => [
          {
            'name' => 'google_oauth2',
            'app_id' => 'YOUR APP ID',
            'app_secret' => 'YOUR APP SECRET',
            'args' => { 'access_type' => 'offline', 'approval_prompt' => '' }
          }
        ]
      }}}

      let(:expected_content){ {
        :gitlab_rb__ldap_servers => %Q{gitlab_rails['ldap_servers'] = {\"main\"=>{\"active_directory\"=>true, \"allow_username_or_email_login\"=>false, \"base\"=>\"\", \"bind_dn\"=>\"_the_full_dn_of_the_user_you_will_bind_with\", \"block_auto_created_users\"=>false, \"host\"=>\"_your_ldap_server\", \"label\"=>\"LDAP\", \"method\"=>\"plain\", \"password\"=>\"_the_password_of_the_bind_user\", \"port\"=>389, \"uid\"=>\"sAMAccountName\", \"user_filter\"=>\"\"}}\n}
      }}

      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*gitlab_rails\['ldap_enabled'\] = true$/)
        .with_content( /\s*#{Regexp.quote(expected_content[:gitlab_rb__ldap_servers])}/m )
        .with_content(/^\s*gitlab_rails\['omniauth_providers'\] = \[{\"app_id\"=>\"YOUR APP ID\", \"app_secret\"=>\"YOUR APP SECRET\", \"args\"=>{\"access_type\"=>\"offline\", \"approval_prompt\"=>\"\"}, \"name\"=>\"google_oauth2\"}\]$/)
      }
    end
    describe 'gitlab_git_http_server with hash value' do
      let(:params) {{:gitlab_git_http_server => {
        'enable' => true,
      }}}

      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*gitlab_git_http_server\['enable'\] = true$/)
      }
    end
    describe 'gitlab_rails with string value' do
      let(:params) {{:gitlab_rails => {
        'backup_path' => '/opt/gitlab_backup',
      }}}

      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*gitlab_rails\['backup_path'\] = "\/opt\/gitlab_backup"$/)
      }
    end
    describe 'rack_attack_git_basic_auth with Numbers and Strings' do
      let(:params) {{
         :gitlab_rails => {
           'rack_attack_git_basic_auth' => {
             'enable' => true,
             'ip_whitelist' => ["127.0.0.1", "10.0.0.0"],
             'maxretry' => 10,
             'findtime' => 60,
             'bantime' => 3600,
           },
         },
       }}

       it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
         .with_content(/^\s*gitlab_rails\['rack_attack_git_basic_auth'\] = {\"bantime\"=>3600, \"enable\"=>true, \"findtime\"=>60, \"ip_whitelist\"=>\[\"127.0.0.1\", \"10.0.0.0\"\], \"maxretry\"=>10}$/)
       }
    end
    describe 'mattermost external URL' do
      let(:params) {{:mattermost_external_url => 'https://mattermost.myserver.tld' }}

      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*mattermost_external_url 'https:\/\/mattermost\.myserver\.tld'$/)
      }
    end
    describe 'mattermost with hash value' do
      let(:params) {{:mattermost => {
        'enable' => true,
      }}}

      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*mattermost\['enable'\] = true$/)
      }
    end
    describe 'prometheus with hash value' do
      let(:params) {{:prometheus => {
        'enable' => true,
      }}}

      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*prometheus\['enable'\] = true$/)
      }
    end
    describe 'prometheus with hash value change listen address' do
      let(:params) {{:prometheus => {
        'listen_address' => 'localhost:9091',
      }}}

      it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') \
        .with_content(/^\s*prometheus\['listen_address'\] = 'localhost:9091'$/)
      }
    end
    describe 'with manage_package => false' do
      let(:params) {{:manage_package => false }}

      it { should_not contain_package('gitlab-ce') }
      it { should_not contain_package('gitlab-ee') }
    end
  end
end
