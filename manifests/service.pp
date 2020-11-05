# @summary This class is meant to be called from gitlab. It ensure the service is running.
#
# @param service_ensure Should Puppet start the service?
# @param service_enable Run the system service on boot.
# @param service_name Name of the system service.
# @param service_exec The service executable path. Provide this variable value only if the service executable path would be a subject of change in future GitLab versions for any reason.
# @param service_manage Should Puppet manage the service?
# @param service_provider_restart Should Puppet restart the gitlab systemd service?
# @param skip_post_deployment_migrations Adds SKIP_POST_DEPLOYMENT_MIGRATIONS=true to the execution of gitlab-ctl reconfigure. Used for zero-downtime updates
class gitlab::service (
  $service_ensure = $gitlab::service_ensure,
  $service_enable = $gitlab::service_enable,
  $service_name   = $gitlab::service_name,
  $service_exec   = $gitlab::service_exec,
  $service_manage = $gitlab::service_manage,
  $service_provider_restart = $gitlab::service_provider_restart,
  $skip_post_deployment_migrations = $gitlab::skip_post_deployment_migrations,
) {
  if $service_manage {
    $restart = "${service_exec} restart"
    $start = "${service_exec} start"
    $stop = "${service_exec} stop"
    $status = "${service_exec} status"

    service { $service_name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      restart    => $restart,
      start      => $start,
      stop       => $stop,
      status     => $status,
      hasstatus  => true,
      hasrestart => true,
    }
  }

  $reconfigure_attributes = {
    command     => '/bin/sh -c "unset LD_LIBRARY_PATH; /usr/bin/gitlab-ctl reconfigure"',
    refreshonly => true,
    timeout     => 1800,
    logoutput   => true,
    tries       => 5,
    subscribe   => Class['gitlab::omnibus_config'],
    require     => Class['gitlab::install'],
  }

  if $skip_post_deployment_migrations {
    $_reconfigure_attributes = $reconfigure_attributes + { environment => ['SKIP_POST_DEPLOYMENT_MIGRATIONS=true'] }
  } else {
    $_reconfigure_attributes = $reconfigure_attributes
  }

  if ($service_manage and $service_provider_restart) {
    exec { 'gitlab_reconfigure':
      notify => Service[$service_name],
      *      => $_reconfigure_attributes,
    }
  } else {
    exec { 'gitlab_reconfigure':
      * => $_reconfigure_attributes,
    }
  }
}
