# @summary Manage global chain loaded hook files for all GitLab projects. Hooks can be created as a pre-receive, post-receive, or update hook. It's possible to create  multipe hooks per type as long as their names are unique. Support for chained (global) hooks is introduced in GitLab Shell 4.1.0 and GitLab 8.15.
#
# @example Global hook usage
#   gitlab::custom_hook { 'my_custom_hook':
#     type            => 'post-receive',
#     source          => 'puppet:///modules/my_module/post-receive',
#   }
#
# @param type The custom hook type. Should be one of pre-receive, post-receive, or update.
# @param custom_hooks_dir The GitLab shell repos path. This defaults to '/opt/gitlab/embedded/service/gitlab-shell/hooks' if not present.
# @param content Specify the custom hook contents either as a string or using the template function. If this paramter is specified source parameter must not be present.
# @param source Specify a file source path to populate the custom hook contents. If this paramter is specified content parameter must not be present.
define gitlab::global_hook (
  Enum['post-receive', 'pre-receive', 'update'] $type,
  Stdlib::Absolutepath                          $custom_hooks_dir = $gitlab::custom_hooks_dir,
  Optional[String[1]]                           $content          = undef,
  Optional[Pattern[/^puppet:/]]                 $source           = undef,
) {
  if ! ($content) and ! ($source) {
    fail('gitlab::custom_hook resource must specify either content or source')
  }

  if ($content) and ($source) {
    fail('gitlab::custom_hook resource must specify either content or source, but not both')
  }

  $hook_path = "${custom_hooks_dir}/${type}.d"

  File {
    owner => $gitlab::service_user,
    group => $gitlab::service_group,
    mode  => '0755',
  }

  # Create the hook chain directory for this project, if it doesn't exist
  if !defined(File[$hook_path]) {
    file { $hook_path:
      ensure => directory,
    }
  }

  file { "${hook_path}/${name}":
    ensure  => 'file',
    content => $content,
    source  => $source,
  }
}
