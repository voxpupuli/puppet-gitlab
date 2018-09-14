# == Class gitlab::repos
#
# This class is used to configure gitlab repositories
#
class gitlab::omnibus_package_repository (
  $repository_configuration = $gitlab::repository_configuration,
  $manage_omnibus_repository = $gitlab::manage_omnibus_repository,
  $manage_upstream_edition = $gitlab::manage_upstream_edition,
) {
  if $manage_omnibus_repository {

    if $gitlab::edition {
      $_edition = $gitlab::edition
      notify { 'gitlab::edition is deprecated':
        message => 'gitlab::edition has been deprecated, use gitlab::manage_upstream_edition instead',
      }
    } else {
      $_edition = $manage_upstream_edition
    }

    $_repository_configuration = $repository_configuration

    # common attributes for all repository configuration resources
    # ensures correct ordering regardless of the number or configuration
    # of repository related resources
    $resource_defaults = {
      tag    => 'gitlab_omnibus_repository_resource',
      before => Class['gitlab::install'],
    }

    # create all the repository resources
    $_repository_configuration.each() | String $resource_type, Hash $resources | {
      create_resources($resource_type, $resources, $resource_defaults)
    }
  }
}
