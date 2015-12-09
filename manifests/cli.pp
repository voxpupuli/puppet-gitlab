class gitlab::cli(
  $gitlab_api_endpoint     = $::gitlab::params::gitlab_api_endpoint,
  $gitlab_api_password     = $::gitlab::params::gitlab_api_password,
  $gitlab_api_user         = $::gitlab::params::gitlab_api_user,
  $manage_cli_dependencies = $::gitlab::params::manage_cli_dependencies,
  ) {

  # input validation
  validate_bool($manage_cli_dependencies)
  validate_string($gitlab_api_endpoint, $gitlab_api_password, $gitlab_api_user)

  # check if we need to manage dependencies
  if $manage_cli_dependencies {
    $gem_dependencies  = [ Package['rubygems'], Package['ruby-devel'] ]
    $exec_dependencies = [ Package['curl'], Package['jq'],  ]
  } else {
    $gem_dependencies  = undef
    $exec_dependencies = undef
  }

  # set up the gitlab gem to have gitlab cli support
  package { 'gitlab':
    ensure   => installed,
    provider => 'gem',
    require  => $gem_dependencies,
  } ->

  # we retrieve the private token with a simple raw curl API call. Reason for 
  # this is to make initial deployment work: gitlab gets installed with a
  # user/pw combo root/5ifeL!fe and an auto-generated private token. By doing 
  # this API call this way it will work in the first puppet run
  exec { 'gitlab-settings':
    command => "/bin/echo export GITLAB_API_PRIVATE_TOKEN=`/bin/curl -s -X POST -d 'password=${gitlab_api_password}&login=${gitlab_api_user}' ${gitlab_api_endpoint}/session | /bin/jq .private_token -r` > ~/.gitlab; /bin/echo export GITLAB_API_ENDPOINT=${gitlab_api_endpoint} >> ~/.gitlab",
    onlyif  => [
      "/bin/test -f ~/.gitlab", 
      "/bin/grep GITLAB_API_PRIVATE_TOKEN ~/.gitlab", 
      "/bin/grep GITLAB_API_ENDPOINT ~/.gitlab" ],
    require => $exec_dependencies,
  }
  
}