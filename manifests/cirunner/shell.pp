# == Class: gitlab::cirunner::shell
#
class gitlab::cirunner::shell (
  String                  $default_shell        = 'bash',
  Hash                    $runners              = {},
  Optional[String]        $default_token        = undef,
  Optional[String]        $default_url  = undef,
  Optional[Boolean]       $default_run_untagged = undef,
  Optional[Boolean]       $default_locked       = undef,
  Optional[Array[String]] $default_tags         = undef,
) {
  include ::gitlab::cirunner

  create_resources('gitlab::runners::shell', $runners)
}
