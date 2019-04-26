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
#   Default: false
#   Should Puppet manage the service?

# [*service_provider_restart*]
#   Default: false
#   Should Puppet restart the gitlab systemd service?
#
# [*service_user*]
#   Default: root
#   Owner of the config file.
#
# [*service_group*]
#   Default: root
#   Group of the config file.
#
# [*rake_exec*]
#   Default: '/usr/bin/gitlab-rake'
#   The gitlab-rake executable path.
#   You should not need to change this path.
#
# [*edition*]
#   **Deprecated**: See `manage_upstream_edition`
#   Default: undef
#
# [*manage_upstream_edition*]
#   Default: 'ce'
#   One of [ 'ce', 'ee', 'disabled' ]
#   Manage the installation of an upstream Gitlab Omnibus edition to install.
#
# [*config_manage*]
#   Default: true
#   Should Puppet manage the config?
#
# [*config_file*]
#   Default: /etc/gitlab/gitlab.rb
#   Path of the Gitlab Omnibus config file.
#
# [*alertmanager*]
#   Default: undef
#   Hash of 'alertmanager' config parameters.
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
# [*grafana*]
#   Default: undef
#   Hash of 'grafana' config parameters.
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
# [*skip_post_deployment_migrations*]
#   Default: false
#   Adds SKIP_POST_DEPLOYMENT_MIGRATIONS=true to the execution of gitlab-ctl reconfigure
#   Used for zero-downtime updates
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
# [*package_name*]
#   Default: 'gitlab-ce'
#   The internal packaging system's name for the package
#   This name will automatically be changed by the gitlab::edition parameter
#   Can be overridden for the purposes of installing custom compiled version of gitlab-omnibus
#
# [*manage_package*]
#   Default: true
#   Should the GitLab package be managed?
#
# [*repository_configuration*]
#   A hash of repository types and attributes for configuraiton the gitlab package repositories
#   See docs in README.md
#
# [*manage_omnibus_repository*]
#   Default: true
#   Set to false if you wish to manage gitlab without configuring the package repository
# [*pgpass_file_location*]
#   Default: '/home/gitlab-consul/.pgpass'
#   Path to location of .pgpass file used by consul to
#   authenticate with pgbouncer database
#
# [*pgpass_file_ensure*]
#   Default: 'absent'
#   Create .pgpass file for pgbouncer authentication
#   When set to present requires valid value for pgbouncer_password
#
# [*pgbouncer_password*]
#   Default: undef
#   Password for the gitlab-consul database user in the
#   pgbouncer database
#
class gitlab (
  Hash                           $repository_configuration,
  # package configuration
  String                         $package_ensure,
  Optional[String]               $edition,
  Enum['ce', 'ee', 'disabled']   $manage_upstream_edition,
  Boolean                        $manage_omnibus_repository,
  # system service configuration
  Boolean                        $service_enable,
  Enum['stopped', 'false', 'running', 'true'] $service_ensure, # lint:ignore:quoted_booleans
  Boolean                        $service_manage,
  Boolean                        $service_provider_restart,
  String                         $service_name,
  String                         $service_exec,
  String                         $service_user,
  String                         $service_group,
  # gitlab specific
  String                         $rake_exec,
  Optional[Hash]                 $alertmanager,
  Optional[Hash]                 $ci_redis,
  Optional[Hash]                 $ci_unicorn,
  Boolean                        $config_manage,
  Stdlib::Absolutepath           $config_file,
  Optional[Hash]                 $consul,
  Optional[String]               $custom_hooks_dir,
  Stdlib::Httpurl                $external_url,
  Optional[Integer[1, 65565]]    $external_port,
  Optional[Hash]                 $geo_postgresql,
  Boolean                        $geo_primary_role,
  Optional[Hash]                 $geo_secondary,
  Boolean                        $geo_secondary_role,
  Optional[Hash]                 $git,
  Optional[Hash]                 $gitaly,
  Optional[Hash]                 $git_data_dirs,
  Optional[Hash]                 $gitlab_git_http_server,
  Optional[Hash]                 $gitlab_ci,
  Optional[Hash]                 $gitlab_pages,
  Optional[Hash]                 $gitlab_rails,
  Optional[Hash]                 $grafana,
  Optional[Hash]                 $high_availability,
  Optional[Hash]                 $logging,
  Optional[Hash]                 $letsencrypt,
  Optional[Hash]                 $logrotate,
  Optional[Hash]                 $manage_storage_directories,
  Optional[Hash]                 $manage_accounts,
  Boolean                        $manage_package,
  Optional[Hash]                 $mattermost,
  Optional[String]               $mattermost_external_url,
  Optional[Hash]                 $mattermost_nginx,
  Boolean                        $mattermost_nginx_eq_nginx,
  Optional[Hash]                 $nginx,
  Optional[Hash]                 $node_exporter,
  Optional[Hash]                 $redis_exporter,
  Optional[String]               $pgbouncer_password,
  Enum['absent', 'present']      $pgpass_file_ensure,
  Stdlib::Absolutepath           $pgpass_file_location,
  Optional[Hash]                 $postgres_exporter,
  Optional[Hash]                 $gitlab_monitor,
  Optional[String]               $package_name,
  Optional[String]               $pages_external_url,
  Optional[Hash]                 $pages_nginx,
  Boolean                        $pages_nginx_eq_nginx,
  Optional[Hash]                 $pgbouncer,
  Optional[Hash]                 $postgresql,
  Optional[Hash]                 $prometheus,
  Optional[Boolean]              $prometheus_monitoring_enable,
  Optional[Hash]                 $redis,
  Optional[Boolean]              $redis_master_role,
  Optional[Boolean]              $redis_slave_role,
  Optional[Boolean]              $redis_sentinel_role,
  Optional[Hash]                 $registry,
  Optional[String]               $registry_external_url,
  Optional[Hash]                 $registry_nginx,
  Boolean                        $registry_nginx_eq_nginx,
  Optional[Hash]                 $repmgr,
  Optional[Array]                $roles,
  Optional[Hash]                 $sentinel,
  Boolean                        $skip_post_deployment_migrations,
  Optional[Hash]                 $shell,
  Optional[Hash]                 $sidekiq,
  Optional[Hash]                 $sidekiq_cluster,
  Enum['present', 'absent']      $skip_auto_reconfigure,
  Optional                       $skip_auto_migrations,
  Optional[Stdlib::Absolutepath] $source_config_file,
  Boolean                        $store_git_keys_in_db,
  Optional[Hash]                 $unicorn,
  Optional[Hash]                 $gitlab_workhorse,
  Optional[Hash]                 $user,
  Optional[Hash]                 $web_server,
  Boolean                        $backup_cron_enable,
  Integer[0,59]                  $backup_cron_minute,
  Integer[0,23]                  $backup_cron_hour,
  Array                          $backup_cron_skips,
  Hash                           $custom_hooks,
  Hash                           $global_hooks,
) {

  include gitlab::omnibus_package_repository

  contain gitlab::host_config
  contain gitlab::omnibus_config
  contain gitlab::install
  contain gitlab::service

  Class['gitlab::host_config']
  -> Class['gitlab::omnibus_config']
  -> Class['gitlab::install']
  -> Class['gitlab::service']

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
