# == Class gitlab::backup
#
# This class is called from gitlab for backup config.
#
class gitlab::backup {
  $rake_exec = $::gitlab::rake_exec
  $backup_cron_enable = $::gitlab::backup_cron_enable
  $backup_cron_minute = $::gitlab::backup_cron_minute
  $backup_cron_hour = $::gitlab::backup_cron_hour
  if empty($::gitlab::backup_cron_skips) {
    $backup_cron_skips = ''
  } else {
    $_backup_cron_skips = join($::gitlab::backup_cron_skips, ',')
    $backup_cron_skips = "SKIP=${_backup_cron_skips}"
  }

  if $backup_cron_enable {
    cron {'gitlab backup':
      command => "${rake_exec} gitlab:backup:create CRON=1 ${backup_cron_skips}",
      hour    => $backup_cron_hour,
      minute  => $backup_cron_minute,
    }
  }
}
