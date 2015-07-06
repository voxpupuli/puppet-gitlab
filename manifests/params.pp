# == Class gitlab::params
#
# This class is meant to be called from gitlab.
# It sets variables according to platform.
#
class gitlab::params {

  # package parameters
  $package_ensure = installed
  $manage_package_repo = true

  # service parameters
  case $::osfamily {
    'debian': {
      $service_enable = true
    }
    'redhat': {
      $service_enable = false
    }
    default: {
      $service_enable = true
    }
  }

  $service_restart    = '/usr/bin/gitlab-ctl restart'
  $service_start      = '/usr/bin/gitlab-ctl start'
  $service_stop       = '/usr/bin/gitlab-ctl stop'
  $service_status     = '/usr/bin/gitlab-ctl status'
  $service_hasstatus  = true
  $service_hasrestart = true

  $service_ensure = running
  $service_manage = true
  $service_name = 'gitlab-runsvdir'
  $service_user = 'root'
  $service_group = 'root'

  # gitlab specific
  $config_file = '/etc/gitlab/gitlab.rb'
  $edition = 'ce'

}
