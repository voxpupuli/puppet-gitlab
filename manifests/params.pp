# == Class gitlab::params
#
# This class is meant to be called from gitlab.
# It sets variables according to platform.
#
class gitlab::params {

  # package parameters
  $package_ensure = installed
  $package_pin = false
  $manage_package_repo = true
  $manage_package = true

  $service_enable = true

  $service_exec = '/usr/bin/gitlab-ctl'
  $service_restart = "${service_exec} restart"
  $service_start = "${service_exec} start"
  $service_stop = "${service_exec} stop"
  $service_status = "${service_exec} status"
  $service_hasstatus = true
  $service_hasrestart = true

  $service_ensure = running
  $service_manage = true
  $service_name = 'gitlab-runsvdir'
  $service_user = 'root'
  $service_group = 'root'

  # gitlab specific
  $config_file = '/etc/gitlab/gitlab.rb'
  $secrets_file = '/etc/gitlab/gitlab-secrets.json'
  $edition = 'ce'

}
