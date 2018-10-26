# == Define: gitlab::global_hook
#
# Manage global chain loaded hook files for all GitLab projects. Hooks can be created
# as a pre-receive, post-receive, or update hook. It's possible to create
# multipe hooks per type as long as their names are unique.
#
# Support for chained (global) hooks is introduced in GitLab Shell 4.1.0 and GitLab 8.15.
#
# === Parameters
#
# [*namevar*]
#   The namevar is used as chail file name and should be unique. Supply a descriptive
#   namevar of your choosing.
#
# [*type*]
#   The custom hook type. Should be one of pre-receive, post-receive, or update.
#
# [*content*]
#   Specify the custom hook contents either as a string or using the template
#   function. If this paramter is specified source parameter must not be
#   present.
#
# [*source*]
#   Specify a file source path to populate the custom hook contents. If this
#   paramter is specified content parameter must not be present.
#
# [*custom_hooks_dir*]
#   The GitLab shell repos path. This defaults to
#   '/opt/gitlab/embedded/service/gitlab-shell/hooks' if not present.
#
# [*git_username*]
#   The git user name. Defaults to 'git' if not present.
#
# [*git_groupname*]
#   The git group name. Defaults to 'git' if not present.
#
#
# === Examples
#
#   gitlab::custom_hook { 'my_custom_hook':
#     type            => 'post-receive',
#     source          => 'puppet:///modules/my_module/post-receive',
#   }
#
# === Authors
# Hidde Boomsma <hboomsma@hostnet.nl>
#
# Inspired by the custom_hook module by:
# Drew A. Blessing <drew.blessing@mac.com>
#
# === Copyright
#
# Copyright 2017 Hidde Boomsma
#
define gitlab::global_hook (
  Enum['post-receive', 'pre-receive', 'update'] $type,
  Stdlib::Absolutepath                          $custom_hooks_dir,
  Optional[String[1]]                           $content          = undef,
  Optional[/^puppet:/]                          $source           = undef,
) {
  if $custom_hooks_dir {
    $_custom_hooks_dir = $custom_hooks_dir
  } elsif $::gitlab::custom_hooks_dir {
    $_custom_hooks_dir = $::gitlab::custom_hooks_dir
  } else {
    $_custom_hooks_dir = '/opt/gitlab/embedded/service/gitlab-shell/hooks'
  }

  if ! ($content) and ! ($source) {
    fail('gitlab::custom_hook resource must specify either content or source')
  }

  if ($content) and ($source) {
    fail('gitlab::custom_hook resource must specify either content or source, but not both')
  }

  $hook_path = "${_custom_hooks_dir}/${type}.d"

  File {
    owner => $::gitlab::service_user,
    group => $::gitlab::service_group,
    mode  => '0755',
  }

  # Create the hook chain directory for this project, if it doesn't exist
  if !defined(File[$hook_path]) {
    file { $hook_path:
      ensure => directory,
    }
  }

  file { "${hook_path}/${name}":
    ensure  => 'present',
    content => $content,
    source  => $source,
  }
}
