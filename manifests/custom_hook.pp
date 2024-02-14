# @summary Manage custom hook files within a GitLab project. Custom hooks can be created as a pre-receive, post-receive, or update hook. Only one of each is currently supported by this module.
#
# @example Custom hook usage
#   gitlab::custom_hook { 'my_custom_hook':
#     namespace      => 'my_group',
#     project        => 'my_project',
#     type           => 'post-receive',
#     source         => 'puppet:///modules/my_module/post-receive',
#   }
#
# @example Calculate hashed storage path
#   gitlab::custom_hook { 'my_custom_hook':
#     project        => 93,
#     hashed_storage => true,
#     type           => 'post-receive',
#     source         => 'puppet:///modules/my_module/post-receive',
#   }
#   # Hook path will be `@hashed/6e/40/6e4001871c0cf27c7634ef1dc478408f642410fd3a444e2a88e301f5c4a35a4d`
#
# @param project The GitLab project name, or the hashed directory name or project ID number
# @param namespace The GitLab group namespace for the project.
# @param type The custom hook type. Should be one of pre-receive, post-receive, or update.
# @param content Specify the custom hook contents either as a string or using the template function. If this paramter is specified source parameter must not be present.
# @param source Specify a file source path to populate the custom hook contents. If this paramter is specified content parameter must not be present.
# @param repos_path The GitLab shell repos path. This defaults to '/var/opt/gitlab/git-data/repositories' if not present.
# @param hashed_storage Whether to treat the project name as a hashed storage directory name or ID number
#
define gitlab::custom_hook (
  Variant[String,Integer]                       $project,
  Enum['update', 'post-receive', 'pre-receive'] $type,
  Optional[String]                              $namespace = undef,
  Optional[String]                              $content = undef,
  Optional[String]                              $source = undef,
  Optional[Stdlib::Absolutepath]                $repos_path = undef,
  Boolean                                       $hashed_storage = false,
) {
  if $repos_path {
    $_repos_path = $repos_path
  } elsif $gitlab::git_data_dir {
    $_repos_path = "${gitlab::git_data_dir}/repositories"
  } else {
    $_repos_path = '/var/opt/gitlab/git-data/repositories'
  }

  if ! ($content) and ! ($source) {
    fail("gitlab::custom_hook[${name}]: Must specify either content or source")
  }

  if ($content) and ($source) {
    fail("gitlab::custom_hook[${name}]: Must specify either content or source, but not both")
  }

  if ! ($hashed_storage) and ! ($namespace) {
    fail("gitlab::custom_hook[${name}]: Must specify either namespace or hashed_storage")
  }

  if ($hashed_storage) and ($namespace) {
    fail("gitlab::custom_hook[${name}]: Must specify either namespace or hashed_storage, but not both")
  }

  if ($namespace) {
    $hook_path = "${_repos_path}/${namespace}/${project}.git/custom_hooks"
  } elsif ($hashed_storage) {
    if ($project.is_a(Integer)) {
      $_project_hash = sha256(String($project))
    } else {
      $_project_hash = $project
    }

    if ($_project_hash.length != 64) {
      fail("gitlab::custom_hook[${name}]: Invalid project hash ${_project_hash}")
    }

    $hook_path = "${_repos_path}/@hashed/${_project_hash[0,2]}/${_project_hash[2,2]}/${_project_hash}.git/custom_hooks"
  }

  File {
    owner => $gitlab::service_user,
    group => $gitlab::service_group,
    mode  => '0755',
  }

  # Create the custom_hooks directory for this project, if it doesn't exist
  if !defined(File[$hook_path]) {
    file { $hook_path:
      ensure => directory,
    }
  }

  file { "${hook_path}/${type}":
    ensure  => file,
    content => $content,
    source  => $source,
  }
}
