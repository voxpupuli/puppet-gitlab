# == Define: gitlab::runner::ssh
#
define gitlab::runner::ssh (
  Optional[String]            $token             = undef,
  Optional[String ]           $url               = undef,
  Optional[Boolean]           $run_untagged      = undef,
  Optional[Boolean]           $locked            = undef,
  Optional[Array[String]]     $tags              = undef,
  Optional[String]            $ssh_user          = undef,
  Optional[String]            $ssh_password      = undef,
  Optional[String]            $ssh_host          = undef,
  Optional[Integer[0,65535]]  $ssh_port          = undef,
  Optional[String]            $ssh_identity_file = undef,
) {
  include ::gitlab::cirunner::ssh
  $executor_cmd = '--executor ssh'
  $_name        = "ssh_${name}"
  $name_cmd     = "-n --name ${_name}"
  $token_cmd = ::gitlab::cirunner::cmd_str(
    'registration-token',
    [$token, $gitlab::cirunner::ssh::default_token,
    $::gitlab::cirunner::default_token]
  )
  $url_cmd = ::gitlab::cirunner::cmd_str(
    'url',
    [$url, $gitlab::cirunner::ssh::default_url,
    $::gitlab::cirunner::default_url]
  )
  $run_untagged_cmd = ::gitlab::cirunner::cmd_str(
    'run-untagged',
    [$run_untagged, $gitlab::cirunner::ssh::default_run_untagged,
    $::gitlab::cirunner::default_run_untagged]
  )
  $locked_cmd = ::gitlab::cirunner::cmd_str(
    'locked',
    [$locked, $gitlab::cirunner::ssh::default_locked,
    $::gitlab::cirunner::default_locked]
  )
  $tags_cmd = ::gitlab::cirunner::cmd_str(
    'tags',
    [$tags, $gitlab::cirunner::ssh::default_tags,
    $::gitlab::cirunner::default_tags]
  )
  $ssh_user_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-user',
    [$ssh_user, $gitlab::cirunner::ssh::default_ssh_user]
  )
  $ssh_password_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-password',
    [$ssh_password, $gitlab::cirunner::ssh::default_ssh_password]
  )
  $ssh_host_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-host',
    [$ssh_host, $gitlab::cirunner::ssh::default_ssh_host]
  )
  $ssh_port_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-port',
    [$ssh_port, $gitlab::cirunner::ssh::default_ssh_port]
  )
  $ssh_identity_file_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-identity-file',
    [$ssh_identity_file, $gitlab::cirunner::ssh::default_ssh_identity_file]
  )
  $parameters_string = [
    $executor_cmd, $token_cmd, $url_cmd, $name_cmd, $run_untagged_cmd, $locked_cmd,
    $tags_cmd, $ssh_user_cmd, $ssh_password_cmd, $ssh_host_cmd, $ssh_port_cmd,
    $ssh_identity_file_cmd,
    ].join(' ')
    # Execute gitlab ci multirunner register
    exec {"Register_runner_${title}":
      command => "/usr/bin/gitlab-ci-multi-runner register ${parameters_string}",
      unless  => "/bin/grep ${_name} ${::gitlab::cirunner::conf_file}",
    }

}
