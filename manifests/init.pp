# == Class: gitlab
#
# Full description of class gitlab here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
# === Examples
#
#  class { 'gitlab':
#    sample_parameter => 'sample value',
#  }
#
# === Authors
#
# vshn
#
# === Copyright
#
# Copyright 2015 vshn
#
class gitlab (
  # package installation handling
  $package_ensure        = $::gitlab::params::package_ensure,
  $package_name          = $::gitlab::params::package_name,
  $package_repo_location = $::gitlab::params::package_repo_location,
  $package_repo_repos    = $::gitlab::params::package_repo_repos,
  $package_repo_key      = $::gitlab::params::package_repo_key,
  $package_repo_key_src  = $::gitlab::params::package_repo_key_src,
  $manage_package_repo   = $::gitlab::params::manage_package_repo,
  # system service configuration
  $service_name          = $::gitlab::params::service_name,
  $service_enable        = $::gitlab::params::service_enable,
  $service_ensure        = $::gitlab::params::service_ensure,
  $service_manage        = $::gitlab::params::service_manage,
  $service_user          = $::gitlab::params::service_user,
  $service_group         = $::gitlab::params::service_group,
  # gitlab specific
  $config_file           = $::gitlab::params::config_file,
  $ci_nginx              = undef,
  $ci_redis              = undef,
  $ci_unicorn            = undef,
  $external_url          = undef,
  $git                   = undef,
  $git_data_dir          = undef,
  $gitlab_ci             = undef,
  $gitlab_rails          = undef,
  $logging               = undef,
  $logrotate             = undef,
  $nginx                 = undef,
  $postgresql            = undef,
  $rails                 = undef,
  $redis                 = undef,
  $shell                 = undef,
  $sidekiq               = undef,
  $unicorn               = undef,
  $user                  = undef,
  $web_server            = undef,
) inherits ::gitlab::params {

  # mandatory parameters
  # TODO validate all parameters
  validate_string($external_url)

  class { '::gitlab::install': } ->
  class { '::gitlab::config': } ~>
  class { '::gitlab::service': }

  contain ::gitlab::install
  contain ::gitlab::config
  contain ::gitlab::service

}
