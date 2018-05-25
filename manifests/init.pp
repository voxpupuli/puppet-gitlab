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
# [*git_data_dirs*]
#   Default: undef
#   Hash of git data directories
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
# [*letsencrypt*]
#   Default: undef
#   Hash of 'letsencrypt' config parameters.
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
# [*roles*]
#   Default: undef
#   Array of roles when using a HA or Geo enabled GitLab configuration
#   See: https://docs.gitlab.com/omnibus/roles/README.html for acceptable values
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
#   Deprecated if using Gitlab > 10.6.4 and < 11.0.0, unsupported by gitlab omnibus using gitlab 11+
#   Use skip_auto_reconfigure
#
# [*skip_auto_reconfigure*]
#   Default: undef
#   Utilized for Zero Downtime Updates, See: https://docs.gitlab.com/omnibus/update/README.html#zero-downtime-updates
#
# [*store_git_keys_in_db*]
#   Default: false
#   Enable or disable Fast Lookup of authorized SSH keys in the database
#   See: https://docs.gitlab.com/ee/administration/operations/fast_ssh_key_lookup.html
#
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
#    edition                                       => 'ee',
#    external_url                                  => 'https://gitlab.mydomain.tld',
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
  Boolean                        $manage_package_repo           = $::gitlab::params::manage_package_repo,
  Boolean                        $manage_package                = $::gitlab::params::manage_package,
  String                         $package_ensure                = $::gitlab::params::package_ensure,
  Boolean                        $package_pin                   = $::gitlab::params::package_pin,
  # system service configuration
  Boolean                        $service_enable                = $::gitlab::params::service_enable,
  Enum['stopped', 'false', 'running', 'true'] $service_ensure   = $::gitlab::params::service_ensure, # lint:ignore:quoted_booleans
  String                         $service_group                 = $::gitlab::params::service_group,
  Boolean                        $service_hasrestart            = $::gitlab::params::service_hasrestart,
  Boolean                        $service_hasstatus             = $::gitlab::params::service_hasstatus,
  Boolean                        $service_manage                = $::gitlab::params::service_manage,
  String                         $service_name                  = $::gitlab::params::service_name,
  String                         $service_exec                  = $::gitlab::params::service_exec,
  String                         $service_restart               = $::gitlab::params::service_restart,
  String                         $service_start                 = $::gitlab::params::service_start,
  String                         $service_status                = $::gitlab::params::service_status,
  String                         $service_stop                  = $::gitlab::params::service_stop,
  String                         $service_user                  = $::gitlab::params::service_user,
  # gitlab specific
  String                         $rake_exec                     = $::gitlab::params::rake_exec,
  Enum['ce', 'ee']               $edition                       = 'ce',
  Optional[Hash]                 $ci_redis                      = undef,
  Optional[Hash]                 $ci_unicorn                    = undef,
  Boolean                        $config_manage                 = $::gitlab::params::config_manage,
  Stdlib::Absolutepath           $config_file                   = $::gitlab::params::config_file,
  Optional[String]               $custom_hooks_dir              = undef,
  Stdlib::Httpurl                $external_url                  = $::gitlab::params::external_url,
  Optional[Integer[1, 65565]]    $external_port                 = undef,
  Optional[Hash]                 $geo_postgresql                = undef,
  Boolean                        $geo_primary_role              = false,
  Optional[Hash]                 $geo_secondary                 = undef,
  Boolean                        $geo_secondary_role            = false,
  Optional[Hash]                 $git                           = undef,
  Optional[Hash]                 $gitaly                        = undef,
  Optional[Hash]                 $git_data_dirs                 = undef,
  Optional[Hash]                 $gitlab_git_http_server        = undef,
  Optional[Hash]                 $gitlab_ci                     = undef,
  Optional[Hash]                 $gitlab_pages                  = undef,
  Optional[Hash]                 $gitlab_rails                  = undef,
  Optional[Hash]                 $high_availability             = undef,
  Optional[Hash]                 $logging                       = undef,
  Optional[Hash]                 $letsencrypt                   = undef,
  Optional[Hash]                 $logrotate                     = undef,
  Optional[Hash]                 $manage_storage_directories    = undef,
  Optional[Hash]                 $manage_accounts               = undef,
  Optional[Hash]                 $mattermost                    = undef,
  Optional[String]               $mattermost_external_url       = undef,
  Optional[Hash]                 $mattermost_nginx              = undef,
  Boolean                        $mattermost_nginx_eq_nginx     = false,
  Optional[Hash]                 $nginx                         = undef,
  Optional[Hash]                 $node_exporter                 = undef,
  Optional[Hash]                 $redis_exporter                = undef,
  Optional[Hash]                 $postgres_exporter             = undef,
  Optional[Hash]                 $gitlab_monitor                = undef,
  Optional[String]               $pages_external_url            = undef,
  Optional[Hash]                 $pages_nginx                   = undef,
  Boolean                        $pages_nginx_eq_nginx          = false,
  Optional[Hash]                 $postgresql                    = undef,
  Optional[Hash]                 $prometheus                    = undef,
  Optional[Boolean]              $prometheus_monitoring_enable  = undef,
  Optional[Hash]                 $redis                         = undef,
  Optional[Boolean]              $redis_master_role             = undef,
  Optional[Boolean]              $redis_slave_role              = undef,
  Optional[Boolean]              $redis_sentinel_role           = undef,
  Optional[Hash]                 $registry                      = undef,
  Optional[String]               $registry_external_url         = undef,
  Optional[Hash]                 $registry_nginx                = undef,
  Boolean                        $registry_nginx_eq_nginx       = false,
  Optional[Array]                $roles                         = undef,
  Optional[Hash]                 $secrets                       = undef,
  Stdlib::Absolutepath           $secrets_file                  = $::gitlab::params::secrets_file,
  Optional[Hash]                 $sentinel                      = undef,
  Optional[Hash]                 $shell                         = undef,
  Optional[Hash]                 $sidekiq                       = undef,
  Optional[Hash]                 $sidekiq_cluster               = undef,
  Enum['present', 'absent']      $skip_auto_reconfigure         = 'absent',
  Optional                       $skip_auto_migrations          = undef,
  Optional[Stdlib::Absolutepath] $source_config_file            = undef,
  Boolean                        $store_git_keys_in_db          = false,
  Optional[Hash]                 $unicorn                       = undef,
  Optional[Hash]                 $gitlab_workhorse              = undef,
  Optional[Hash]                 $user                          = undef,
  Optional[Hash]                 $web_server                    = undef,
  Boolean                        $backup_cron_enable            = false,
  Integer[0,59]                  $backup_cron_minute            = 0,
  Integer[0,23]                  $backup_cron_hour              = 2,
  Array                          $backup_cron_skips             = [],
  Hash                           $custom_hooks                  = {},
  Hash                           $global_hooks                  = {},
) inherits gitlab::params {

  contain gitlab::preinstall
  contain gitlab::install
  contain gitlab::config
  contain gitlab::service
  contain gitlab::backup

  $custom_hooks.each |$name, $options| {
    gitlab::custom_hook { $name:
      * => $options,
    }
  }

  $global_hooks.each |$name, $options| {
    gitlab::global_hook { $name:
      * => $options,
    }
  }
}
