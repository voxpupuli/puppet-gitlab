# @summary This module installs and configures Gitlab CI Runners.
# @param concurrent the number of concurrent jobs the runner can handle
# @param conf_file path to the config file
# @param token the runner registration token
# @param url the url to the gitlab server
#
class gitlab::cirunner (
  Integer          $concurrent = 1,
  String           $conf_file  = '/etc/gitlab-runner/config.toml',
  Optional[String] $token      = undef,
  String           $url        = 'https://gitlab.com',
) {
  $package_name = 'gitlab-runner'
  ensure_packages([$package_name])
  $command = "/usr/bin/gitlab-ci-multi-runner register -n --executor shell --token ${token} --url ${url}"

  exec { 'gitlab-runner-restart':
    command     => "/usr/bin/${package_name} restart",
    refreshonly => true,
    require     => Package[$package_name],
  }
  exec { 'Register_runner':
    command => $command,
    unless  => "/bin/grep ${token} ${conf_file}",
    require => Package[$package_name],
  }
  file_line { 'gitlab-runner-concurrent':
    path    => $conf_file,
    line    => "concurrent = ${concurrent}",
    match   => '^concurrent = \d+',
    require => Exec['Register_runner'],
    notify  => Exec['gitlab-runner-restart'],
  }
}
