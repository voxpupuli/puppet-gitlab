# @summary Manages initial root token
#
# **NOTE** This hack allows to use the gitlab instance via API immediately.
# While this way is quite convenient, it cannot be called a good one..
# Use it at your own risk!
#
# Remove the /etc/gitlab/initial_root_token file to regenerate the token in a
# next Puppet run.
#
# @see https://docs.gitlab.com/administration/operations/rails_console/#using-the-rails-runner
# @see https://docs.gitlab.com/user/profile/personal_access_tokens/#create-a-personal-access-token-programmatically
#
# @api private
class gitlab::initial_root_token {
  $token_file_path = '/etc/gitlab/initial_root_token'
  $script_path = '/etc/gitlab/create_initial_root_token.rb'

  if $gitlab::create_initial_root_token {
    $script_ensure = 'file'
    $script_content = epp('gitlab/create_initial_root_token.rb.epp',
      token             => $gitlab::initial_root_token,
      token_ttl_minutes => $gitlab::initial_root_token_ttl_minutes,
      token_file_path   => $token_file_path,
    )

    # Execute after the script is created, but only if token is managed
    exec { 'create_initial_root_token':
      command => "/usr/bin/gitlab-rails runner '${script_path}'",
      creates => $token_file_path,
      require => File[$script_path],
    }
  } else {
    $script_ensure = 'absent'
    $script_content = undef

    # Ensure there is no token file left if it was created before
    file { $token_file_path:
      ensure => 'absent',
    }
  }

  file { $script_path:
    ensure  => $script_ensure,
    owner   => 'root',
    group   => 'git', # gitlab-rails runner executes this script as 'git' user
    mode    => '0640',
    content => $script_content,
  }
}
