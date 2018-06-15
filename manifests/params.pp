# == Class gitlab::params
#
# This class is meant to be called from gitlab.
# It sets variables according to platform.
#
class gitlab::params {

  $rake_exec = '/usr/bin/gitlab-rake'


  if $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '6' {
    $service_enable = false
  } else {
    $service_enable = true
  }

  # gitlab specific
  $external_url = "http://${::fqdn}"
}
