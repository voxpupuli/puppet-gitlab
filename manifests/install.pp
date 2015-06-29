# == Class gitlab::install
#
# This class is called from gitlab for install.
#
class gitlab::install {

  $package_ensure      = $::gitlab::package_ensure
  $manage_package_repo = $::gitlab::manage_package_repo
  $edition             = $::gitlab::edition
  $package_name        = "gitlab-${edition}"

  # only do repo management when on a Debian-like system
  if $manage_package_repo {
    case $::osfamily {
      'debian': {
        Exec['apt_update'] -> Package[$package_name]
        apt::source { 'gitlab_official':
          comment     => 'Official repository for Gitlab',
          location    => "https://packages.gitlab.com/gitlab/gitlab-${edition}/ubuntu/",
          release     => $::lsbdistcodename,
          repos       => 'main',
          key         => '1A4C919DB987D435939638B914219A96E15E78F4',
          key_source  => 'https://packages.gitlab.com/gpg.key',
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
          baseurl       => "https://packages.gitlab.com/gitlab/gitlab-${edition}/el/\$releasever/\$basearch",
          enabled       => 1,
          gpgcheck      => 0,
          gpgkey        => 'https://packages.gitlab.com/gpg.key',
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
