# == Define: gitlab::runner::parallels
#
define gitlab::runner::parallels (
  Optional[String]        $token             = undef,
  Optional[String ]       $url               = undef,
  Optional[Boolean]       $run_untagged      = undef,
  Optional[Boolean]       $locked            = undef,
  Optional[Array[String]] $tags              = undef,
  Optional[String]        $base_name         = undef,
  Optional[String]        $template_name     = undef,
  Optional[Boolean]       $disable_snapshots = undef,
) {
  include ::gitlab::cirunner::parallels
  $executor_cmd = '--executor parallels'
  $_name        = "parallels_${name}"
  $name_cmd     = "-n --name ${_name}"
  $token_cmd = ::gitlab::cirunner::cmd_str(
    'registration-token',
    [$token, $gitlab::cirunner::parallels::default_token,
    $::gitlab::cirunner::default_token]
  )
  $url_cmd = ::gitlab::cirunner::cmd_str(
    'url',
    [$url, $gitlab::cirunner::parallels::default_url,
    $::gitlab::cirunner::default_url]
  )
  $run_untagged_cmd = ::gitlab::cirunner::cmd_str(
    'run-untagged',
    [$run_untagged, $gitlab::cirunner::parallels::default_run_untagged,
    $::gitlab::cirunner::default_run_untagged]
  )
  $locked_cmd = ::gitlab::cirunner::cmd_str(
    'locked',
    [$locked, $gitlab::cirunner::parallels::default_locked,
    $::gitlab::cirunner::default_locked]
  )
  $tags_cmd = ::gitlab::cirunner::cmd_str(
    'tags',
    [$tags, $gitlab::cirunner::parallels::default_tags,
    $::gitlab::cirunner::default_tags]
  )
  $base_name_cmd = ::gitlab::cirunner::cmd_str(
    'parallels-base-name',
    [$base_name, $gitlab::cirunner::parallels::default_base_name]
  )
  $template_name_cmd = ::gitlab::cirunner::cmd_str(
    'parallels-template-name',
    [$template_name, $gitlab::cirunner::parallels::default_template_name]
  )
  $disable_snapshots_cmd = ::gitlab::cirunner::cmd_str(
    'parallels-disable-snapshots',
    [$disable_snapshots, $gitlab::cirunner::parallels::default_disable_snapshots]
  )
  $parameters_string = [
    $executor_cmd, $token_cmd, $url_cmd, $name_cmd, $run_untagged_cmd, $locked_cmd,
    $tags_cmd, $base_name_cmd, $template_name_cmd, $disable_snapshots_cmd,
  ].join(' ')
  # Execute gitlab ci multirunner register
  exec {"Register_runner_${title}":
    command => "/usr/bin/gitlab-ci-multi-runner register ${parameters_string}",
    unless  => "/bin/grep ${_name} ${::gitlab::cirunner::conf_file}",
  }

}
