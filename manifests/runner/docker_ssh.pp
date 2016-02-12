# == Define: gitlab::runner::docker
#
define gitlab::runner::docker_ssh (
  Optional[String]           $token                     = undef,
  Optional[String ]          $url                       = undef,
  Optional[Boolean]          $run_untagged              = undef,
  Optional[Boolean]          $locked                    = undef,
  Optional[Array[String]]    $tags                      = undef,
  Optional[String]           $host                      = undef,
  Optional[String]           $cert_path                 = undef,
  Optional[Boolean]          $tlsverify                 = undef,
  Optional[String]           $hostname                  = undef,
  Optional[String]           $image                     = undef,
  Optional[String]           $cpuset_cpus               = undef,
  Optional[Integer]          $cpus                      = undef,
  Optional[Array[String]]    $dns                       = undef,
  Optional[Array[String]]    $dns_search                = undef,
  Optional[Boolean]          $privileged                = undef,
  Optional[String]           $userns                    = undef,
  Optional[Boolean]          $cap_add                   = undef,
  Optional[Boolean]          $cap_drop                  = undef,
  Optional[String]           $security_opt              = undef,
  Optional[String]           $devices                   = undef,
  Optional[Boolean]          $disable_cache             = undef,
  Optional[String]           $volumes                   = undef,
  Optional[String]           $volume_driver             = undef,
  Optional[String]           $cache_dir                 = undef,
  Optional[String]           $extra_hosts               = undef,
  Optional[Array[String]]    $volumes_from              = undef,
  Optional[String]           $network_mode              = undef,
  Optional[Array[String]]    $links                     = undef,
  Optional[Array[String]]    $services                  = undef,
  Optional[Integer]          $wait_for_services_timeout = undef,
  Optional[Array[String]]    $allowed_images            = undef,
  Optional[Array[String]]    $allowed_services          = undef,
  Optional[String]           $pull_policy               = undef,
  Optional[Integer]          $shm_size                  = undef,
  Optional[String]           $ssh_user                  = undef,
  Optional[String]           $ssh_password              = undef,
  Optional[String]           $ssh_host                  = undef,
  Optional[Integer[0,65535]] $ssh_port                  = undef,
  Optional[String]           $ssh_identity_file         = undef,
) {
  include ::gitlab::cirunner::docker_ssh
  $executor_cmd = '--executor docker_ssh'
  $_name        = "docker_ssh_${name}"
  $name_cmd     = "-n ${_name}"
  $token_cmd = ::gitlab::cirunner::cmd_str(
    'registration-token',
    [$token, $gitlab::cirunner::docker_ssh::default_token,
    $::gitlab::cirunner::default_token]
  )
  $url_cmd = ::gitlab::cirunner::cmd_str(
    'url',
    [$url, $gitlab::cirunner::docker_ssh::default_url,
    $::gitlab::cirunner::default_url]
  )
  $run_untagged_cmd = ::gitlab::cirunner::cmd_str(
    'run-untagged',
    [$run_untagged, $gitlab::cirunner::docker_ssh::default_run_untagged,
    $::gitlab::cirunner::default_run_untagged]
  )
  $locked_cmd = ::gitlab::cirunner::cmd_str(
    'locked',
    [$locked, $gitlab::cirunner::docker_ssh::default_locked,
    $::gitlab::cirunner::default_locked]
  )
  $tags_cmd = ::gitlab::cirunner::cmd_str(
    'tags',
    [$tags, $gitlab::cirunner::docker_ssh::default_tags,
    $::gitlab::cirunner::default_tags]
  )
  $host_cmd = ::gitlab::cirunner::cmd_str(
    'docker-host',
    [$host, $gitlab::cirunner::docker_ssh::default_host]
  )
  $tlsverify_cmd = ::gitlab::cirunner::cmd_str(
    'docker-tlsverify',
    [$tlsverify, $gitlab::cirunner::docker_ssh::default_tlsverify]
  )
  $hostname_cmd = ::gitlab::cirunner::cmd_str(
    'docker-hostname',
    [$hostname, $gitlab::cirunner::docker_ssh::default_hostname]
  )
  $image_cmd = ::gitlab::cirunner::cmd_str(
    'docker-image',
    [$image, $gitlab::cirunner::docker_ssh::default_image]
  )
  $cpuset_cpus_cmd = ::gitlab::cirunner::cmd_str(
    'docker-cpuset-cpus',
    [$cpuset_cpus, $gitlab::cirunner::docker_ssh::default_cpuset_cpus]
  )
  $cpus_cmd = ::gitlab::cirunner::cmd_str(
    'docker-cpus',
    [$cpus, $gitlab::cirunner::docker_ssh::default_cpus]
  )
  $dns_cmd = ::gitlab::cirunner::cmd_str(
    'docker-dns',
    [$dns, $gitlab::cirunner::docker_ssh::default_dns]
  )
  $dns_search_cmd = ::gitlab::cirunner::cmd_str(
    'docker-dns-search',
    [$dns_search, $gitlab::cirunner::docker_ssh::default_dns_search]
  )
  $privileged_cmd = ::gitlab::cirunner::cmd_str(
    'docker-privileged',
    [$privileged, $gitlab::cirunner::docker_ssh::default_privileged]
  )
  $userns_cmd = ::gitlab::cirunner::cmd_str(
    'docker-userns',
    [$userns, $gitlab::cirunner::docker_ssh::default_userns]
  )
  $cap_add_cmd = ::gitlab::cirunner::cmd_str(
    'docker-cap-add',
    [$cap_add, $gitlab::cirunner::docker_ssh::default_cap_add]
  )
  $cap_drop_cmd = ::gitlab::cirunner::cmd_str(
    'docker-cap-drop',
    [$cap_drop, $gitlab::cirunner::docker_ssh::default_cap_drop]
  )
  $security_opt_cmd = ::gitlab::cirunner::cmd_str(
    'docker-security-opt',
    [$security_opt, $gitlab::cirunner::docker_ssh::default_security_opt]
  )
  $devices_cmd = ::gitlab::cirunner::cmd_str(
    'docker-devices',
    [$devices, $gitlab::cirunner::docker_ssh::default_devices]
  )
  $disable_cache_cmd = ::gitlab::cirunner::cmd_str(
    'docker-disable-cache',
    [$disable_cache, $gitlab::cirunner::docker_ssh::default_disable_cache]
  )
  $volume_driver_cmd = ::gitlab::cirunner::cmd_str(
    'docker-volume-driver',
    [$volume_driver, $gitlab::cirunner::docker_ssh::default_volume_driver]
  )
  $extra_hosts_cmd = ::gitlab::cirunner::cmd_str(
    'docker-extra-hosts',
    [$extra_hosts, $gitlab::cirunner::docker_ssh::default_extra_hosts]
  )
  $volumes_from_cmd = ::gitlab::cirunner::cmd_str(
    'docker-volumes-from',
    [$volumes_from, $gitlab::cirunner::docker_ssh::default_volumes_from]
  )
  $network_mode_cmd = ::gitlab::cirunner::cmd_str(
    'docker-network-mode',
    [$network_mode, $gitlab::cirunner::docker_ssh::default_network_mode]
  )
  $links_cmd = ::gitlab::cirunner::cmd_str(
    'docker-links',
    [$links, $gitlab::cirunner::docker_ssh::default_links]
  )
  $services_cmd = ::gitlab::cirunner::cmd_str(
    'docker-services',
    [$services, $gitlab::cirunner::docker_ssh::default_services]
  )
  $wait_for_services_timeout_cmd = ::gitlab::cirunner::cmd_str(
    'docker-wait-for-services-timeout',
    [$wait_for_services_timeout, $gitlab::cirunner::docker_ssh::default_wait_for_services_timeout]
  )
  $allowed_images_cmd = ::gitlab::cirunner::cmd_str(
    'docker-allowed-images',
    [$allowed_images, $gitlab::cirunner::docker_ssh::default_allowed_images]
  )
  $allowed_services_cmd = ::gitlab::cirunner::cmd_str(
    'docker-allowed-services',
    [$allowed_services, $gitlab::cirunner::docker_ssh::default_allowed_services]
  )
  $pull_policy_cmd = ::gitlab::cirunner::cmd_str(
    'docker-pull-policy',
    [$pull_policy, $gitlab::cirunner::docker_ssh::default_pull_policy]
  )
  $shm_size_cmd = ::gitlab::cirunner::cmd_str(
    'docker-shm-size',
    [$shm_size, $gitlab::cirunner::docker_ssh::default_shm_size]
  )
  $ssh_user_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-user',
    [$ssh_user, $gitlab::cirunner::docker_ssh::default_ssh_user]
  )
  $ssh_password_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-password',
    [$ssh_password, $gitlab::cirunner::docker_ssh::default_ssh_password]
  )
  $ssh_host_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-host',
    [$ssh_host, $gitlab::cirunner::docker_ssh::default_ssh_host]
  )
  $ssh_port_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-port',
    [$ssh_port, $gitlab::cirunner::docker_ssh::default_ssh_port]
  )
  $ssh_identity_file_cmd = ::gitlab::cirunner::cmd_str(
    'ssh-identity-file',
    [$ssh_identity_file, $gitlab::cirunner::docker_ssh::default_ssh_identity_file]
  )
  $parameters_string = [
    $executor_cmd, $token_cmd, $url_cmd, $name_cmd, $run_untagged_cmd, $locked_cmd,
    $tags_cmd, $host_cmd, $tlsverify_cmd, $hostname_cmd, $image_cmd,
    $cpuset_cpus_cmd, $cpus_cmd, $dns_cmd, $dns_search_cmd, $privileged_cmd,
    $userns_cmd, $cap_add_cmd, $cap_drop_cmd, $security_opt_cmd, $devices_cmd,
    $disable_cache_cmd, $volume_driver_cmd, $extra_hosts_cmd, $volumes_from_cmd,
    $network_mode_cmd, $links_cmd, $services_cmd, $wait_for_services_timeout_cmd,
    $allowed_images_cmd, $allowed_services_cmd, $pull_policy_cmd, $shm_size_cmd,
    $ssh_user_cmd, $ssh_password_cmd, $ssh_host_cmd, $ssh_port_cmd,
    $ssh_identity_file_cmd,
  ].join(' ')
  # Execute gitlab ci multirunner register
  exec {"Register_runner_${title}":
    command => "/usr/bin/gitlab-ci-multi-runner register ${parameters_string}",
    unless  => "/bin/grep ${_name} ${::gitlab::cirunner::conf_file}",
  }
}
