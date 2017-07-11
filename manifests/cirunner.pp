# == Class: gitlab::cirunner
#
# This module installs and configures Gitlab CI Runners.
#
# === Parameters
#
# [*concurrent*]
#   Default: `undef`
#   The limit on the number of jobs that can run concurrently among
#   all runners, or `undef` to leave unmanaged.
#
# [*hiera_default_config_key*]
#   Default: gitlab_ci_runners_defaults
#   Name of hiera hash with default configs for CI Runners.
#   The config is the parameters for the /usr/bin/gitlab-ci-multi-runner register
#   command (for version 10.x: /usr/bin/gitlab-runner).
#
# [*hiera_runners_key*]
#   Default: gitlab_ci_runners
#   Name of hiera hash with individual runners to be installed.
#
# [*common_config*]
#   Default: {}
#   hash with default configs for CI Runners.
#
# [*runners_config*]
#   Default: {}
#   hash with individual runners to be installed
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
# Matthias Indermuehle <matthias.indermuehle@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
#
class gitlab::cirunner (
  $concurrent = undef,
  $hiera_default_config_key = 'gitlab_ci_runners_defaults',
  $hiera_runners_key = 'gitlab_ci_runners',
  $common_config = {},
  $runners_config = {},
  $manage_docker = true,
  $manage_repo = true,
  $xz_package_name = 'xz-utils',
  $package_ensure = installed,
  $package_name = 'gitlab-ci-multi-runner',
) {

  validate_string($hiera_default_config_key)
  validate_string($hiera_runners_key)
  validate_bool($manage_docker)
  validate_bool($manage_repo)
  validate_string($xz_package_name)
  validate_string($package_ensure)
  validate_string($package_name)
  validate_hash($common_config)
  validate_hash($runners_config)

  unless ($::osfamily == 'Debian' or $::osfamily == 'RedHat')  {
    fail ("OS family ${::osfamily} is not supported. Only Debian and Redhat is suppported.")
  }

  if $manage_docker {
    include ::docker
    # workaround for cirunner issue #1617
    # https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/issues/1617
    ensure_packages($xz_package_name)

    $docker_images = {
      ubuntu_trusty => {
        image => 'ubuntu',
        image_tag => 'trusty',
      },
    }
    class { '::docker::images':
      images => $docker_images,
    }
  }

  if $manage_repo {
    $repo_base_url = 'https://packages.gitlab.com'

    case $::osfamily {
      'Debian': {
        include apt
        ensure_packages('apt-transport-https')

        $distid = downcase($::lsbdistid)

        ::apt::source { 'apt_gitlabci':
          comment  => 'GitlabCI Runner Repo',
          location => "${repo_base_url}/runner/${package_name}/${distid}/",
          release  => $::lsbdistcodename,
          repos    => 'main',
          key      => {
            'id'     => '1A4C919DB987D435939638B914219A96E15E78F4',
            'server' => 'keys.gnupg.net',
          },
          include  => {
            'src' => false,
            'deb' => true,
          }
        }
        Apt::Source['apt_gitlabci'] -> Package[$package_name]
        Exec['apt_update'] -> Package[$package_name]
      }
      'RedHat': {
        yumrepo { "runner_${package_name}":
          ensure        => 'present',
          baseurl       => "${repo_base_url}/runner/${package_name}/el/${::operatingsystemmajrelease}/\$basearch",
          descr         => "runner_${package_name}",
          enabled       => '1',
          gpgcheck      => '0',
          gpgkey        => "${repo_base_url}/gpg.key",
          repo_gpgcheck => '1',
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify     => '1',
        }

        yumrepo { "runner_${package_name}-source":
          ensure        => 'present',
          baseurl       => "${repo_base_url}/runner/${package_name}/el/${::operatingsystemmajrelease}/SRPMS",
          descr         => "runner_${package_name}-source",
          enabled       => '1',
          gpgcheck      => '0',
          gpgkey        => "${repo_base_url}/gpg.key",
          repo_gpgcheck => '1',
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify     => '1',
        }
      }
      default: {
        fail ("gitlab::cirunner::manage_repo parameter for ${::osfamily} is not supported.")
      }
    }
  }

  package { $package_name:
    ensure => $package_ensure,
  }

  if $concurrent {
    validate_integer($concurrent, undef, 1)

    file_line { 'gitlab-runner-concurrent':
      path    => '/etc/gitlab-runner/config.toml',
      line    => "concurrent = ${concurrent}",
      match   => '^concurrent = \d+',
      require => Package[$package_name],
      notify  => Exec['gitlab-runner-restart'],
    }
  }

  exec { 'gitlab-runner-restart':
    command     => "/usr/bin/${package_name} restart",
    refreshonly => true,
    require     => Package[$package_name],
  }

  $runners_hash = merge($runners_config, hiera_hash($hiera_runners_key, {}))
  $runners = keys($runners_hash)
  $default_config = merge($common_config, hiera_hash($hiera_default_config_key, {}))
  gitlab::runner { $runners:
    binary         => $package_name,
    default_config => $default_config,
    runners_hash   => $runners_hash,
    require        => Exec['gitlab-runner-restart'],
  }
}
