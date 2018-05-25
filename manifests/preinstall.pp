class gitlab::preinstall (
  $skip_auto_migrations = $gitlab::skip_auto_migrations,
  $skip_auto_reconfigure = $gitlab::skip_auto_reconfigure
) {

  ####
  # Deprecation notice:
  # skip_auto_migrations is deprecated and will be removed at some point after
  # GitLab 11.0 is released
	$skip_auto_migrations_deprecation_msg = "DEPRECTATION: 'skip_auto_migrations' is deprecated if using GitLab 10.6 or greater. Set skip_auto_reconfigure instead"

  if $skip_auto_migrations != undef {

		notify { $skip_auto_migrations_deprecation_msg: }

    $_skip_auto_migrations_ensure = $skip_auto_migrations ? {
      true    => 'present',
      default => 'absent',
    }
    file { '/etc/gitlab/skip-auto-migrations':
      ensure => $_skip_auto_migrations_ensure,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
  }

  file { '/etc/gitlab/skip-auto-reconfigure':
    ensure => $skip_auto_reconfigure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
}
