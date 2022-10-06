# @summary This class is for setting host configurations required for gitlab installation.
#
# @param config_dir The service executable path. Provide this variable value only if the service executable path would be a subject of change in future GitLab versions for any reason.
# @param skip_auto_migrations Deprecated if using Gitlab > 10.6.4 and < 11.0.0, unsupported by gitlab omnibus using gitlab 11+. Use skip_auto_reconfigure
# @param skip_auto_reconfigure Utilized for Zero Downtime Updates, See: https://docs.gitlab.com/omnibus/update/README.html#zero-downtime-updates
# @param store_git_keys_in_db Enable or disable Fast Lookup of authorized SSH keys in the database. See: https://docs.gitlab.com/ee/administration/operations/fast_ssh_key_lookup.html
# @param pgpass_file_ensure Create .pgpass file for pgbouncer authentication. When set to present requires valid value for pgbouncer_password.
# @param pgpass_file_location Path to location of .pgpass file used by consul to authenticate with pgbouncer database
# @param pgbouncer_password Password for the gitlab-consul database user in the pgbouncer database
# @param config_show_diff Whether to display diff in the puppet log or not
class gitlab::host_config (
  $config_dir = '/etc/gitlab',
  $skip_auto_migrations = $gitlab::skip_auto_migrations,
  $skip_auto_reconfigure = $gitlab::skip_auto_reconfigure,
  $store_git_keys_in_db = $gitlab::store_git_keys_in_db,
  $pgpass_file_ensure = $gitlab::pgpass_file_ensure,
  $pgpass_file_location = $gitlab::pgpass_file_location,
  $pgbouncer_password = $gitlab::pgbouncer_password,
  $config_show_diff = $gitlab::config_show_diff,
) {
  file { $config_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0775',
  }

  # Deprecation notice:
  # skip_auto_migrations is deprecated and will be removed at some point after
  # GitLab 11.0 is released
  $skip_auto_migrations_deprecation_msg = "DEPRECTATION: 'skip_auto_migrations' is deprecated if using GitLab 10.6 or greater. Set skip_auto_reconfigure instead"
  $skip_auto_reconfigure_attributes = {
    owner => 'root',
    group => 'root',
    mode  => '0644',
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

    file { '/opt/gitlab-shell':
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

  if ($pgpass_file_ensure == 'present' and $pgbouncer_password == undef) {
    fail('A password must be provided to pgbouncer_password if pgpass_file_attrs[ensure] is \'present\'')
  } elsif ($pgpass_file_ensure == 'absent') {
    file { $pgpass_file_location:
      ensure => 'absent',
    }
  } else {
    # owner,group params for pgpass_file should NOT be changed, as they are hardcoded into gitlab HA db schema for pgbouncer database template
    file { $pgpass_file_location:
      ensure    => $pgpass_file_ensure,
      owner     => 'gitlab-consul',
      group     => 'gitlab-consul',
      show_diff => $config_show_diff,
      content   => epp('gitlab/.pgpass.epp', {
          'pgbouncer_password' => $pgbouncer_password,
      }),
    }
  }

  include gitlab::backup
}
