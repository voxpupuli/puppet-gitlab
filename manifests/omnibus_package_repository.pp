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

    # ensure the correct edition is used if upstream package repositories are being configured
    if $_edition != 'disabled'{
      case $facts['os']['family'] {
        'Debian': {
          $_filtered_repository_configuration = {
            'apt::source' => {
              "gitlab_official_${_edition}" => {
                location => "https://packages.gitlab.com/gitlab/gitlab-${_edition}/debian",
              },
            },
          }
        }
        'RedHat': {
          $_filtered_repository_configuration = {
            'yumrepo' =>  {
              "gitlab_official_${_edition}" =>  {
                baseurl => "https://packages.gitlab.com/gitlab/gitlab-${_edition}/el/${facts['os']['release']['major']}/\$basearch",
              },
            },
          }
        }
        default: {
          $_filtered_repository_configuration = {}
        }
      }
      $_repository_configuration = deep_merge($repository_configuration, $_filtered_repository_configuration)
    } else {
    # using upstream repository, so just use defaults
      $_repository_configuration = $repository_configuration
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
