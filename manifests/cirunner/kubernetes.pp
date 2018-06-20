# == Class: gitlab::cirunner::kubernetes
#
class gitlab::cirunner::kubernetes (
  Hash                    $runners                                   = {},
  Optional[String]        $default_token                             = undef,
  Optional[String]        $default_url                       = undef,
  Optional[Boolean]       $default_run_untagged                      = undef,
  Optional[Boolean]       $default_locked                            = undef,
  Optional[Array[String]] $default_tags                              = undef,
  Optional[String]        $default_host                              = undef,
  Optional[String]        $default_cert_file                         = undef,
  Optional[String]        $default_key_file                          = undef,
  Optional[String]        $default_ca_file                           = undef,
  Optional[String]        $default_image                             = undef,
  Optional[String]        $default_namespace                         = undef,
  Optional[String]        $default_namespace_overwrite_allowed       = undef,
  Optional[Boolean]       $default_privileged                        = undef,
  Optional[Integer]       $default_cpu_limit                         = undef,
  Optional[Integer]       $default_memory_limit                      = undef,
  Optional[Integer]       $default_service_cpu_limit                 = undef,
  Optional[Integer]       $default_service_memory_limit              = undef,
  Optional[Integer]       $default_helper_cpu_limit                  = undef,
  Optional[Integer]       $default_helper_memory_limit               = undef,
  Optional[Integer]       $default_cpu_request                       = undef,
  Optional[Integer]       $default_memory_request                    = undef,
  Optional[Integer]       $default_service_cpu_request               = undef,
  Optional[Integer]       $default_service_memory_request            = undef,
  Optional[Integer]       $default_helper_cpu_request                = undef,
  Optional[Integer]       $default_helper_memory_request             = undef,
  Optional[Integer]       $default_pull_policy                       = undef,
  Optional[Integer]       $default_node_selector                     = undef,
  Optional[Integer]       $default_image_pull_secrets                = undef,
  Optional[Integer]       $default_helper_image                      = undef,
  Optional[Integer]       $default_termination_grace_period          = undef,
  Optional[Integer]       $default_poll_interval                     = undef,
  Optional[Integer]       $default_poll_timeout                      = undef,
  Optional[String]        $default_pod_labels                        = undef,
  Optional[String]        $default_service_account                   = undef,
  Optional[String]        $default_service_account_overwrite_allowed = undef,
) {
  include ::gitlab::cirunner

  create_resources('gitlab::runner::kubernetes', $runners)
}
