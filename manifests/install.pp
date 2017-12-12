# == Class gitlab::install
#
# This class is called from gitlab for install.
#
class gitlab::install {

  $edition             = $::gitlab::edition
  $manage_package_repo = $::gitlab::manage_package_repo
  $manage_package      = $::gitlab::manage_package
  $package_ensure      = $::gitlab::package_ensure
  $package_name        = "gitlab-${edition}"
  $package_pin         = $::gitlab::package_pin

  # only do repo management when on a Debian-like system
  if $manage_package_repo {
    case $::osfamily {
      'debian': {
        include apt
        ensure_packages('apt-transport-https')
        $_lower_os = downcase($::operatingsystem)
        apt::source { "gitlab_official_${edition}":
          comment  => 'Official repository for Gitlab',
          location => "https://packages.gitlab.com/gitlab/gitlab-${edition}/${_lower_os}/",
          release  => $::lsbdistcodename,
          repos    => 'main',
          key      => {
            id     => '1A4C919DB987D435939638B914219A96E15E78F4',
            source => 'https://packages.gitlab.com/gpg.key',
          },
          include  => {
            src => true,
            deb => true,
          },
        }
        if $manage_package {
          package { $package_name:
            ensure  => $package_ensure,
            require => [
              Exec['apt_update'],
              Apt::Source["gitlab_official_${edition}"],
            ],
          }
        }
        if $package_pin {
          apt::pin { 'hold-gitlab':
            packages => $package_name,
            version  => $package_ensure,
            priority => 1001,
          }
        }
      }
      'redhat': {

        $gpgkey = $edition ? {
            'ee'    => 'https://packages.gitlab.com/gitlab/gitlab-ee/gpgkey/gitlab-gitlab-ee-3D645A26AB9FBD22.pub.gpg',
            default => 'https://packages.gitlab.com/gpg.key',
        }

        yumrepo { "gitlab_official_${edition}":
          descr         => 'Official repository for Gitlab',
          baseurl       => "https://packages.gitlab.com/gitlab/gitlab-${edition}/el/${::operatingsystemmajrelease}/\$basearch",
          enabled       => 1,
          repo_gpgcheck => 1,
          gpgcheck      => 1,
          gpgkey        => $gpgkey,
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify     => 1,
        }

        if $manage_package {
          package { $package_name:
            ensure  => $package_ensure,
            require => Yumrepo["gitlab_official_${edition}"],
          }
        }
      }
      default: {
        fail("OS family ${::osfamily} not supported")
      }
    }
  } elsif $manage_package  {
    package { $package_name:
      ensure => $package_ensure,
    }
  }

}
