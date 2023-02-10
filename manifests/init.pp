# @summary This module installs and configures Gitlab with the Omnibus package.
#
# @param package_ensure Can be used to choose exact package version to install.
# @param service_name Name of the system service.
# @param service_enable Run the system service on boot.
# @param service_exec The service executable path. Provide this variable value only if the service executable path would be a subject of change in future GitLab versions for any reason.
# @param service_ensure Should Puppet start the service?
# @param service_manage Should Puppet manage the service?
# @param service_provider_restart Should Puppet restart the gitlab systemd service?
# @param service_user Owner of the config file.
# @param service_group Group of the config file.
# @param rake_exec The gitlab-rake executable path. You should not need to change this path.
# @param edition **Deprecated**: See `manage_upstream_edition`
# @param manage_upstream_edition One of [ 'ce', 'ee', 'disabled' ]. Manage the installation of an upstream Gitlab Omnibus edition to install.
# @param config_manage Should Puppet manage the config?
# @param config_file Path of the Gitlab Omnibus config file.
# @param config_show_diff Whether show the diff in the log or not.
# @param alertmanager Hash of 'alertmanager' config parameters.
# @param ci_redis Hash of 'ci_redis' config parameters.
# @param ci_unicorn Hash of 'ci_unicorn' config parameters.
# @param external_url External URL of Gitlab.
# @param external_port External PORT of Gitlab.
# @param geo_postgresql Hash of 'geo_postgresql' config parameters.
# @param geo_logcursor Hash of 'geo_logcursor' config parameters.
# @param geo_primary_role Boolean to enable Geo primary role
# @param geo_secondary Hash of 'geo_secondary' config parameters.
# @param geo_secondary_role Boolean to enable Geo secondary role
# @param git Hash of 'omnibus_gitconfig' config parameters.
# @param gitaly Hash of 'omnibus_gitconfig' config parameters.
# @param git_data_dirs Hash of git data directories
# @param gitlab_git_http_server Hash of 'gitlab_git_http_server' config parameters.
# @param gitlab_ci Hash of 'gitlab_ci' config parameters.
# @param gitlab_kas Hash of 'gitlab_kas' config parameters.
# @param gitlab_pages Hash of 'gitlab_pages' config parameters.
# @param gitlab_rails Hash of 'gitlab_pages' config parameters.
# @param gitlab_workhorse Hash of 'gitlab_workhorse' config parameters.
# @param grafana Hash of 'grafana' config parameters.
# @param logging Hash of 'logging' config parameters.
# @param letsencrypt Hash of 'letsencrypt' config parameters.
# @param package Hash of 'package' config parameters.
# @param logrotate Hash of 'logrotate' config parameters.
# @param manage_storage_directories Hash of 'manage_storage_directories' config parameters.
# @param manage_accounts Hash of 'manage_accounts' config parameters.
# @param mattermost_external_url External URL of Mattermost.
# @param mattermost Hash of 'mattmost' config parameters.
# @param mattermost_nginx Hash of 'mattmost_nginx' config parameters.
# @param mattermost_nginx_eq_nginx Replicate the Mattermost Nginx config from the Gitlab Nginx config.
# @param nginx Hash of 'nginx' config parameters.
# @param node_exporter Hash of 'node_exporter' config parameters.
# @param redis_exporter Hash of 'redis_exporter' config parameters.
# @param postgres_exporter Hash of 'postgres_exporter' config parameters.
# @param pgbouncer_exporter Hash of 'pgbouncer_exporter' config parameters.
# @param gitlab_monitor Deprecated if using Gitlab > 12.3 and < 13.0, unsupported by gitlab omnibus using Gitlab 13+. Hash of 'gitlab_monitor' config parameters.
# @param gitlab_exporter Hash of 'gitlab_exporter' config parameters.
# @param pages_external_url External URL of Gitlab Pages.
# @param pages_nginx Hash of 'pages_nginx' config parameters.
# @param pages_nginx_eq_nginx Replicate the Pages Nginx config from the Gitlab Nginx config.
# @param postgresql Hash of 'postgresql' config parameters.
# @param prometheus Hash of 'prometheus' config parameters.
# @param prometheus_monitoring_enable Enable/disable prometheus support.
# @param redis Hash of 'redis' config parameters.
# @param redis_master_role To enable Redis master role for the node.
# @param redis_slave_role To enable Redis slave role for the node.
# @param redis_sentinel_role To enable sentinel role for the node.
# @param registry Hash of 'registry' config parameters.
# @param registry_external_url External URL of Registry
# @param registry_nginx Hash of 'registry_nginx' config parameters.
# @param registry_nginx_eq_nginx Replicate the registry Nginx config from the Gitlab Nginx config.
# @param roles Array of roles when using a HA or Geo enabled GitLab configuration. See: https://docs.gitlab.com/omnibus/roles/README.html for acceptable values
# @param sentinel Hash of 'sentinel' config parameters.
# @param shell Hash of 'gitlab_shell' config parameters.
# @param sidekiq Hash of 'sidekiq' config parameters
# @param sidekiq_cluster Hash of 'sidekiq_cluster' config parameters.
# @param skip_auto_migrations Deprecated if using Gitlab > 10.6.4 and < 11.0.0, unsupported by gitlab omnibus using gitlab 11+. Use skip_auto_reconfigure
# @param skip_auto_reconfigure Utilized for Zero Downtime Updates, See: https://docs.gitlab.com/omnibus/update/README.html#zero-downtime-updates
# @param skip_post_deployment_migrations Adds SKIP_POST_DEPLOYMENT_MIGRATIONS=true to the execution of gitlab-ctl reconfigure. Used for zero-downtime updates
# @param store_git_keys_in_db Enable or disable Fast Lookup of authorized SSH keys in the database. See: https://docs.gitlab.com/ee/administration/operations/fast_ssh_key_lookup.html
# @param source_config_file Override Hiera config with path to gitlab.rb config file
# @param unicorn Hash of 'unicorn' config parameters.
# @param puma Hash of 'puma' config parameters.
# @param user Hash of 'user' config parameters.
# @param web_server Hash of 'web_server' config parameters.
# @param high_availability Hash of 'high_availability' config parameters.
# @param backup_cron_enable Boolean to enable the daily backup cron job
# @param backup_cron_minute The minute when to run the daily backup cron job
# @param backup_cron_hour The hour when to run the daily backup cron job
# @param backup_cron_skips Array of items to skip valid values: db, uploads, repositories, builds, artifacts, lfs, registry, pages
# @param package_name The internal packaging system's name for the package. This name will automatically be changed by the gitlab::edition parameter. Can be overridden for the purposes of installing custom compiled version of gitlab-omnibus.
# @param manage_package Should the GitLab package be managed?
# @param repository_configuration A hash of repository types and attributes for configuraiton the gitlab package repositories. See docs in README.md
# @param manage_omnibus_repository Set to false if you wish to manage gitlab without configuring the package repository
# @param pgpass_file_location Path to location of .pgpass file used by consul to authenticate with pgbouncer database
# @param pgpass_file_ensure Create .pgpass file for pgbouncer authentication. When set to present requires valid value for pgbouncer_password.
# @param pgbouncer_password Password for the gitlab-consul database user in the pgbouncer database
class gitlab (
  Hash                                $repository_configuration,
  # package configuration
  String                              $package_ensure                  = 'installed',
  Optional[String]                    $edition                         = undef,
  Enum['ce', 'ee', 'disabled']        $manage_upstream_edition         = 'ce',
  Boolean                             $manage_omnibus_repository       = true,
  # system service configuration
  Boolean                             $service_enable                  = true,
  Enum['stopped', 'false', 'running', 'true'] $service_ensure        = 'running', # lint:ignore:quoted_booleans
  Boolean                             $service_manage                  = false,
  Boolean                             $service_provider_restart        = false,
  String                              $service_name                    = 'gitlab-runsvdir',
  String                              $service_exec                    = '/usr/bin/gitlab-ctl',
  String                              $service_user                    = 'root',
  String                              $service_group                   = 'root',
  # gitlab specific
  String                              $rake_exec                       = '/usr/bin/gitlab-rake',
  Optional[Hash]                      $alertmanager                    = undef,
  Optional[Hash]                      $ci_redis                        = undef,
  Optional[Hash]                      $ci_unicorn                      = undef,
  Boolean                             $config_manage                   = true,
  Stdlib::Absolutepath                $config_file                     = '/etc/gitlab/gitlab.rb',
  Boolean                             $config_show_diff                = false,
  Optional[Hash]                      $consul                          = undef,
  Stdlib::Absolutepath                $custom_hooks_dir                = '/opt/gitlab/embedded/service/gitlab-shell/hooks',
  Stdlib::Absolutepath                $system_hooks_dir                = '/opt/gitlab/embedded/service/gitlab-rails/file_hooks',
  Stdlib::Httpurl                     $external_url                    = "http://${facts['networking']['fqdn']}",
  Optional[Integer[1, 65565]]         $external_port                   = undef,
  Optional[Hash]                      $geo_postgresql                  = undef,
  Optional[Hash]                      $geo_logcursor                   = undef,
  Boolean                             $geo_primary_role                = false,
  Optional[Hash]                      $geo_secondary                   = undef,
  Boolean                             $geo_secondary_role              = false,
  Optional[Hash]                      $git                             = undef,
  Optional[Hash]                      $gitaly                          = undef,
  Optional[Hash]                      $git_data_dirs                   = undef,
  Optional[Hash]                      $gitlab_git_http_server          = undef,
  Optional[Hash]                      $gitlab_ci                       = undef,
  Optional[Hash]                      $gitlab_kas                      = undef,
  Optional[Hash]                      $gitlab_pages                    = undef,
  Optional[Hash]                      $gitlab_rails                    = undef,
  Optional[Hash]                      $grafana                         = undef,
  Optional[Hash]                      $high_availability               = undef,
  Optional[Hash]                      $logging                         = undef,
  Optional[Hash]                      $letsencrypt                     = undef,
  Optional[Hash[String[1], Scalar]]   $package                         = undef,
  Optional[Hash]                      $logrotate                       = undef,
  Optional[Hash]                      $manage_storage_directories      = undef,
  Optional[Hash]                      $manage_accounts                 = undef,
  Boolean                             $manage_package                  = true,
  Optional[Hash]                      $mattermost                      = undef,
  Optional[String]                    $mattermost_external_url         = undef,
  Optional[Hash]                      $mattermost_nginx                = undef,
  Boolean                             $mattermost_nginx_eq_nginx       = false,
  Optional[Hash]                      $nginx                           = undef,
  Optional[Hash]                      $node_exporter                   = undef,
  Optional[Hash]                      $redis_exporter                  = undef,
  Optional[String]                    $pgbouncer_password              = undef,
  Enum['absent', 'present']           $pgpass_file_ensure              = 'absent',
  Stdlib::Absolutepath                $pgpass_file_location            = '/home/gitlab-consul/.pgpass',
  Optional[Hash]                      $postgres_exporter               = undef,
  Optional[Hash]                      $pgbouncer_exporter              = undef,
  Optional[Hash]                      $gitlab_monitor                  = undef,
  Optional[Hash]                      $gitlab_exporter                 = undef,
  Optional[String]                    $package_name                    = undef,
  Optional[String]                    $pages_external_url              = undef,
  Optional[Hash]                      $pages_nginx                     = undef,
  Boolean                             $pages_nginx_eq_nginx            = false,
  Optional[Hash]                      $pgbouncer                       = undef,
  Optional[Hash]                      $postgresql                      = undef,
  Optional[Hash]                      $prometheus                      = undef,
  Optional[Boolean]                   $prometheus_monitoring_enable    = undef,
  Optional[Hash]                      $redis                           = undef,
  Optional[Boolean]                   $redis_master_role               = undef,
  Optional[Boolean]                   $redis_slave_role                = undef,
  Optional[Boolean]                   $redis_sentinel_role             = undef,
  Optional[Hash]                      $registry                        = undef,
  Optional[String]                    $registry_external_url           = undef,
  Optional[Hash]                      $registry_nginx                  = undef,
  Boolean                             $registry_nginx_eq_nginx         = false,
  Optional[Hash]                      $repmgr                          = undef,
  Optional[Array]                     $roles                           = undef,
  Optional[Hash]                      $sentinel                        = undef,
  Boolean                             $skip_post_deployment_migrations = false,
  Optional[Hash]                      $shell                           = undef,
  Optional[Hash]                      $sidekiq                         = undef,
  Optional[Hash]                      $sidekiq_cluster                 = undef,
  Enum['present', 'absent']           $skip_auto_reconfigure           = 'absent',
  Optional                            $skip_auto_migrations            = undef,
  Optional[Stdlib::Absolutepath]      $source_config_file              = undef,
  Boolean                             $store_git_keys_in_db            = false,
  Optional[Hash]                      $unicorn                         = undef,
  Optional[Hash]                      $puma                            = undef,
  Optional[Hash]                      $gitlab_workhorse                = undef,
  Optional[Hash]                      $user                            = undef,
  Optional[Hash]                      $web_server                      = undef,
  Boolean                             $backup_cron_enable              = false,
  Integer[0,59]                       $backup_cron_minute              = 0,
  Integer[0,23]                       $backup_cron_hour                = 2,
  Array                               $backup_cron_skips               = [],
  Hash                                $custom_hooks                    = {},
  Hash                                $global_hooks                    = {},
  Hash[String[1],Hash[String[1],Any]] $system_hooks                    = {},
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

  $system_hooks.each |$name, $options| {
    gitlab::system_hook { $name:
      * => $options,
    }
  }
}
