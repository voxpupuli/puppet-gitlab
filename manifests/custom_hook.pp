# @summary Manage custom hook files within a GitLab project. Custom hooks can be created as a pre-receive, post-receive, or update hook. It's possible to create different custom hook types for the same project - one each for pre-receive, post-receive and update.
#
# @example Custom hook usage
#   gitlab::custom_hook { 'my_custom_hook':
#     namespace       => 'my_group',
#     project         => 'my_project',
#     type            => 'post-receive',
#     source          => 'puppet:///modules/my_module/post-receive',
#   }
#
# @param namespace The GitLab group namespace for the project.
# @param project The GitLab project name.
# @param type The custom hook type. Should be one of pre-receive, post-receive, or update.
# @param content Specify the custom hook contents either as a string or using the template function. If this paramter is specified source parameter must not be present.
# @param source Specify a file source path to populate the custom hook contents. If this paramter is specified content parameter must not be present.
# @param repos_path The GitLab shell repos path. This defaults to '/var/opt/gitlab/git-data/repositories' if not present.
define gitlab::custom_hook (
  String                                        $namespace,
  String                                        $project,
  Enum['update', 'post-receive', 'pre-receive'] $type,
  Optional[String]                              $content = undef,
  Optional[String]                              $source = undef,
  Optional[Stdlib::Absolutepath]                $repos_path = undef,
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

  $hook_path = "${_repos_path}/${namespace}/${project}.git/custom_hooks"

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
