# == Class gitlab::install
#
# This class is called from gitlab for install.
class gitlab::install (
  $package_name = $gitlab::package_name,
  $package_ensure = $gitlab::package_ensure,
  $manage_package = $gitlab::manage_package,
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
      fail('gitlab::package_name required when gitlab::manage_upstream_edition is `disabled`')
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
