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
  Optional[Integer]       $concurrent           = undef,
  Boolean                 $manage_repo          = true,
  String                  $conf_file            = '/etc/gitlab-runner/config.toml',
  Enum[installed, absent] $package_ensure       = installed,
  Optional[String]        $default_token        = undef,
  String                  $default_url          = 'https://gitlab.com',
  Boolean                 $default_run_untagged = true,
  Boolean                 $default_locked       = false,
  Optional[Array[String]] $default_tags         = undef,
  Hash                    $docker_runners       = {},
  Hash                    $shell_runners        = {},
  Hash                    $ssh_runners          = {},
  Hash                    $docker_ssh_runners   = {},
  Hash                    $parallels_runners    = {},
  Hash                    $virtualbox_runners   = {},
  Hash                    $kubernetes_runners   = {},
) {

  unless ($::osfamily == 'Debian' or $::osfamily == 'RedHat')  {
    fail ("OS family ${::osfamily} is not supported. Only Debian and Redhat is suppported.")
  }

  if $manage_repo {
    case $::osfamily {
      'Debian': {
        include ::apt
        ensure_packages('apt-transport-https')

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
          },
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
    ensure => $package_ensure,
  }

  if $concurrent {
    file_line { 'gitlab-runner-concurrent':
      path    => $conf_file,
      line    => "concurrent = ${concurrent}",
      match   => '^concurrent = \d+',
      require => Package['gitlab-ci-multi-runner'],
      notify  => Exec['gitlab-runner-restart'],
    }
  }

  exec { 'gitlab-runner-restart':
    command     => '/usr/bin/gitlab-ci-multi-runner restart',
    refreshonly => true,
    require     => Package['gitlab-ci-multi-runner'],
  }
  if ! empty($docker_runners) {
    if defined(Class['gitlab::cirunner::docker']) {
      warning('Class[\'gitlab::cirunner::docker\' is defined so $gitlab::cirunner::docker__runners willbe ignored')
    } else {
      class {'::gitlab::cirunner::docker': runners => $docker_runners}
    }
  }
  if ! empty($shell_runners) {
    if defined(Class['gitlab::cirunner::shell']) {
      warning('Class[\'gitlab::cirunner::shell\' is defined so $gitlab::cirunner::shell_runners willbe ignored')
    } else {
      class {'::gitlab::cirunner::shell': runners => $shell_runners}
    }
  }
  if ! empty($ssh_runners) {
    if defined(Class['gitlab::cirunner::ssh']) {
      warning('Class[\'gitlab::cirunner::ssh\' is defined so $gitlab::cirunner::ssh_runners willbe ignored')
    } else {
      class {'::gitlab::cirunner::ssh': runners => $ssh_runners}
    }
  }
  if ! empty($docker_ssh_runners) {
    if defined(Class['gitlab::cirunner::docker_ssh']) {
      warning('Class[\'gitlab::cirunner::docker_ssh\' is defined so $gitlab::cirunner::docker_ssh_runners willbe ignored')
    } else {
      lass {'::gitlab::cirunner::docker_ssh': runners => $docker_ssh_runners}
    }
  }
  if ! empty($parallels_runners) {
    if defined(Class['gitlab::cirunner::parallels']) {
      warning('Class[\'gitlab::cirunner::parallels\' is defined so $gitlab::cirunner::parallels_runners willbe ignored')
    } else {
      class {'::gitlab::cirunner::parallels': runners => $parallels_runners}
    }
  }
  if ! empty($virtualbox_runners) {
    if defined(Class['gitlab::cirunner::virtualbox']) {
      warning('Class[\'gitlab::cirunner::virtualbox\' is defined so $gitlab::cirunner::virtualbox_runners willbe ignored')
    } else {
      class {'::gitlab::cirunner::virtualbox': runners => $virtualbox_runners}
    }
  }
  if ! empty($kubernetes_runners) {
    if defined(Class['gitlab::cirunner::kubernetes']) {
      warning('Class[\'gitlab::cirunner::kubernetes\' is defined so $gitlab::cirunner::kubernetes_runners willbe ignored')
    } else {
      class {'::gitlab::cirunner::kubernetes': runners => $kubernetes_runners}
    }
  }
}
