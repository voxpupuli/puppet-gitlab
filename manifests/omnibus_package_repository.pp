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

    if $_edition == 'disabled' {
      $_repository_configuration = $repository_configuration
    } else {
      # if we manage the repositories, adjust the ensure => present/absent
      # attributes according to the desired edition.
      $_repository_configuration = $repository_configuration.reduce({}) | $_memo, $_pair1 | {
        # yumrepo =>  ...
        [ $_rsc_type, $_repo_hash ] = $_pair1

        $_mapped_repo_hash = $_repo_hash.reduce({}) | $_memo, $_pair2 | {
          # gitlab_official_ce => ...
          [ $_repo_name, $_repo_attrs, ] = $_pair2

          if $_repo_name == "gitlab_official_${_edition}" {
            $_ensure = 'present'
          } else {
            $_ensure = 'absent'
          }

          $_memo + { $_repo_name => $_repo_attrs + { ensure => $_ensure } }
        }

        $_memo + { $_rsc_type => $_mapped_repo_hash }
      }
    }

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
