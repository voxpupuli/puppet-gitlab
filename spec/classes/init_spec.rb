require 'spec_helper'

describe 'gitlab', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default params' do
        it { is_expected.to contain_class('gitlab::host_config').that_comes_before('Class[gitlab::install]') }
        it { is_expected.to contain_class('gitlab::omnibus_config').that_comes_before('Class[gitlab::install]') }
        it { is_expected.to contain_class('gitlab::install').that_comes_before('Class[gitlab::service]') }
        it { is_expected.to contain_class('gitlab::service').that_comes_before('Class[gitlab::initial_root_token]') }
        it { is_expected.to contain_class('gitlab::initial_root_token') }
        it { is_expected.to contain_file('/etc/gitlab/create_initial_root_token.rb').with_ensure('absent') }
        it { is_expected.not_to contain_exec('create_initial_root_token') }
        it { is_expected.to contain_exec('gitlab_reconfigure').that_subscribes_to('Class[gitlab::omnibus_config]') }
        it { is_expected.to contain_file('/etc/gitlab/gitlab.rb') }
        it { is_expected.to contain_package('gitlab-omnibus').with_ensure('installed').with_name('gitlab-ce') }
        it { is_expected.to contain_class('gitlab') }
        it { is_expected.not_to raise_error }

        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_apt__source('gitlab_official_ce').with_ensure('present').with_comment(%r{.}) }
          it { is_expected.to contain_apt__source('gitlab_official_ee').with_ensure('absent') }
          it { is_expected.to contain_class('apt::update').that_comes_before('Class[gitlab::install]') }
          it { is_expected.not_to contain_apt__source('gitlab_official_') }
          it { is_expected.not_to contain_yumrepo('gitlab_official_ce') }
          case facts[:operatingsystem]
          when 'Ubuntu'
            it { is_expected.to contain_apt__source('gitlab_official_ce').with_location('https://packages.gitlab.com/gitlab/gitlab-ce/ubuntu') }
            it { is_expected.to contain_apt__source('gitlab_official_ee').with_location('https://packages.gitlab.com/gitlab/gitlab-ee/ubuntu') }
          else
            it { is_expected.to contain_apt__source('gitlab_official_ce').with_location('https://packages.gitlab.com/gitlab/gitlab-ce/debian') }
            it { is_expected.to contain_apt__source('gitlab_official_ee').with_location('https://packages.gitlab.com/gitlab/gitlab-ee/debian') }
          end
        when 'RedHat'
          it { is_expected.to contain_yumrepo('gitlab_official_ce').with_ensure('present').with_enabled(1) }
          it { is_expected.to contain_yumrepo('gitlab_official_ce').without_baseurl(%r{/gitlab-/}) }
          it { is_expected.to contain_yumrepo('gitlab_official_ce').without_gpgkey(%r{/gitlab-/}) }
          it { is_expected.to contain_yumrepo('gitlab_official_ce').without_gpgkey('https://packages.gitlab.com/gpg.key') }
          it { is_expected.to contain_yumrepo('gitlab_official_ee').with_ensure('absent') }
          it { is_expected.not_to contain_yumrepo('gitlab_official_') }
          it { is_expected.not_to contain_apt__source('gitlab_official_ce') }
          it { is_expected.not_to contain_class('apt::update').that_comes_before('Class[gitlab::install]') }
        end
      end

      context 'with class specific parameters' do
        describe 'edition = ee' do
          let(:params) { { edition: 'ee' } }

          it { is_expected.to contain_package('gitlab-omnibus').with_ensure('installed').with_name('gitlab-ee') }

          case facts[:osfamily]
          when 'Debian'
            it { is_expected.to contain_apt__source('gitlab_official_ee').with_ensure('present') }
            it { is_expected.to contain_apt__source('gitlab_official_ce').with_ensure('absent')  }
            it { is_expected.to contain_class('apt::update').that_comes_before('Class[gitlab::install]') }
          when 'RedHat'
            it { is_expected.to contain_yumrepo('gitlab_official_ee').with_ensure('present') }
            it { is_expected.to contain_yumrepo('gitlab_official_ee').without_baseurl(%r{/gitlab-/}) }
            it { is_expected.to contain_yumrepo('gitlab_official_ee').without_gpgkey(%r{/gitlab-/}) }
            it { is_expected.to contain_yumrepo('gitlab_official_ee').without_gpgkey('https://packages.gitlab.com/gpg.key') }
            it { is_expected.to contain_yumrepo('gitlab_official_ce').with_ensure('absent') }
          end
        end
        describe 'service_manage' do
          let(:params) { { service_manage: true } }

          it {
            is_expected.to contain_service('gitlab-runsvdir').without_notify
          }
        end
        describe 'service_provider_restart' do
          let(:params) do
            { service_manage: true,
              service_provider_restart: true }
          end

          it {
            is_expected.to contain_exec('gitlab_reconfigure'). \
              that_notifies('Service[gitlab-runsvdir]')
          }
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
        describe 'alertmanager' do
          let(:params) do
            { alertmanager: {
              'enable' => true,
              'flags' => { 'cluster.advertise-address' => '127.0.0.1:9093' }
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*alertmanager\['enable'\] = true$}).
              with_content(%r{^\s*alertmanager\['flags'\] = {\"cluster.advertise-address\"=>\"127.0.0.1:9093\"}$})
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
        describe 'package' do
          let(:params) do
            { package: {
              'systemd_after' => 'foo.target',
              'systemd_wanted_by' => 'bar.target',
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*package\['systemd_after'\] = "foo.target"$}).
              with_content(%r{^\s*package\['systemd_wanted_by'\] = "bar.target"$})
          }
        end
        describe 'consul' do
          let(:params) do
            { consul: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*consul\['enable'\] = true$})
          }
        end
        describe 'pgbouncer' do
          let(:params) do
            { pgbouncer: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*pgbouncer\['enable'\] = true$})
          }
        end
        describe 'praefect' do
          let(:params) do
            {
              praefect: {
                'enable' => true,
                'listen_addr' => '0.0.0.0:2305',
                'virtual_storage' => {
                  'default' => {
                    'host01' => { 'address' => 'tcp://host01:8075', 'token' => 'xxx-xxx-xxx' },
                    'host02' => { 'address' => 'tcp://host02:8075', 'token' => 'xxx-xxx-xxx' },
                  }
                }
              }
            }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*praefect\['enable'\] = true$})
          }
          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*praefect\['listen_addr'\] = "0\.0\.0\.0:2305"$})
          }
          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*praefect\['virtual_storage'\] = \{"default"=>\{"host01"=>\{"address"=>"tcp://host01:8075", "token"=>"xxx-xxx-xxx"\}, "host02"=>\{"address"=>"tcp://host02:8075", "token"=>"xxx-xxx-xxx"\}\}\}$})
          }
        end
        describe 'repmgr' do
          let(:params) do
            { repmgr: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*repmgr\['enable'\] = true$})
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
        describe 'skip_post_deployment_migrations' do
          let(:params) do
            { skip_post_deployment_migrations: true }
          end

          it {
            is_expected.to contain_exec('gitlab_reconfigure').with_environment(['SKIP_POST_DEPLOYMENT_MIGRATIONS=true'])
          }
        end
        context 'managing pgpass_file' do
          describe 'with defaults' do
            it { is_expected.to contain_file('/home/gitlab-consul/.pgpass').with_ensure('absent') }
          end
          context "with pgpass_file_ensure => 'present'" do
            let(:params) do
              { pgpass_file_ensure: 'present' }
            end

            describe 'without a password for pgbouncer_password' do
              it { is_expected.to raise_error(%r{A password must be provided to pgbouncer_password}) }
            end
            describe 'with a password for pgbouncer_password' do
              let(:params) do
                super().merge('pgbouncer_password' => 'PAsswd')
              end

              it {
                is_expected.to contain_file('/home/gitlab-consul/.pgpass').with(
                  'ensure' => 'present',
                  'path' => '/home/gitlab-consul/.pgpass',
                  'owner' => 'gitlab-consul',
                  'group' => 'gitlab-consul'
                ).with_content(
                  %r{^127.0.0.1:\*:pgbouncer:pgbouncer:PAsswd}
                )
              }
            end
          end
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
              gitlab_rb__ldap_servers: %(gitlab_rails['ldap_servers'] = {"main"=>{"active_directory"=>true, "allow_username_or_email_login"=>false, "base"=>"", "bind_dn"=>"_the_full_dn_of_the_user_you_will_bind_with", "block_auto_created_users"=>false, "host"=>"_your_ldap_server", "label"=>"LDAP", "method"=>"plain", "password"=>"_the_password_of_the_bind_user", "port"=>389, "uid"=>"sAMAccountName", "user_filter"=>""}}\n)
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
        describe 'with roles' do
          let(:params) do
            {
              'roles' => %w[redis_sentinel_role redis_master_role]
            }
          end

          let(:expected_content) do
            {
              roles: %(roles ["redis_sentinel_role", "redis_master_role"])
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
              datadirs: %(git_data_dirs({"default"=>{"path"=>"/git-data/data"}})\n)
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
        describe 'gitlab_monitor' do
          let(:params) do
            { gitlab_monitor: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*gitlab_monitor\['enable'\] = true$})
          }
          it {
            is_expected.to contain_notify("DEPRECTATION: 'gitlab_monitor' is deprecated if using GitLab 12.3 or greater. Set 'gitlab_exporter' instead")
          }
        end
        describe 'gitlab_exporter' do
          let(:params) do
            { gitlab_exporter: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*gitlab_exporter\['enable'\] = true$})
          }
        end
        describe 'puma' do
          let(:params) do
            { puma: {
              'enable' => true,
              'worker_processes' => 3,
              'worker_timeout' => 60
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb').
              with_content(%r{^\s*puma\['enable'\] = true$}).
              with_content(%r{^\s*puma\['worker_processes'\] = 3$}).
              with_content(%r{^\s*puma\['worker_timeout'\] = 60$})
          }
        end
        describe 'pgbouncer_exporter' do
          let(:params) do
            { pgbouncer_exporter: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*pgbouncer_exporter\['enable'\] = true$})
          }
        end
        describe 'geo_logcursor' do
          let(:params) do
            { geo_logcursor: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*geo_logcursor\['enable'\] = true$})
          }
        end
        describe 'gitlab_sshd' do
          let(:params) do
            { gitlab_sshd: {
              'enable' => true
            } }
          end

          it {
            is_expected.to contain_file('/etc/gitlab/gitlab.rb'). \
              with_content(%r{^\s*gitlab_sshd\['enable'\] = true$})
          }
        end
        describe 'package_hold' do
          let(:params) do
            { package_ensure: '16.10.3-ce.0', package_hold: 'hold' }
          end

          it {
            is_expected.to contain_package('gitlab-omnibus').with('ensure' => '16.10.3-ce.0', 'name' => 'gitlab-ce', 'mark' => 'hold')
          }
        end
        describe 'create_intial_root_token' do
          let(:params) { { create_initial_root_token: true } }

          it do
            is_expected.to contain_file('/etc/gitlab/create_initial_root_token.rb').
              with_content(%r{^token_value = 'glpat-' \+ SecureRandom.alphanumeric\(20\)$}).
              with_content(%r{^token_ttl_minutes = 60$}).
              with_content(%r{^token_file_path = '/etc/gitlab/initial_root_token'$})
          end
          it { is_expected.to contain_exec('create_initial_root_token').with_creates('/etc/gitlab/initial_root_token') }

          describe 'initial_root_token' do
            let(:params) { super().merge(initial_root_token: sensitive('foobarbaz')) }

            it { is_expected.to contain_file('/etc/gitlab/create_initial_root_token.rb').with_content(%r{^token_value = 'foobarbaz'$}) }
          end

          describe 'initial_root_token_ttl_minutes' do
            let(:params) { super().merge(initial_root_token_ttl_minutes: 123) }

            it { is_expected.to contain_file('/etc/gitlab/create_initial_root_token.rb').with_content(%r{^token_ttl_minutes = 123$}) }
          end
        end
      end
    end
  end

  context 'on usupported os' do
    let(:facts) do
      {
        'os' => {
          'family' => 'Solaris'
        }
      }
    end

    describe 'gitlab class without any parameters on Solaris/Nexenta' do
      it { is_expected.not_to compile }
    end
  end
end
