# == Define: gitlab::custom_hook
#
# Manage custom hook files within a GitLab project. Custom hooks can be created
# as a pre-receive, post-receive, or update hook. It's possible to create
# different custom hook types for the same project - one each for pre-receive,
# post-receive and update.
#
# === Parameters
#
# [*namevar*]
#   The namevar is arbitrary and is not used directly. Supply a descriptive
#   namevar of your choosing.
#
# [*namespace*]
#   The GitLab group namespace for the project.
#
# [*project*]
#   The GitLab project name.
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
# [*repos_path*]
#   The GitLab shell repos path. This defaults to
#   '/var/opt/gitlab/git-data/repositories' if not present.
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
#     namespace       => 'my_group',
#     project         => 'my_project',
#     type            => 'post-receive',
#     source          => 'puppet:///modules/my_module/post-receive',
#   }
#
# === Authors
#
# Drew A. Blessing <drew.blessing@mac.com>
#
# === Copyright
#
# Copyright 2014 Spencer Owen, unless otherwise noted.
#
define gitlab::custom_hook(
  $namespace      = undef,
  $project        = undef,
  $type           = undef,
  $content        = undef,
  $source         = undef,
  $repos_path     = undef,
) {
  validate_string($namespace)
  validate_string($project)
  validate_re($type, '^(post-receive|pre-receive|update)$')

  if $repos_path {
    $_repos_path = $repos_path
  } elsif $::gitlab::git_data_dir {
    $_repos_path = "${::gitlab::git_data_dir}/repositories"

  } else {
    $_repos_path = '/var/opt/gitlab/git-data/repositories'
  }
  validate_absolute_path($_repos_path)

  if !$content and !$source {
    fail('gitlab::custom_hook resource must specify either content or source')
  }

  if $content and $source {
    fail('gitlab::custom_hook resource must specify either content or source, but not both')
  }

  if $source {
    validate_re($source, '^puppet:')
  }

  $hook_path = "${_repos_path}/${namespace}/${project}.git/custom_hooks"

  File {
    owner     => $::gitlab::service_user,
    group     => $::gitlab::service_group,
    mode      => '0755',
  }

  # Create the custom_hooks directory for this project, if it doesn't exist
  if !defined(File[$hook_path]) {
    file { $hook_path:
      ensure      => directory,
    }
  }

  file { "${hook_path}/${type}":
    ensure      => 'present',
    content     => $content,
    source      => $source,
  }
}
