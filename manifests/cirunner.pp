# == Class: gitlab::cirunner
#
# This module installs and configures Gitlab CI Runners.
#
# === Parameters
#
# [*hiera_default_config_key*]
#   Default: gitlab_ci_runners_defaults
#   Name of hiera hash with default configs for CI Runners.
#   The config is the parameters for the /usr/bin/gitlab-ci-multi-runner register
#   command.
#
# [*hiera_runners_key*]
#   Default: gitlab_ci_runners
#   Name of hiera hash with individual runners to be installed.
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
  $hiera_default_config_key = 'gitlab_ci_runners_defaults',
  $hiera_runners_key = 'gitlab_ci_runners',
  $manage_docker = true,
  $manage_repo = true,
) {

  validate_string($hiera_default_config_key)
  validate_string($hiera_runners_key)
  validate_bool($manage_docker)
  validate_bool($manage_repo)

  unless ($::osfamily == 'Debian' or $::osfamily == 'RedHat')  {
    fail ("OS family ${::osfamily} is not supported. Only Debian and Redhat is suppported.")
  }

  if $manage_docker {
    include ::docker

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
    case $::osfamily {
      'Debian': {
        $distid = downcase($::lsbdistid)

        ::apt::source { 'apt_gitlabci':
          comment  => 'GitlabCI Runner Repo',
          location => "https://packages.gitlab.com/runner/gitlab-ci-multi-runner/${distid}/",
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
        Apt::Source['apt_gitlabci'] -> Package['gitlab-ci-multi-runner']
        Exec['apt_update'] -> Package['gitlab-ci-multi-runner']
      }
      'RedHat': {
        yumrepo { 'runner_gitlab-ci-multi-runner':
          ensure        => 'present',
          baseurl       => "https://packages.gitlab.com/runner/gitlab-ci-multi-runner/el/${::operatingsystemmajrelease}/\$basearch",
          descr         => 'runner_gitlab-ci-multi-runner',
          enabled       => '1',
          gpgcheck      => '0',
          gpgkey        => 'https://packages.gitlab.com/gpg.key',
          repo_gpgcheck => '1',
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify     => '1',
        }

        yumrepo { 'runner_gitlab-ci-multi-runner-source':
          ensure        => 'present',
          baseurl       => "https://packages.gitlab.com/runner/gitlab-ci-multi-runner/el/${::operatingsystemmajrelease}/SRPMS",
          descr         => 'runner_gitlab-ci-multi-runner-source',
          enabled       => '1',
          gpgcheck      => '0',
          gpgkey        => 'https://packages.gitlab.com/gpg.key',
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

  package { 'gitlab-ci-multi-runner':
    ensure => 'present',
  }

  $runners_hash = hiera($hiera_runners_key, {})
  $runners = keys($runners_hash)
  $default_config = hiera($hiera_default_config_key, {})
  gitlab::runner { $runners:
    default_config => $default_config,
    runners_hash   => $runners_hash,
  }
}
