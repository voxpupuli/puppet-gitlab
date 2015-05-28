# == Class gitlab::install
#
# This class is called from gitlab for install.
#
class gitlab::install {

  $package_name        = $::gitlab::package_name
  $package_ensure      = $::gitlab::package_ensure
  $manage_package_repo = $::gitlab::manage_package_repo

  # only do repo management when on a Debian-like system
  if $manage_package_repo {
    $package_repo_location = $::gitlab::package_repo_location
    $package_repo_repos    = $::gitlab::package_repo_repos
    $package_repo_key      = $::gitlab::package_repo_key
    $package_repo_key_src  = $::gitlab::package_repo_key_src
    case $::osfamily {
      'debian': {
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
      }
      'redhat': {
        yumrepo { 'gitlab_official':
          descr         => 'Official repository for Gitlab',
          baseurl       => $package_repo_location,
          enabled       => 1,
          gpgcheck      => 0,
          gpgkey        => $package_repo_key_src,
          repo_gpgcheck => 1,
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify     => 1,
        } ->
        package { $package_name:
          ensure => $package_ensure,
        }
      }
      default: {
        fail("OS family ${::osfamily} not supported")
      }
    }
  } else {
    package { $package_name:
      ensure => $package_ensure,
    }
  }

}
