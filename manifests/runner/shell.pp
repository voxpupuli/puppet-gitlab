# == Define: gitlab::runner::shell
#
define gitlab::runner::shell (
  Optional[String]        $token        = undef,
  Optional[String ]       $url          = undef,
  Optional[Boolean]       $run_untagged = undef,
  Optional[Boolean]       $locked       = undef,
  Optional[Array[String]] $tags         = undef,
  Optional[String]        $shell        = undef,
) {
  include ::gitlab::cirunner::shell
  $executor_cmd = '--executor shell'
  $_name        = "shell_${name}"
  $name_cmd     = "-n --name ${_name}"
  $token_cmd = ::gitlab::cirunner::cmd_str(
    'registration-token',
    [$token, $gitlab::cirunner::shell::default_token,
    $::gitlab::cirunner::default_token]
  )
  $url_cmd = ::gitlab::cirunner::cmd_str(
    'url',
    [$url, $gitlab::cirunner::shell::default_url,
    $::gitlab::cirunner::default_url]
  )
  $run_untagged_cmd = ::gitlab::cirunner::cmd_str(
    'run-untagged',
    [$run_untagged, $gitlab::cirunner::shell::default_run_untagged,
    $::gitlab::cirunner::default_run_untagged]
  )
  $locked_cmd = ::gitlab::cirunner::cmd_str(
    'locked',
    [$locked, $gitlab::cirunner::shell::default_locked,
    $::gitlab::cirunner::default_locked]
  )
  $tags_cmd = ::gitlab::cirunner::cmd_str(
    'tags',
    [$tags, $gitlab::cirunner::shell::default_tags,
    $::gitlab::cirunner::default_tags]
  )
  $shell_cmd = ::gitlab::cirunner::cmd_str(
    'shell',
    [$shell, $gitlab::cirunner::shell::default_shell]
  )
  $parameters_string = [
    $executor_cmd, $token_cmd, $url_cmd, $name_cmd, $run_untagged_cmd,
    $locked_cmd, $tags_cmd, $shell_cmd,
  ].join(' ')
  exec {"Register_runner_${_name}":
    command => "/usr/bin/gitlab-ci-multi-runner register ${parameters_string}",
    unless  => "/bin/grep ${_name} ${::gitlab::cirunner::conf_file}",
  }

}
