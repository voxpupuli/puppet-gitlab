# == Class gitlab::install
#
# This class is called from gitlab for install.
#
# [*manage_package*]
#   Default: true
#   Should the GitLab package be managed?
#
class gitlab::install (
  $package_ensure = $gitlab::package_ensure,
  $edition = $gitlab::edition,
  Boolean $manage_package = true,
){
  include gitlab::omnibus_package_repository

  if $manage_package {
    package { 'gitlab-omnibus':
      ensure  => $package_ensure,
      name    => "gitlab-${edition}",
      require => Class['gitlab::omnibus_package_repository'],
    }
  }
}
