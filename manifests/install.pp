# == Class gitlab::install
#
# This class is called from gitlab for install.
#
class gitlab::install {

  $package_name        = $::gitlab::package_name
  $package_ensure      = $::gitlab::package_ensure
  $manage_package_repo = $::gitlab::manage_package_repo

  # only do repo management when on a Debian-like system
  if $manage_package_repo and $::osfamily == 'Debian' {
    $package_repo_location = $::gitlab::package_repo_location
    $package_repo_repos    = $::gitlab::package_repo_repos
    $package_repo_key      = $::gitlab::package_repo_key
    $package_repo_key_src  = $::gitlab::package_repo_key_src

    apt::source { 'gitlab_official':
      comment     => 'Official repository for Gitlab',
      location    => $package_repo_location,
      release     => $::lsbdistcodename,
      repos       => $package_repo_repos,
      key         => $package_repo_key,
      key_source  => $package_repo_key_src,
      include_src => true,
      include_deb => true,
    } ->
    package { $package_name:
      ensure => $package_ensure,
    }
  } else {
    package { $package_name:
      ensure => $package_ensure,
    }
  }

}
