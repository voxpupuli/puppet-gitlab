# == Class gitlab::repos
#
# This class is used to configure gitlab repositories
#
class gitlab::omnibus_package_repository (
  Hash $repository,
  String $repository_resource_type,
  Boolean $manage_omnibus_repository,
) {
  if $manage_omnibus_repository {
    create_resources($repository_resource_type, $repository, {tag => 'gitlab_omnibus_repository'})
  }
}
