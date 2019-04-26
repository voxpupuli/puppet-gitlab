require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_module
install_module_dependencies

RSpec.configure do |c|
  # Configure all nodes
  c.before :suite do
    # The omnibus installer use the following algorithm to know what to do.
    # https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-cookbooks/runit/recipes/default.rb
    # If this peace of code trigger docker case, the installer hang indefinitly.
    pp = %(
      file {'/.dockerenv':
        ensure => absent,
      }
      package { ['curl']:
        ensure => present,
      }
    )

    apply_manifest(pp, catch_failures: true)

    # https://gitlab.com/gitlab-org/omnibus-gitlab/issues/2229
    # There is no /usr/share/zoneinfo in latest Docker image for ubuntu 16.04
    # Gitlab installer fail without this file
    tzdata = %(
      package { ['tzdata']:
        ensure => present,
      }
    )

    apply_manifest(tzdata, catch_failures: true) if fact('os.release.major') =~ %r{(16.04|18.04)}
  end
end
