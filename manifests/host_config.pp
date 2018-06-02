# == Class gitlab::host_config
#
# This class is for setting host configurations required for gitlab installation
#
# [*config_dir*]
#   Default: '/etc/gitlab'
#   The service executable path.
#   Provide this variable value only if the service executable path
#   would be a subject of change in future GitLab versions for any reason.
class gitlab::host_config (
  $skip_auto_migrations = $gitlab::skip_auto_migrations,
  $skip_auto_reconfigure = $gitlab::skip_auto_reconfigure,
  $config_dir = '/etc/gitlab',
  $config_file = '/etc/gitlab/gitlab.rb',
  $secrets_file = '/etc/gitlab/gitlab-secrets.json',
  $store_git_keys_in_db = $::gitlab::store_git_keys_in_db,
) {

  file { $config_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'group',
    mode   => '0775',
  }

  # Deprecation notice:
  # skip_auto_migrations is deprecated and will be removed at some point after
  # GitLab 11.0 is released
  $skip_auto_migrations_deprecation_msg = "DEPRECTATION: 'skip_auto_migrations' is deprecated if using GitLab 10.6 or greater. Set skip_auto_reconfigure instead"
  $skip_auto_reconfigure_attributes = {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  if $skip_auto_migrations != undef {

    notify { $skip_auto_migrations_deprecation_msg: }

    $_skip_auto_migrations_ensure = $skip_auto_migrations ? {
      true    => 'present',
      default => 'absent',
    }

    file { '/etc/gitlab/skip-auto-migrations':
      ensure => $_skip_auto_migrations_ensure,
      *      => $skip_auto_reconfigure_attributes,
    }
  }

  file { '/etc/gitlab/skip-auto-reconfigure':
    ensure => $skip_auto_reconfigure,
    *      => $skip_auto_reconfigure_attributes,
  }

  if $store_git_keys_in_db != undef {
    $_store_git_keys_in_db = $store_git_keys_in_db ? {
      true    => 'file',
      default => 'absent',
    }

    $opt_gitlab_shell_dir = $store_git_keys_in_db ? {
      true    => 'directory',
      default => 'absent'
    }

    file {'/opt/gitlab-shell':
      ensure => $opt_gitlab_shell_dir,
      owner  => 'root',
      group  => 'git',
    }

    file { '/opt/gitlab-shell/authorized_keys':
      ensure => $_store_git_keys_in_db,
      owner  => 'root',
      group  => 'git',
      mode   => '0650',
      source => 'puppet:///modules/gitlab/gitlab_shell_authorized_keys',
    }
  }

  include gitlab::backup
}
