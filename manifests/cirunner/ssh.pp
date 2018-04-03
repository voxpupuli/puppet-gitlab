# == Class: gitlab::cirunner::ssh
#
class gitlab::cirunner::ssh (
  Hash                        $runners                   = {},
  Optional[String]            $default_token             = undef,
  Optional[String]            $default_url       = undef,
  Optional[Boolean]           $default_run_untagged      = undef,
  Optional[Boolean]           $default_locked            = undef,
  Optional[Array[String]]     $default_tags              = undef,
  Optional[String]            $default_ssh_user          = undef,
  Optional[String]            $default_ssh_password      = undef,
  Optional[String]            $default_ssh_host          = undef,
  Optional[Integer[0, 65535]] $default_ssh_port          = undef,
  Optional[String]            $default_ssh_identity_file = undef,
) {
  include ::gitlab::cirunner

  create_resources('gitlab::runner::ssh', $runners)
}
