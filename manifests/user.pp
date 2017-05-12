define gitlab::user(
  $username,
  $email,
  $password,
  $fullname,
  ) {
  
  validate_string($username, $email, $password, $fullname)
  
  exec { "create-user-${title}":
    command => "/bin/bash -c 'source /root/.gitlab; /usr/local/bin/gitlab create_user \"${email}\" \"${password}\" \"${username}\" \"{name: \\\"${fullname}\\\"}\"'",
    unless  => "/bin/bash -c 'source /root/.gitlab; /usr/local/bin/gitlab users | /bin/grep $email'",
    path    => '/bin:/usr/local/bin',
    environment => 'HOME=/root',
    require => Package['gitlab-cli'],
  }
}