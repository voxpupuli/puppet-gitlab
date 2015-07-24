# == Class: gitlab
#
# This module installs and configures Gitlab with the Omnibus package.
#
# === Parameters
#
# [*package_ensure*]
#   Default: installed
#   Can be used to choose exact package version to install.
#
# [*manage_package_repo*]
#   Default: true
#   Should the official package repository be managed?
#
# [*service_name*]
#   Default: gitlab-runsvdir
#   Name of the system service.
#
# [*service_enable*]
#   Default: true
#   Run the system service on boot.
#
# [*service_ensure*]
#   Default: running
#   Should Puppet start the service?
#
# [*service_manage*]
#   Default: true
#   Should Puppet manage the service?
#
# [*service_user*]
#   Default: root
#   Owner of the config file.
#
# [*service_group*]
#   Default: root
#   Group of the config file.
#
# [*service_restart/_start/_stop/_status*]
#   Default: /usr/bin/gitlab-ctl <command>
#   Commands for the service definition.
#
# [*service_hasstatus/_hasrestart*]
#   Default: true
#   The gitlab service has this commands available.
#
# [*edition*]
#   Default: ce
#   Gitlab edition to install. ce or ee.
#
# [*config_file*]
#   Default: /etc/gitlab/gitlab.rb
#   Path of the Gitlab Omnibus config file.
#
# [*ci_external_url*]
#   Default: undef
#   External URL of Gitlab CI.
#
# [*ci_nginx_eq_nginx*]
#   Default: false
#   Replicate the CI Nginx config from the Gitlab Nginx config.
#
# [*ci_nginx*]
#   Default: undef
#   Hash of 'ci_nginx' config parameters.
#
# [*ci_redis*]
#   Default: undef
#   Hash of 'ci_redis' config parameters.
#
# [*ci_unicorn*]
#   Default: undef
#   Hash of 'ci_unicorn' config parameters.
#
# [*external_url*]
#   Default: undef
#   External URL of Gitlab.
#
# [*git*]
#   Default: undef
#   Hash of 'omnibus_gitconfig' config parameters.
#
# [*git_data_dir*]
#   Default: undef
#   Git data dir
#
# [*gitlab_ci*]
#   Default: undef
#   Hash of 'gitlab_ci' config parameters.
#
# [*gitlab_rails*]
#   Default: undef
#   Hash of 'gitlab_rails' config parameters.
#
# [*logging*]
#   Default: undef
#   Hash of 'logging' config parameters.
#
# [*logrotate*]
#   Default: undef
#   Hash of 'logrotate' config parameters.
#
# [*nginx*]
#   Default: undef
#   Hash of 'nginx' config parameters.
#
# [*postgresql*]
#   Default: undef
#   Hash of 'postgresql' config parameters.
#
# [*redis*]
#   Default: undef
#   Hash of 'redis' config parameters.
#
# [*secrets*]
#   Default: undef
#   Hash of values which will be placed into $secrets_file (by default /etc/gitlab/gitlab-secrets.json)
#   If this parameter is undef, the file won't be managed.
#
# [*secrets_file*]
#   Default: /etc/gitlab/gitlab-secrets.json
#   Full path to secrets JSON file.
#
# [*shell*]
#   Default: undef
#   Hash of 'gitlab_shell' config parameters.
#
# [*sidekiq*]
#   Default: undef
#   Hash of 'sidekiq' config parameters.
#
# [*unicorn*]
#   Default: undef
#   Hash of 'unicorn' config parameters.
#
# [*user*]
#   Default: undef
#   Hash of 'user' config parameters.
#
# [*web_server*]
#   Default: undef
#   Hash of 'web_server' config parameters.
#
# [*high_availability*]
#   Default: undef
#   Hash of 'high_availability' config parameters.
#
# === Examples
#
#  class { 'gitlab':
#    edition           => 'ee',
#    ci_external_url   => 'https://myci.mydomain.tld',
#    external_url      => 'https://gitlab.mydomain.tld',
#    nginx             => { redirect_http_to_https => true },
#    ci_nginx_eq_nginx => true,
#  }
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
#
class gitlab (
  # package installation handling
  $manage_package_repo = $::gitlab::params::manage_package_repo,
  $package_ensure      = $::gitlab::params::package_ensure,
  # system service configuration
  $service_enable      = $::gitlab::params::service_enable,
  $service_ensure      = $::gitlab::params::service_ensure,
  $service_group       = $::gitlab::params::service_group,
  $service_hasrestart  = $::gitlab::params::service_hasrestart,
  $service_hasstatus   = $::gitlab::params::service_hasstatus,
  $service_manage      = $::gitlab::params::service_manage,
  $service_name        = $::gitlab::params::service_name,
  $service_restart     = $::gitlab::params::service_restart,
  $service_start       = $::gitlab::params::service_start,
  $service_status      = $::gitlab::params::service_status,
  $service_stop        = $::gitlab::params::service_stop,
  $service_user        = $::gitlab::params::service_user,
  # gitlab specific
  $edition             = 'ce',
  $ci_external_url     = undef,
  $ci_nginx            = undef,
  $ci_nginx_eq_nginx   = false,
  $ci_redis            = undef,
  $ci_unicorn          = undef,
  $config_file         = $::gitlab::params::config_file,
  $external_url        = undef,
  $git                 = undef,
  $git_data_dir        = undef,
  $gitlab_ci           = undef,
  $gitlab_rails        = undef,
  $high_availability   = undef,
  $logging             = undef,
  $logrotate           = undef,
  $nginx               = undef,
  $postgresql          = undef,
  $redis               = undef,
  $secrets             = undef,
  $secrets_file        = $::gitlab::params::secrets_file,
  $shell               = undef,
  $sidekiq             = undef,
  $unicorn             = undef,
  $user                = undef,
  $web_server          = undef,
) inherits ::gitlab::params {

  # package installation handling
  validate_bool($manage_package_repo)
  # system service configuration
  validate_string($service_name)
  validate_bool($service_enable)
  validate_re($service_ensure, '^stopped|false|running|true$')
  validate_bool($service_manage)
  validate_string($service_user)
  validate_string($service_group)
  # gitlab specific
  validate_re($edition, [ '^ee$', '^ce$' ])
  validate_absolute_path($config_file)
  if $ci_nginx { validate_hash($ci_nginx) }
  validate_bool($ci_nginx_eq_nginx)
  if $ci_redis { validate_hash($ci_redis) }
  if $ci_unicorn { validate_hash($ci_unicorn) }
  if $ci_external_url { validate_string($ci_external_url) }
  validate_string($external_url)
  if $git  { validate_hash($git) }
  if $git_data_dir { validate_absolute_path($git_data_dir) }
  if $gitlab_ci { validate_hash($gitlab_ci) }
  if $gitlab_rails { validate_hash($gitlab_rails) }
  if $logging { validate_hash($logging) }
  if $logrotate { validate_hash($logrotate) }
  if $nginx { validate_hash($nginx) }
  if $postgresql { validate_hash($postgresql) }
  if $redis { validate_hash($redis) }
  if $secrets { validate_hash($secrets) }
  if $shell { validate_hash($shell) }
  if $sidekiq { validate_hash($sidekiq) }
  if $unicorn { validate_hash($unicorn) }
  if $user { validate_hash($user) }
  if $web_server { validate_hash($web_server) }
  if $high_availability { validate_hash($high_availability) }

  class { '::gitlab::install': } ->
  class { '::gitlab::config': } ~>
  class { '::gitlab::service': }

  contain ::gitlab::install
  contain ::gitlab::config
  contain ::gitlab::service

}
