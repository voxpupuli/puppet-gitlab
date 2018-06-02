# == Class gitlab::service
#
# This class is meant to be called from gitlab.
# It ensure the service is running.
#
class gitlab::service (
  $service_ensure = $gitlab::service_ensure,
  $service_enable = $gitlab::service_enable,
  $service_name   = $gitlab::service_name,
  $service_exec   = $gitlab::service_exec,
  $service_manage = $gitlab::service_manage,
){

  exec { 'gitlab_reconfigure':
    command     => '/usr/bin/gitlab-ctl reconfigure',
    refreshonly => true,
    timeout     => 1800,
    logoutput   => true,
    tries       => 5,
  }

  if $service_manage {
    $restart = "${service_exec} restart"
    $start = "${service_exec} start"
    $stop = "${service_exec} stop"
    $status = "${service_exec} status"

    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      restart    => $restart,
      start      => $start,
      stop       => $stop,
      status     => $status,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
