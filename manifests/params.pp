# == Class gitlab::params
#
# This class is meant to be called from gitlab.
# It sets variables according to platform.
#
class gitlab::params {

  $edition = 'ce'

  # OS specific parameters
  case $::osfamily {
    'debian': {
      $package_name          = "gitlab-${edition}"
      $service_name          = 'gitlab-runsvdir'
      $package_repo_location = "https://packages.gitlab.com/gitlab/gitlab-${edition}/ubuntu/"
      $package_repo_repos    = 'main'
      $package_repo_key      = 'E15E78F4'
      $package_repo_key_src  = 'https://packages.gitlab.com/gpg.key'
    }
    'redhat': {
      $package_name          = "gitlab-${edition}"
      $service_name          = 'gitlab-runsvdir'
      $package_repo_location = "https://packages.gitlab.com/gitlab/gitlab-${edition}/el/5/\$basearch"
      $package_repo_repos    = "gitlab_gitlab-${edition}"
      $package_repo_key_src  = 'https://packages.gitlab.com/gpg.key'
    }
    default: {
      fail("OS family ${::osfamily} not supported")
    }
  }

  # package parameters
  $package_ensure = installed
  $manage_package_repo = true

  # service parameters
  $service_enable = true
  $service_ensure = running
  $service_manage = true

  # gitlab specific
  $config_file = '/etc/gitlab/gitlab.rb'

}
