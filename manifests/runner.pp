# == Define: gitlab::runner
#
# This module installs and configures Gitlab CI Runners.
#
# === Parameters
#
# [*runners_hash*]
#   Hash with configuration for runners
#
# [*default_config*]
#   Hash with default configration for runners. This will
#   be merged with the runners_hash config
#
# === Authors
#
# Tobias Brunner <tobias.brunner@vshn.ch>
# Matthias Indermuehle <matthias.indermuehle@vshn.ch>
#
# === Copyright
#
# Copyright 2015 Tobias Brunner, VSHN AG
#
define gitlab::runner (
  $runners_hash,
  $default_config = {},
) {

  validate_hash($runners_hash)
  validate_hash($default_config)

  # Set resource name as name for the runner
  $name_config = {
    name => $title,
  }
  $_default_config = merge($default_config, $name_config)
  $config = $runners_hash[$title]

  # Merge default config with actual config
  $_config = merge($_default_config, $config)

  # Convert configuration into a string
  $parameters_array = join_keys_to_values($_config, " ")
  $parameters_array_dashes = prefix($parameters_array, "--")
  $parameters_string = join($parameters_array_dashes, " ")

  $runner_name = $_config['name']
  $toml_file = '/etc/gitlab-runner/config.toml'

  # Execute gitlab ci multirunner register
  exec {"Register_runner_${title}":
    command => "/usr/bin/gitlab-ci-multi-runner register -n ${parameters_string}",
    unless  => "/bin/grep ${runner_name} ${toml_file}",
  }

}
