# == Class gitlab::config
#
# This class is called from gitlab for service config.
#
class gitlab::config {

  # get variables from the toplevel manifest for usage in the template
  $ci_external_url = $::gitlab::ci_external_url
  $ci_nginx = $::gitlab::ci_nginx
  $ci_nginx_eq_nginx = $::gitlab::ci_nginx_eq_nginx
  $ci_redis = $::gitlab::ci_redis
  $ci_unicorn = $::gitlab::ci_unicorn
  $config_file = $::gitlab::config_file
  $external_url = $::gitlab::external_url
  $git = $::gitlab::git
  $git_data_dir = $::gitlab::git_data_dir
  $gitlab_git_http_server = $::gitlab::gitlab_git_http_server
  $gitlab_ci = $::gitlab::gitlab_ci
  $gitlab_rails = $::gitlab::gitlab_rails
  $high_availability = $::gitlab::high_availability
  $logging = $::gitlab::logging
  $logrotate = $::gitlab::logrotate
  $manage_accounts = $::gitlab::manage_accounts
  $mattermost = $::gitlab::mattermost
  $mattermost_external_url = $::gitlab::mattermost_external_url
  $mattermost_nginx = $::gitlab::mattermost_nginx
  $mattermost_nginx_eq_nginx = $::gitlab::mattermost_nginx_eq_nginx
  $nginx = $::gitlab::nginx
  $postgresql = $::gitlab::postgresql
  $redis = $::gitlab::redis
  $secrets = $::gitlab::secrets
  $secrets_file = $::gitlab::secrets_file
  $service_group = $::gitlab::service_group
  $service_manage = $::gitlab::service_manage
  $service_user = $::gitlab::service_user
  $shell = $::gitlab::shell
  $sidekiq = $::gitlab::sidekiq
  $unicorn = $::gitlab::unicorn
  $gitlab_workhorse = $::gitlab::gitlab_workhorse
  $user = $::gitlab::user
  $web_server = $::gitlab::web_server

  # replicate $nginx to $ci_nginx if $ci_nginx_eq_nginx true
  if $ci_nginx_eq_nginx {
    $_real_ci_nginx = $nginx
  } else {
    $_real_ci_nginx = $ci_nginx
  }

  # replicate $nginx to $mattermost_nginx if $mattermost_nginx_eq_nginx true
  if $mattermost_nginx_eq_nginx {
    $_real_mattermost_nginx = $nginx
  } else {
    $_real_mattermost_nginx = $mattermost_nginx
  }

  file { $config_file:
      ensure  => file,
      owner   => $service_user,
      group   => $service_group,
      mode    => '0600',
      content => template('gitlab/gitlab.rb.erb');
  }

  if ! empty($secrets) {
    file { $secrets_file:
        ensure  => file,
        owner   => $service_user,
        group   => $service_group,
        mode    => '0600',
        content => inline_template('<%= require \'json\'; JSON.pretty_generate(@secrets) + "\n" %>'),
    }
  }

  if $service_manage {
    # configure gitlab using the official tool
    File[$config_file] {
      notify => Exec['gitlab_reconfigure']
    }
    if ! empty($secrets) {
      File[$secrets_file] {
        notify => Exec['gitlab_reconfigure']
      }
    }
    exec { 'gitlab_reconfigure':
      command     => '/usr/bin/gitlab-ctl reconfigure',
      refreshonly => true,
      timeout     => 1800,
      logoutput   => true,
      tries       => 5,
    }

    if is_hash($postgresql) {
      unless $postgresql[enable] {
        exec { 'gitlab_setup':
          command     => '/bin/echo yes | /usr/bin/gitlab-rake gitlab:setup',
          refreshonly => true,
          timeout     => 1800,
          require     => Exec['gitlab_reconfigure'],
          unless      => "/bin/grep complete ${git_data_dir}/postgresql.setup"
        }
        ->
        file { "${git_data_dir}/postgresql.setup":
          content => 'complete'
        }
      }
    }
  }

}
