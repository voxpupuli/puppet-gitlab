# == Class: gitlab::cirunner::parallels
#
class gitlab::cirunner::parallels (
  Hash                    $runners                   = {},
  Optional[String]        $default_token             = undef,
  Optional[String]        $default_url       = undef,
  Optional[Boolean]       $default_run_untagged      = undef,
  Optional[Boolean]       $default_locked            = undef,
  Optional[Array[String]] $default_tags              = undef,
  Optional[String]        $default_base_name         = undef,
  Optional[String]        $default_template_name     = undef,
  Boolean                 $default_disable_snapshots = true,
) {
  include ::gitlab::cirunner

  create_resources('gitlab::runners::parallels', $runners)
}
