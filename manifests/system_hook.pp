# @summary A file hook will run on each event so it's up to you to filter events or projects
# within a file hook code. You can have as many file hooks as you want. Each file hook will
# be triggered by GitLab asynchronously in case of an event. For a list of events
# see the system hooks documentation.
#
#
# @example System hook usage
#   gitlab::system_hook { 'my_system_hook':
#     type            => 'post-receive',
#     source          => 'puppet:///modules/my_module/post-receive',
#   }
#
# @param system_hooks_dir The GitLab shell repos path. This defaults to '/opt/gitlab/embedded/service/gitlab-rails/file_hooks' if not present.
# @param content Specify the system hook contents either as a string or using the template function. If this paramter is specified source parameter must not be present.
# @param source Specify a file source path to populate the system hook contents. If this paramter is specified content parameter must not be present.
define gitlab::system_hook (
  Stdlib::Absolutepath                          $system_hooks_dir = $gitlab::system_hooks_dir,
  Optional[String[1]]                           $content          = undef,
  Optional[Pattern[/^puppet:/]]                 $source           = undef,
) {
  if ! ($content) and ! ($source) {
    fail('gitlab::system_hook resource must specify either content or source')
  }

  if ($content) and ($source) {
    fail('gitlab::system_hook resource must specify either content or source, but not both')
  }

  File {
    owner => $gitlab::service_user,
    group => $gitlab::service_group,
    mode  => '0755',
  }

  # Create the hook chain directory for this project, if it doesn't exist
  if !defined(File[$system_hooks_dir]) {
    file { $system_hooks_dir:
      ensure => directory,
    }
  }

  file { "${system_hooks_dir}/${name}":
    ensure  => 'file',
    content => $content,
    source  => $source,
  }
}
