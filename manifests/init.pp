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
  $ci_external_url       = undef,
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

  # package installation handling
  #validate_re($package_ensure, '^installed|present|absent|purged|held|latest$')
  validate_string($package_repo_location)
  validate_string($package_repo_repos)
  validate_string($package_repo_key)
  validate_string($package_repo_key_src)
  validate_string($package_name)
  validate_bool($manage_package_repo)
  # system service configuration
  validate_string($service_name)
  validate_bool($service_enable)
  validate_re($service_ensure, '^stopped|false|running|true$')
  validate_bool($service_manage)
  validate_string($service_user)
  validate_string($service_group)
  # gitlab specific
  validate_absolute_path($config_file)
  if $ci_nginx { validate_hash($ci_nginx) }
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
  if $rails { validate_hash($rails) }
  if $redis { validate_hash($redis) }
  if $shell { validate_hash($shell) }
  if $sidekiq { validate_hash($sidekiq) }
  if $unicorn { validate_hash($unicorn) }
  if $user { validate_hash($user) }
  if $web_server { validate_hash($web_server) }

  class { '::gitlab::install': } ->
  class { '::gitlab::config': }
  #class { '::gitlab::config': } ~>
  class { '::gitlab::service': }

  contain ::gitlab::install
  contain ::gitlab::config
  contain ::gitlab::service

}
