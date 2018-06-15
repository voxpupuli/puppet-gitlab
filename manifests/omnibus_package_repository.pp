# == Class gitlab::repos
#
# This class is used to configure gitlab repositories
#
class gitlab::omnibus_package_repository (
  Hash $repository_configuration,
  Boolean $manage_omnibus_repository = true,
  $manage_upstream_edition = $gitlab::manage_upstream_edition,
) {
  if $manage_omnibus_repository {

    if $gitlab::edition {
      $manage_upstream_edition = $gitlab::edition
      notify { "gitlab::edition is deprecated":
        message => "gitlab::edition has been deprecated, use gitlab::manage_upstream_edition instead",
      }
    }

    # ensure the correct edition is used if upstream package repositories are being configured
    if $manage_upstream_edition != 'disabled'{
      case $facts['os']['family'] {
        'Debian': {
          $_filtered_repository_configuration = {
            'apt::source' => {
              "gitlab_official_${edition}" => {
                location => "https://packages.gitlab.com/gitlab/gitlab-${edition}/debian",
              }
            }
          }
        }
        'RedHat': {
          $_filtered_repository_configuration = {
            'yumrepo' =>  {
              "gitlab_official_${edition}" =>  {
                baseurl => "https://packages.gitlab.com/gitlab/gitlab-${edition}/el/${facts.os.release.major}/$basearch"
              }
            }
          }
        }
        default: {
          $_filtered_repository_configuration = {}
        }
      }
      $_repository_configuraiton = deep_merge($repository_configuration, $_filtered_repository_configuration)
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
      create_resources($resource_type, $_resources, $resource_defaults)
    }
  }
}
