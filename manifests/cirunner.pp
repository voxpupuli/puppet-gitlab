# @summary This module installs and configures Gitlab CI Runners.
# @param conf_file path to the config file
# @param url the url to the gitlab server
# @param runners the hash of runners
#
class gitlab::cirunner (
  String               $conf_file  = '/etc/gitlab-runner/config.toml',
  String               $url        = 'https://gitlab.com',
  Hash[String, String] $runners = {},
) {
  $concurrent = $runners.size
  $package_name = 'gitlab-runner'
  ensure_packages([$package_name])

  exec { 'gitlab-runner-restart':
    command     => "/usr/bin/${package_name} restart",
    refreshonly => true,
    require     => Package[$package_name],
  }
  $runners.each |$name, $token| {
    $command = "/usr/bin/gitlab-ci-multi-runner register -n --executor shell --token ${token} --url ${url}"
    exec { "Register_runner ${name}":
      command => $command,
      unless  => "/bin/grep ${token} ${conf_file}",
      require => Package[$package_name],
    }
  }
  file_line { 'gitlab-runner-concurrent':
    path   => $conf_file,
    line   => "concurrent = ${concurrent}",
    match  => '^concurrent = \d+',
    notify => Exec['gitlab-runner-restart'],
  }
}
