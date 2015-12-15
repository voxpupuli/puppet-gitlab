class gitlab::user(
  $username,
  $email,
  $password,
  $fullname,
  ) {
  
  validate_string($username, $email, $password, $fullname)

  exec { "create-user-${title}":
    command => "source ~/.gitlab; /usr/local/bin/gitlab '${email}' '${password}' '${username}' '{name: \"${fullname}\"}'",
    onlyif  => [ 
      "source ~/.gitlab; /usr/local/bin/gitlab users | grep $email",
      "source ~/.gitlab; /usr/local/bin/gitlab users | grep $username",
    ],
    require => Package['gitlab-cli'],
  }

}