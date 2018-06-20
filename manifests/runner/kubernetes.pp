# == Define: gitlab::runner::kubernetes
#
define gitlab::runner::kubernetes (
  Optional[String]           $token                             = undef,
  Optional[String ]          $url                               = undef,
  Optional[Boolean]          $run_untagged                      = undef,
  Optional[Boolean]          $locked                            = undef,
  Optional[Array[String]]    $tags                              = undef,
  Optional[String]           $host                              = undef,
  Optional[String]           $cert_file                         = undef,
  Optional[String]           $key_file                          = undef,
  Optional[String]           $ca_file                           = undef,
  Optional[String]           $image                             = undef,
  Optional[String]           $namespace                         = undef,
  Optional[String]           $namespace_overwrite_allowed       = undef,
  Optional[Boolean]          $privileged                        = undef,
  Optional[Integer]          $cpu_limit                         = undef,
  Optional[Integer]          $memory_limit                      = undef,
  Optional[Integer]          $service_cpu_limit                 = undef,
  Optional[Integer]          $service_memory_limit              = undef,
  Optional[Integer]          $helper_cpu_limit                  = undef,
  Optional[Integer]          $helper_memory_limit               = undef,
  Optional[Integer]          $cpu_request                       = undef,
  Optional[Integer]          $memory_request                    = undef,
  Optional[Integer]          $service_cpu_request               = undef,
  Optional[Integer]          $service_memory_request            = undef,
  Optional[Integer]          $helper_cpu_request                = undef,
  Optional[Integer]          $helper_memory_request             = undef,
  Optional[Integer]          $pull_policy                       = undef,
  Optional[Integer]          $node_selector                     = undef,
  Optional[Integer]          $image_pull_secrets                = undef,
  Optional[Integer]          $helper_image                      = undef,
  Optional[Integer]          $termination_grace_period          = undef,
  Optional[Integer]          $poll_interval                     = undef,
  Optional[Integer]          $poll_timeout                      = undef,
  Optional[String]           $pod_labels                        = undef,
  Optional[String]           $service_account                   = undef,
  Optional[String]           $service_account_overwrite_allowed = undef,
) {
  include ::gitlab::cirunner::kubernetes
  $executor_cmd = '--executor kubernetes'
  $_name        = "kubernetes_${name}"
  $name_cmd     = "-n --name ${_name}"
  $token_cmd = ::gitlab::cirunner::cmd_str(
    'registration-token',
    [$token, $gitlab::cirunner::kubernetes::default_token,
    $::gitlab::cirunner::default_token]
  )
  $url_cmd = ::gitlab::cirunner::cmd_str(
    'url',
    [$url, $gitlab::cirunner::kubernetes::default_url,
    $::gitlab::cirunner::default_url]
  )
  $run_untagged_cmd = ::gitlab::cirunner::cmd_str(
    'run-untagged',
    [$run_untagged, $gitlab::cirunner::kubernetes::default_run_untagged,
    $::gitlab::cirunner::default_run_untagged]
  )
  $locked_cmd = ::gitlab::cirunner::cmd_str(
    'locked',
    [$locked, $gitlab::cirunner::kubernetes::default_locked,
    $::gitlab::cirunner::default_locked]
  )
  $tags_cmd = ::gitlab::cirunner::cmd_str(
    'tag-list',
    [$tags, $gitlab::cirunner::kubernetes::default_tags,
    $::gitlab::cirunner::default_tags]
  )
  $host_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-host',
    [$host, $gitlab::cirunner::kubernetes::default_host]
  )
  $image_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-image',
    [$image, $gitlab::cirunner::kubernetes::default_image]
  )
  $namespace_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-namespace',
    [$namespace, $gitlab::cirunner::kubernetes::default_namespace]
  )
  $namespace_overwrite_allowed_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-namespace_overwrite_allowed',
    [$namespace_overwrite_allowed, $gitlab::cirunner::kubernetes::default_namespace_overwrite_allowed]
  )
  $privileged_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-privileged',
    [$privileged, $gitlab::cirunner::kubernetes::default_privileged]
  )
  $cpu_limit_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-cpu-limit',
    [$cpu_limit, $gitlab::cirunner::kubernetes::default_cpu_limit]
  )
  $memory_limit_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-memory-limit',
    [$memory_limit, $gitlab::cirunner::kubernetes::default_memory_limit]
  )
  $service_cpu_limit_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-service-cpu-limit',
    [$service_cpu_limit, $gitlab::cirunner::kubernetes::default_service_cpu_limit]
  )
  $service_memory_limit_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-service-memory-limit',
    [$service_memory_limit, $gitlab::cirunner::kubernetes::default_service_memory_limit]
  )
  $helper_cpu_limit_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-helper-cpu-limit',
    [$helper_cpu_limit, $gitlab::cirunner::kubernetes::default_helper_cpu_limit]
  )
  $helper_memory_limit_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-helper-memory-limit',
    [$helper_memory_limit, $gitlab::cirunner::kubernetes::default_helper_memory_limit]
  )
  $cpu_request_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-cpu-request',
    [$cpu_request, $gitlab::cirunner::kubernetes::default_cpu_request]
  )
  $memory_request_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-memory-request',
    [$memory_request, $gitlab::cirunner::kubernetes::default_memory_request]
  )
  $service_cpu_request_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-service-cpu-request',
    [$service_cpu_request, $gitlab::cirunner::kubernetes::default_service_cpu_request]
  )
  $service_memory_request_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-service-memory-request',
    [$service_memory_request, $gitlab::cirunner::kubernetes::default_service_memory_request]
  )
  $helper_cpu_request_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-helper-cpu-request',
    [$helper_cpu_request, $gitlab::cirunner::kubernetes::default_helper_cpu_request]
  )
  $helper_memory_request_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-helper-memory-request',
    [$helper_memory_request, $gitlab::cirunner::kubernetes::default_helper_memory_request]
  )
  $pull_policy_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-pull-policy',
    [$pull_policy, $gitlab::cirunner::kubernetes::default_pull_policy]
  )
  $node_selector_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-node-selector',
    [$node_selector, $gitlab::cirunner::kubernetes::default_node_selector]
  )
  $image_pull_secrets_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-image-pull-secrets',
    [$image_pull_secrets, $gitlab::cirunner::kubernetes::default_image_pull_secrets]
  )
  $helper_image_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-helper-image',
    [$helper_image, $gitlab::cirunner::kubernetes::default_helper_image]
  )
  $termination_grace_period_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-terminationGracePeriodSeconds',
    [$termination_grace_period, $gitlab::cirunner::kubernetes::default_termination_grace_period]
  )
  $poll_interval_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-poll-interval',
    [$poll_interval, $gitlab::cirunner::kubernetes::default_poll_interval]
  )
  $poll_timeout_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-poll-timeout',
    [$poll_timeout, $gitlab::cirunner::kubernetes::default_poll_timeout]
  )
  $pod_labels_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-pod-labels',
    [$pod_labels, $gitlab::cirunner::kubernetes::default_pod_labels]
  )
  $service_account_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-service-account',
    [$service_account, $gitlab::cirunner::kubernetes::default_service_account]
  )
  $service_account_overwrite_allowed_cmd = ::gitlab::cirunner::cmd_str(
    'kubernetes-service_account_overwrite_allowed',
    [$service_account_overwrite_allowed, $gitlab::cirunner::kubernetes::default_service_account_overwrite_allowed]
  )
  $parameters_string = [
    $executor_cmd, $token_cmd, $url_cmd, $name_cmd, $run_untagged_cmd, $locked_cmd,
    $tags_cmd, $host_cmd, $image_cmd, $namespace_cmd,
    $namespace_overwrite_allowed_cmd, $privileged_cmd,
    $cpu_limit_cmd, $memory_limit_cmd, $service_cpu_limit_cmd,
    $service_memory_limit_cmd, $helper_cpu_limit_cmd, $helper_memory_limit_cmd,
    $cpu_request_cmd, $memory_request_cmd, $service_cpu_request_cmd,
    $service_memory_request_cmd, $helper_cpu_request_cmd,
    $helper_memory_request_cmd, $pull_policy_cmd, $node_selector_cmd,
    $image_pull_secrets_cmd, $helper_image_cmd, $termination_grace_period_cmd,
    $poll_interval_cmd, $poll_timeout_cmd, $pod_labels_cmd, $service_account_cmd,
    $service_account_overwrite_allowed_cmd,
  ].join(' ')
  # Execute gitlab ci multirunner register
  exec {"Register_runner_${title}":
    command => "/usr/bin/gitlab-ci-multi-runner register ${parameters_string}",
    unless  => "/bin/grep ${_name} ${::gitlab::cirunner::conf_file}",
  }

}
