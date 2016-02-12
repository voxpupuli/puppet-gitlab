# == Class: gitlab::cirunner::docker
#
class gitlab::cirunner::docker (
  Boolean                    $manage_docker                     = true,
  String                     $xz_package_name                   = 'xz-utils',
  String                     $default_image                     = 'ubuntu_trusty',
  Hash                       $docker_images                     = {},
  Hash                       $runners                           = {},
  Optional[String]           $default_token                     = undef,
  Optional[String]           $default_url                       = undef,
  Optional[Boolean]          $default_run_untagged              = undef,
  Optional[Boolean]          $default_locked                    = undef,
  Optional[Array[String]]    $default_tags                      = undef,
  Optional[String]           $default_host                      = undef,
  Optional[String]           $default_cert_path                 = undef,
  Optional[Boolean]          $default_tlsverify                 = undef,
  Optional[String]           $default_hostname                  = undef,
  Optional[String]           $default_cpuset_cpus               = undef,
  Optional[Integer]          $default_cpus                      = undef,
  Optional[Array[String]]    $default_dns                       = undef,
  Optional[Array[String]]    $default_dns_search                = undef,
  Optional[Boolean]          $default_privileged                = undef,
  Optional[String]           $default_userns                    = undef,
  Optional[Boolean]          $default_cap_add                   = undef,
  Optional[Boolean]          $default_cap_drop                  = undef,
  Optional[String]           $default_security_opt              = undef,
  Optional[String]           $default_devices                   = undef,
  Optional[Boolean]          $default_disable_cache             = undef,
  Optional[String]           $default_volumes                   = undef,
  Optional[String]           $default_volume_driver             = undef,
  Optional[String]           $default_cache_dir                 = undef,
  Optional[String]           $default_extra_hosts               = undef,
  Optional[Array[String]]    $default_volumes_from              = undef,
  Optional[String]           $default_network_mode              = undef,
  Optional[Array[String]]    $default_links                     = undef,
  Optional[Array[String]]    $default_services                  = undef,
  Optional[Integer]          $default_wait_for_services_timeout = undef,
  Optional[Array[String]]    $default_allowed_images            = undef,
  Optional[Array[String]]    $default_allowed_services          = undef,
  Optional[String]           $default_pull_policy               = undef,
  Optional[Integer]          $default_shm_size                  = undef,
) {
  include ::gitlab::cirunner

  if $manage_docker {
    if ! empty($docker_images) and ! has_key($docker_images, $default_image) {
      fail("Docker not configuered with default image: ${default_image}")
    }
    include ::docker
    # workaround for cirunner issue #1617
    # https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/issues/1617
    ensure_packages($xz_package_name)
    if !defined(Class['::docker::images']) {
      $_trusty_images = {
        ubuntu_trusty => {
          image => 'ubuntu',
          image_tag => 'trusty',
        },
      }
      $_docker_images = empty($docker_images) ? {
        false   => $docker_images,
        default => $_trusty_images,
      }
      class { '::docker::images':
        images => $_docker_images,
      }
    }
  }
  create_resources('gitlab::runners::docker', $runners)
}
