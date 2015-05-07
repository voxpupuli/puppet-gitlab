# == Class gitlab::service
#
# This class is meant to be called from gitlab.
# It ensure the service is running.
#
class gitlab::service {

  $service_manage = $::gitlab::service_manage
  $service_name   = $::gitlab::service_name
  $service_ensure = $::gitlab::service_ensure
  $service_enable = $::gitlab::service_enable

  if $service_manage {
    # TODO: decide if this makes sense
    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      provider   => 'upstart',
      restart    => '/usr/bin/gitlab-ctl restart',
      start      => '/usr/bin/gitlab-ctl start',
      stop       => '/usr/bin/gitlab-ctl stop',
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
