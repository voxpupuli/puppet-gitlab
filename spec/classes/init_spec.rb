require 'spec_helper'

describe 'gitlab', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default params' do
        it { is_expected.to contain_class('gitlab::params') }
        it { is_expected.to contain_class('gitlab::install').that_comes_before('Class[gitlab::config]') }
        it { is_expected.to contain_class('gitlab::config') }
        it { is_expected.to contain_class('gitlab::service').that_subscribes_to('Class[gitlab::config]') }
        it { is_expected.to contain_exec('gitlab_reconfigure') }
        it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') }
        it { is_expected.to contain_service('gitlab-runsvdir') }
        it { is_expected.to contain_package('gitlab-ce').with_ensure('installed') }
        it { is_expected.to contain_class('gitlab') }

        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_apt__source('gitlab_official_ce') }
        when 'RedHat'
          it { is_expected.to contain_yumrepo('gitlab_official_ce') }
        end
      end

      context 'with class specific parameters' do
        describe 'edition = ee' do
          let(:params) { { edition: 'ee' } }

          it { is_expected.to contain_package('gitlab-ee').with_ensure('installed') }

          case facts[:osfamily]
          when 'Debian'
            it { is_expected.to contain_apt__source('gitlab_official_ee') }
          when 'RedHat'
            it { is_expected.to contain_yumrepo('gitlab_official_ee') }
          end
        end
        describe 'external_url' do
          let(:params) { { external_url: 'http://gitlab.mycompany.com/' } }

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*external_url 'http:\/\/gitlab\.mycompany\.com\/'$})
          }
        end
        describe 'external_port' do
          let(:params) { { external_port: 9654 } }

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*external_port '9654'$})
          }
        end
        describe 'nginx' do
          let(:params) do
            { nginx: {
              'enable' => true,
              'listen_port' => 80
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*nginx\['enable'\] = true$}).
              with_content(%r{^\s*nginx\['listen_port'\] = ('|)80('|)$})
          }
        end
        describe 'letsencrypt' do
          let(:params) do
            { letsencrypt: {
              'enable' => true,
              'contact_emails' => ['test@example.com']
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*letsencrypt\['enable'\] = true$}).
              with_content(%r{^\s*letsencrypt\['contact_emails'\] = \["test@example.com"\]$})
          }
        end
        describe 'skip_auto_reconfigure' do
          let(:params) { { skip_auto_reconfigure: 'present' } }

          it {
              is_expected.to contain_file('/etc/gitlab/skip-auto-reconfigure').with(
                'ensure' => 'present',
                'owner' => 'root',
                'group' => 'root',
                'mode' => '0644'
              )
          }
        end
        describe 'secrets' do
          let(:params) do
            { secrets: {
              'gitlab_shell' => {
                'secret_token' => 'mysupersecrettoken1'
              },
              'gitlab_rails' => {
                'secret_token' => 'mysupersecrettoken2'
              },
              'gitlab_ci' => {
                'secret_token' => 'null',
                'secret_key_base' => 'mysupersecrettoken3',
                'db_key_base' => 'mysupersecrettoken4'
              }
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab-secrets.json'). \
              with_content(%r{{\n  \"gitlab_shell\": {\n    \"secret_token\": \"mysupersecrettoken1\"\n  },\n  \"gitlab_rails\": {\n    \"secret_token\": \"mysupersecrettoken2\"\n  },\n  \"gitlab_ci\": {\n    \"secret_token\": \"null\",\n    \"secret_key_base\": \"mysupersecrettoken3\",\n    \"db_key_base\": \"mysupersecrettoken4\"\n  }\n}\n}m)
          }
        end
        describe 'gitlab_rails with hash value' do
          let(:params) do
            { gitlab_rails: {
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
                  'user_filter' => ''
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
            } }
          end
          let(:expected_content) do
            {
              gitlab_rb__ldap_servers: %(gitlab_rails['ldap_servers'] = {\"main\"=>{\"active_directory\"=>true, \"allow_username_or_email_login\"=>false, \"base\"=>\"\", \"bind_dn\"=>\"_the_full_dn_of_the_user_you_will_bind_with\", \"block_auto_created_users\"=>false, \"host\"=>\"_your_ldap_server\", \"label\"=>\"LDAP\", \"method\"=>\"plain\", \"password\"=>\"_the_password_of_the_bind_user\", \"port\"=>389, \"uid\"=>\"sAMAccountName\", \"user_filter\"=>\"\"}}\n)
            }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*gitlab_rails\['ldap_enabled'\] = true$}).
              with_content(%r{\s*#{Regexp.quote(expected_content[:gitlab_rb__ldap_servers])}}m).
              with_content(%r{^\s*gitlab_rails\['omniauth_providers'\] = \[{\"app_id\"=>\"YOUR APP ID\", \"app_secret\"=>\"YOUR APP SECRET\", \"args\"=>{\"access_type\"=>\"offline\", \"approval_prompt\"=>\"\"}, \"name\"=>\"google_oauth2\"}\]$})
          }
        end
        describe 'gitlab_git_http_server with hash value' do
          let(:params) do
            { gitlab_git_http_server: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*gitlab_git_http_server\['enable'\] = true$})
          }
        end
        describe 'gitlab_rails with string value' do
          let(:params) do
            { gitlab_rails: {
              'backup_path' => '/opt/gitlab_backup'
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*gitlab_rails\['backup_path'\] = "\/opt\/gitlab_backup"$})
          }
        end
        describe 'rack_attack_git_basic_auth with Numbers and Strings' do
          let(:params) do
            {
              gitlab_rails: {
                'rack_attack_git_basic_auth' => {
                  'enable' => true,
                  'ip_whitelist' => ['127.0.0.1', '10.0.0.0'],
                  'maxretry' => 10,
                  'findtime' => 60,
                  'bantime' => 3600
                }
              }
            }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*gitlab_rails\['rack_attack_git_basic_auth'\] = {\"bantime\"=>3600, \"enable\"=>true, \"findtime\"=>60, \"ip_whitelist\"=>\[\"127.0.0.1\", \"10.0.0.0\"\], \"maxretry\"=>10}$})
          }
        end
        describe 'mattermost external URL' do
          let(:params) { { mattermost_external_url: 'https://mattermost.myserver.tld' } }

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*mattermost_external_url 'https:\/\/mattermost\.myserver\.tld'$})
          }
        end
        describe 'mattermost with hash value' do
          let(:params) do
            { mattermost: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*mattermost\['enable'\] = true$})
          }
        end
        describe 'with manage_package => false' do
          let(:params) { { manage_package: false } }

          it { is_expected.not_to contain_package('gitlab-ce') }
          it { is_expected.not_to contain_package('gitlab-ee') }
        end
        describe 'with roles' do
          let(:params) do
            {
              'roles' => %w[redis_sentinel_role redis_master_role]
            }
          end

          let(:expected_content) do
            {
              roles: %(roles [\"redis_sentinel_role\", \"redis_master_role\"])
            }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb').
              with_content(%r{\s*#{Regexp.quote(expected_content[:roles])}}m)
          }
        end
        describe 'with data_dirs' do
          let(:params) do
            {
              'git_data_dirs' => {
                'default' => {
                  'path' => '/git-data/data'
                }
              }
            }
          end
          let(:expected_content) do
            {
              datadirs: %(git_data_dirs({\"default\"=>{\"path\"=>\"/git-data/data\"}})\n)
            }
          end

          it do
            is_expected.to contain_file('/etc/gitlab/gitlab.rb').
              with_content(%r{\s*#{Regexp.quote(expected_content[:datadirs])}}m)
          end
        end
        describe 'with store_git_keys_in_db' do
          let(:params) { { store_git_keys_in_db: true } }

          it do
            is_expected.to contain_file('/opt/gitlab-shell/authorized_keys')
          end
        end
      end
    end
  end

  context 'on usupported os' do
    let(:facts) do
      {
        osfamily: 'Solaris',
        operatingsystem: 'Nexenta'
      }
    end

    describe 'gitlab class without any parameters on Solaris/Nexenta' do
      it { is_expected.to compile.and_raise_error(%r{is not supported}) }
    end
  end
end
