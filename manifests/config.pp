# == Class gitlab::config
#
# This class is called from gitlab for service config.
#
class gitlab::config {

  # get variables from the toplevel manifest for usage in the template
  $ci_redis = $::gitlab::ci_redis
  $ci_unicorn = $::gitlab::ci_unicorn
  $config_manage = $::gitlab::config_manage
  $config_file = $::gitlab::config_file
  $external_url = $::gitlab::external_url
  $external_port = $::gitlab::external_port
  $git = $::gitlab::git
  $git_data_dir = $::gitlab::git_data_dir
  $gitlab_git_http_server = $::gitlab::gitlab_git_http_server
  $gitlab_ci = $::gitlab::gitlab_ci
  $gitlab_pages = $::gitlab::gitlab_pages
  $gitlab_rails = $::gitlab::gitlab_rails
  $high_availability = $::gitlab::high_availability
  $logging = $::gitlab::logging
  $logrotate = $::gitlab::logrotate
  $manage_storage_directories = $::gitlab::manage_storage_directories
  $manage_accounts = $::gitlab::manage_accounts
  $mattermost = $::gitlab::mattermost
  $mattermost_external_url = $::gitlab::mattermost_external_url
  $mattermost_nginx = $::gitlab::mattermost_nginx
  $mattermost_nginx_eq_nginx = $::gitlab::mattermost_nginx_eq_nginx
  $nginx = $::gitlab::nginx
  $node_exporter = $::gitlab::node_exporter
  $redis_exporter = $::gitlab::redis_exporter
  $postgres_exporter = $::gitlab::postgres_exporter
  $gitlab_monitor = $::gitlab::gitlab_monitor
  $pages_external_url = $::gitlab::pages_external_url
  $pages_nginx = $::gitlab::pages_nginx
  $pages_nginx_eq_nginx = $::gitlab::pages_nginx_eq_nginx
  $prometheus = $::gitlab::prometheus
  $postgresql = $::gitlab::postgresql
  $prometheus = $::gitlab::prometheus
  $redis = $::gitlab::redis
  $registry = $::gitlab::registry
  $registry_nginx = $::gitlab::registry_nginx
  $registry_nginx_eq_nginx = $::gitlab::registry_nginx_eq_nginx
  $registry_external_url = $::gitlab::registry_external_url
  $secrets = $::gitlab::secrets
  $secrets_file = $::gitlab::secrets_file
  $service_group = $::gitlab::service_group
  $service_manage = $::gitlab::service_manage
  $service_user = $::gitlab::service_user
  $shell = $::gitlab::shell
  $sidekiq = $::gitlab::sidekiq
  $source_config_file = $::gitlab::source_config_file
  $unicorn = $::gitlab::unicorn
  $gitlab_workhorse = $::gitlab::gitlab_workhorse
  $user = $::gitlab::user
  $web_server = $::gitlab::web_server

  # replicate $nginx to $mattermost_nginx if $mattermost_nginx_eq_nginx true
  if $mattermost_nginx_eq_nginx {
    $_real_mattermost_nginx = $nginx
  } else {
    $_real_mattermost_nginx = $mattermost_nginx
  }

  # replicate $nginx to $pages_nginx if $pages_nginx_eq_nginx true
  if $pages_nginx_eq_nginx {
    $_real_pages_nginx = $nginx
  } else {
    $_real_pages_nginx = $pages_nginx
  }

  # replicate $nginx to $registry_nginx if $registry_nginx_eq_nginx true
  if $registry_nginx_eq_nginx {
    $_real_registry_nginx = $nginx
  } else {
    $_real_registry_nginx = $registry_nginx
  }

  if $config_manage {
    if $source_config_file {
      file { $config_file:
        ensure => file,
        owner  => $service_user,
        group  => $service_group,
        mode   => '0600',
        source => $source_config_file,
      }
    } else {
      file { $config_file:
        ensure  => file,
        owner   => $service_user,
        group   => $service_group,
        mode    => '0600',
        content => template('gitlab/gitlab.rb.erb');
      }
    }
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
