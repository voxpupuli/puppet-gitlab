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
  Enum['gitlab-ce', 'gitlab-ee'] $package_name,
  $package_ensure = $gitlab::package_ensure,
  Boolean $manage_package = true,
){

  if $manage_package {
    package { 'gitlab-omnibus':
      ensure  => $package_ensure,
      name    => $package_name,
      require => Class['gitlab::omnibus_package_repository'],
    }
  }
}
