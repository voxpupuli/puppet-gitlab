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
# [*package_pin*]
#   Default: false
#   Create an apt pin for package_ensure version.
#
# [*manage_package_repo*]
#   Default: true
#   Should the official package repository be managed?
#
# [*manage_package*]
#   Default: true
#   Should the GitLab package be managed?
#
# [*service_name*]
#   Default: gitlab-runsvdir
#   Name of the system service.
#
# [*service_enable*]
#   Default: true
#   Run the system service on boot.
#
# [*service_exec*]
#   Default: '/usr/bin/gitlab-ctl'
#   The service executable path.
#   Provide this variable value only if the service executable path
#   would be a subject of change in future GitLab versions for any reason.
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
# [*rake_exec*]
#   Default: '/usr/bin/gitlab-rake'
#   The gitlab-rake executable path. 
#   You should not need to change this path.
#
# [*edition*]
#   Default: ce
#   Gitlab edition to install. ce or ee.
#
# [*config_manage*]
#   Default: true
#   Should Puppet manage the config?
#
# [*config_file*]
#   Default: /etc/gitlab/gitlab.rb
#   Path of the Gitlab Omnibus config file.
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
#   Default: http://$fqdn
#   External URL of Gitlab.
#
# [*external_port*]
#   Default: undef
#   External PORT of Gitlab.
#
# [*geo_postgresql*]
#   Default: undef
#   Hash of 'geo_postgresql' config parameters.
#
# [*geo_primary_role*]
#   Default: false
#   Boolean to enable Geo primary role
#
# [*geo_secondary*]
#   Default: undef
#   Hash of 'geo_secondary' config parameters.
#
# [*geo_secondary_role*]
#   Default: false
#   Boolean to enable Geo secondary role
#
# [*git*]
#   Default: undef
#   Hash of 'omnibus_gitconfig' config parameters.
#
# [*gitaly*]
#   Default: undef
#   Hash of 'Gitaly' config parameters.
#
# [*git_data_dir*]
#   Default: undef
#   Git data dir
#
# [*gitlab_git_http_server*]
#   Default: undef
#   Hash of 'gitlab_git_http_server' config parameters.
#
# [*gitlab_ci*]
#   Default: undef
#   Hash of 'gitlab_ci' config parameters.
#
# [*gitlab_pages*]
#   Default: undef
#   Hash of 'gitlab_pages' config parameters.
#
# [*gitlab_rails*]
#   Default: undef
#   Hash of 'gitlab_rails' config parameters.
#
# [*gitlab_workhorse*]
#   Default: undef
#   Hash of 'gitlab_workhorse' config parameters.
#
# [*logging*]
#   Default: undef
#   Hash of 'logging' config parameters.
#
# [*logrotate*]
#   Default: undef
#   Hash of 'logrotate' config parameters.
#
# [*manage_storage_directories*]
#   Default: undef
#   Hash of 'manage_storage_directories' config parameters.
#
# [*manage_accounts*]
#   Default: undef
#   Hash of 'manage_accounts' config parameters.
#
# [*mattermost_external_url*]
#   Default: undef
#   External URL of Mattermost.
#
# [*mattermost*]
#   Default: undef
#   Hash of 'mattmost' config parameters.
#
# [*mattermost_nginx*]
#   Default: undef
#   Hash of 'mattmost_nginx' config parameters.
#
# [*mattermost_nginx_eq_nginx*]
#   Default: false
#   Replicate the Mattermost Nginx config from the Gitlab Nginx config.
#
# [*nginx*]
#   Default: undef
#   Hash of 'nginx' config parameters.
#
# [*node_exporter*]
#   Default: undef
#   Hash of 'node_exporter' config parameters.
#
# [*redis_exporter*]
#   Default: undef
#   Hash of 'redis_exporter' config parameters.
#
# [*postgres_exporter*]
#   Default: undef
#   Hash of 'postgres_exporter' config parameters.
#
# [*gitlab_monitor*]
#   Default: undef
#   Hash of 'gitlab_monitor' config parameters.
#
# [*pages_external_url*]
#   Default: undef
#   External URL of Gitlab Pages.
#
# [*pages_nginx*]
#   Default: undef
#   Hash of 'pages_nginx' config parameters.
#
# [*pages_nginx_eq_nginx*]
#   Default: false
#   Replicate the Pages Nginx config from the Gitlab Nginx config.
#
# [*postgresql*]
#   Default: undef
#   Hash of 'postgresql' config parameters.
#
# [*prometheus*]
#   Default: undef
#   Hash of 'prometheus' config parameters.
#
# [*prometheus_monitoring_enable*]
#   Default: undef
#   Enable/disable prometheus support.
#
# [*redis*]
#   Default: undef
#   Hash of 'redis' config parameters.
#
# [*redis_master_role*]
#   Default: undef
#   To enable Redis master role for the node.
#
# [*redis_slave_role*]
#   Default: undef
#   To enable Redis slave role for the node.
#
# [*redis_sentinel_role*]
#   Default: undef
#   To enable sentinel role for the node.
#
# [*registry*]
#   Default: undef
#   Hash of 'registry' config parameters.
#
# [*registry_external_url*]
#  Default: undef
#  External URL of Registry
#
# [*registry_nginx*]
#  Default: undef
#  Hash of 'registry_nginx' config parameters.
#
# [*registry_nginx_eq_nginx*]
#   Default: false
#   Replicate the registry Nginx config from the Gitlab Nginx config.
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
# [*sentinel*]
#   Default: undef
#   Hash of 'sentinel' config parameters.
#
# [*shell*]
#   Default: undef
#   Hash of 'gitlab_shell' config parameters.
#
# [*sidekiq*]
#   Default: undef
#   Hash of 'sidekiq' config parameters.
#
# [*sidekiq_cluster*]
#   Default: undef
#   Hash of 'sidekiq_cluster' config parameters.
#
# [*skip_auto_migrations*]
#   Default: undef
#   Enable or disable auto migrations. undef keeps the current state on the system.
#
# [*source_config_file*]
#   Default: undef
#   Override Hiera config with path to gitlab.rb config file.
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
# [*backup_cron_enable*]
#   Default: false
#   Boolean to enable the daily backup cron job
#
# [*backup_cron_minute*]
#   Default: 0
#   The minute when to run the daily backup cron job
#
# [*backup_cron_hour*]
#   Default: 2
#   The hour when to run the daily backup cron job
#
# [*backup_cron_skips*]
#   Default: []
#   Array of items to skip
#   valid values: db, uploads, repositories, builds,
#                 artifacts, lfs, registry, pages
#
# === Examples
#
#  class { 'gitlab':
#    edition           => 'ee',
#    external_url      => 'https://gitlab.mydomain.tld',
#    nginx             => { redirect_http_to_https => true },
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
  $manage_package = $::gitlab::params::manage_package,
  $package_ensure = $::gitlab::params::package_ensure,
  $package_pin = $::gitlab::params::package_pin,
  # system service configuration
  $service_enable = $::gitlab::params::service_enable,
  $service_ensure = $::gitlab::params::service_ensure,
  $service_group = $::gitlab::params::service_group,
  $service_hasrestart = $::gitlab::params::service_hasrestart,
  $service_hasstatus = $::gitlab::params::service_hasstatus,
  $service_manage = $::gitlab::params::service_manage,
  $service_name = $::gitlab::params::service_name,
  $service_exec = $::gitlab::params::service_exec,
  $service_restart = $::gitlab::params::service_restart,
  $service_start = $::gitlab::params::service_start,
  $service_status = $::gitlab::params::service_status,
  $service_stop = $::gitlab::params::service_stop,
  $service_user = $::gitlab::params::service_user,
  # gitlab specific
  $rake_exec = $::gitlab::params::rake_exec,
  $edition = 'ce',
  $ci_redis = undef,
  $ci_unicorn = undef,
  $config_manage = $::gitlab::params::config_manage,
  $config_file = $::gitlab::params::config_file,
  $custom_hooks_dir = undef,
  $external_url = $::gitlab::params::external_url,
  $external_port = undef,
  $geo_postgresql = undef,
  $geo_primary_role = false,
  $geo_secondary = undef,
  $geo_secondary_role = false,
  $git = undef,
  $gitaly = undef,
  $git_data_dir = undef,
  $git_data_dirs = undef,
  $gitlab_git_http_server = undef,
  $gitlab_ci = undef,
  $gitlab_pages = undef,
  $gitlab_rails = undef,
  $high_availability = undef,
  $logging = undef,
  $logrotate = undef,
  $manage_storage_directories = undef,
  $manage_accounts = undef,
  $mattermost = undef,
  $mattermost_external_url = undef,
  $mattermost_nginx = undef,
  $mattermost_nginx_eq_nginx = false,
  $nginx = undef,
  $node_exporter = undef,
  $redis_exporter = undef,
  $postgres_exporter = undef,
  $gitlab_monitor = undef,
  $pages_external_url = undef,
  $pages_nginx = undef,
  $pages_nginx_eq_nginx = false,
  $postgresql = undef,
  $prometheus = undef,
  $prometheus_monitoring_enable = undef,
  $redis = undef,
  $redis_master_role = undef,
  $redis_slave_role = undef,
  $redis_sentinel_role = undef,
  $registry = undef,
  $registry_external_url = undef,
  $registry_nginx = undef,
  $registry_nginx_eq_nginx = false,
  $secrets = undef,
  $secrets_file = $::gitlab::params::secrets_file,
  $sentinel = undef,
  $shell = undef,
  $sidekiq = undef,
  $sidekiq_cluster = undef,
  $skip_auto_migrations = undef,
  $source_config_file = undef,
  $unicorn = undef,
  $gitlab_workhorse = undef,
  $user = undef,
  $web_server = undef,
  $backup_cron_enable = false,
  $backup_cron_minute = 0,
  $backup_cron_hour = 2,
  $backup_cron_skips = [],
  $custom_hooks = {},
  $global_hooks = {},
) inherits ::gitlab::params {

  # package installation handling
  validate_bool($manage_package_repo)
  validate_bool($manage_package)
  # system service configuration
  validate_string($service_name)
  validate_bool($service_enable)
  validate_re($service_ensure, '^stopped|false|running|true$')
  validate_bool($service_manage)
  validate_string($service_user)
  validate_string($service_group)
  # gitlab specific
  validate_re($edition, [ '^ee$', '^ce$' ])
  validate_bool($config_manage)
  validate_absolute_path($config_file)
  if $custom_hooks_dir { validate_absolute_path($custom_hooks_dir) }
  if $geo_postgresql { validate_hash($geo_postgresql) }
  validate_bool($geo_primary_role)
  if $geo_secondary { validate_hash($geo_secondary) }
  validate_bool($geo_secondary_role)
  if $ci_redis { validate_hash($ci_redis) }
  if $ci_unicorn { validate_hash($ci_unicorn) }
  validate_string($external_url)
  if $git  { validate_hash($git) }
  if $gitaly  { validate_hash($gitaly) }
  if $git_data_dir { validate_absolute_path($git_data_dir) }
  if $git_data_dirs { validate_hash($git_data_dirs) }
  if $gitlab_git_http_server { validate_hash($gitlab_git_http_server) }
  if $gitlab_pages { validate_hash($gitlab_pages) }
  if $gitlab_workhorse { validate_hash($gitlab_workhorse) }
  if $gitlab_ci { validate_hash($gitlab_ci) }
  if $gitlab_rails { validate_hash($gitlab_rails) }
  if $logging { validate_hash($logging) }
  if $logrotate { validate_hash($logrotate) }
  if $manage_storage_directories { validate_hash($manage_storage_directories) }
  if $nginx { validate_hash($nginx) }
  if $mattermost { validate_hash($mattermost) }
  if $mattermost_external_url { validate_string($mattermost_external_url) }
  if $mattermost_nginx { validate_hash($mattermost_nginx) }
  validate_string($pages_external_url)
  if $pages_nginx { validate_hash($pages_nginx) }
  validate_bool($pages_nginx_eq_nginx)
  if $postgresql { validate_hash($postgresql) }
  if $prometheus_monitoring_enable != undef { validate_bool($prometheus_monitoring_enable) }
  if $redis { validate_hash($redis) }
  if $redis_master_role { validate_bool($redis_master_role) }
  if $redis_slave_role { validate_bool($redis_slave_role) }
  if $redis_sentinel_role { validate_bool($redis_sentinel_role) }
  if $registry { validate_hash($registry) }
  if $registry_nginx { validate_hash($registry_nginx) }
  validate_bool($registry_nginx_eq_nginx)
  if $registry_external_url { validate_string($registry_external_url) }
  if $secrets { validate_hash($secrets) }
  if $sentinel { validate_hash($sentinel) }
  if $shell { validate_hash($shell) }
  if $sidekiq { validate_hash($sidekiq) }
  if $sidekiq_cluster { validate_hash($sidekiq_cluster) }
  if $skip_auto_migrations != undef { validate_bool($skip_auto_migrations) }
  if $unicorn { validate_hash($unicorn) }
  if $user { validate_hash($user) }
  if $web_server { validate_hash($web_server) }
  if $high_availability { validate_hash($high_availability) }
  if $manage_accounts { validate_hash($manage_accounts) }
  validate_bool($backup_cron_enable)
  validate_integer($backup_cron_minute,59)
  validate_integer($backup_cron_hour,23)
  validate_array($backup_cron_skips)
  validate_hash($custom_hooks)
  validate_hash($global_hooks)

  class { '::gitlab::install': }
  -> class { '::gitlab::config': }
  ~> class { '::gitlab::service': }

  contain gitlab::install
  contain gitlab::config
  contain gitlab::service
 
  create_resources(gitlab::custom_hook, $custom_hooks)
  create_resources(gitlab::global_hook, $global_hooks)
}
