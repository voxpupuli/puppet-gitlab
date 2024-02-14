require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  # The omnibus installer use the following algorithm to know what to do.
  # https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-cookbooks/runit/recipes/default.rb
  # If this peace of code trigger docker case, the installer hang indefinitly.
  pp = %(
    file {'/.dockerenv':
      ensure => absent,
    }
    package { ['curl']:
      ensure => present,
    }
  )

  apply_manifest_on(host, pp, catch_failures: true)

  # https://gitlab.com/gitlab-org/omnibus-gitlab/issues/2229
  # There is no /usr/share/zoneinfo in latest Docker image for ubuntu 16.04
  # Gitlab installer fail without this file
  tzdata = %(
    package { ['tzdata']:
      ensure => present,
    }
  )

  apply_manifest_on(host, tzdata, catch_failures: true)
end
