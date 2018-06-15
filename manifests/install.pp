# == Class gitlab::install
#
# This class is called from gitlab for install.
#
# [*package_name*]
#   Default: 'gitlab-ce'
#   The internal packaging system's name for the package
#   This name will automatically be changed by the gitlab::edition parameter
#   Can be overridden for the purposes of installing custom compiled version of gitlab-omnibus
#
# [*manage_package*]
#   Default: true
#   Should the GitLab package be managed?
#
class gitlab::install (
  Optional[String] $package_name = undef,
  $package_ensure = $gitlab::package_ensure,
  Boolean $manage_package = true,
){


  if $gitlab::manage_upstream_edition != 'disabled' {
    if $gitlab::edition {
      $_edition = $gitlab::edition
    } else {
      $_edition = $gitlab::manage_upstream_edition
    }

    $_package_name = "gitlab-${_edition}"
  } else {
    unless $package_name {
      fail('gitlab::install::package_name required when gitlab::manage_upstream_edition is `disabled`')
    }

    $_package_name = $package_name
  }

  if $manage_package {
    package { 'gitlab-omnibus':
      ensure  => $package_ensure,
      name    => $_package_name,
      require => Class['gitlab::omnibus_package_repository'],
    }
  }
}
