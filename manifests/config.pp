# == Class gitlab::config
#
# This class is called from gitlab for service config.
#
class gitlab::config {

  # get variables from the toplevel manifest for usage in the template
  $service_manage    = $::gitlab::service_manage
  $config_file       = $::gitlab::config_file
  $external_url      = $::gitlab::external_url
  $ci_external_url   = $::gitlab::ci_external_url
  $ci_nginx          = $::gitlab::ci_nginx
  $ci_nginx_eq_nginx = $::gitlab::ci_nginx_eq_nginx
  $ci_redis          = $::gitlab::ci_redis
  $ci_unicorn        = $::gitlab::ci_unicorn
  $git               = $::gitlab::git
  $git_data_dir      = $::gitlab::git_data_dir
  $gitlab_ci         = $::gitlab::gitlab_ci
  $gitlab_rails      = $::gitlab::gitlab_rails
  $logging           = $::gitlab::logging
  $logrotate         = $::gitlab::logrotate
  $nginx             = $::gitlab::nginx
  $postgresql        = $::gitlab::postgresql
  $redis             = $::gitlab::redis
  $shell             = $::gitlab::shell
  $sidekiq           = $::gitlab::sidekiq
  $unicorn           = $::gitlab::unicorn
  $user              = $::gitlab::user
  $web_server        = $::gitlab::web_server
  $high_availability = $::gitlab::high_availability

  # replicate $nginx to $ci_nginx if $ci_nginx_eq_nginx true
  if $ci_nginx_eq_nginx {
    $_real_ci_nginx = $nginx
  } else {
    $_real_ci_nginx = $ci_nginx
  }

  file { $config_file:
      ensure  => file,
      owner   => $service_user,
      group   => $service_group,
      content => template('gitlab/gitlab.rb.erb');
  }

  if $service_manage {
    # configure gitlab using the official tool
    File[$config_file] {
      notify => Exec['gitlab_reconfigure']
    }
    exec { 'gitlab_reconfigure':
      command     => '/usr/bin/gitlab-ctl reconfigure',
      refreshonly => true,
      timeout     => 1800,
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
