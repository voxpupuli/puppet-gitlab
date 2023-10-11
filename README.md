# GitLab module for Puppet

[![Build Status](https://travis-ci.org/voxpupuli/puppet-gitlab.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-gitlab)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/gitlab.svg)](https://forge.puppetlabs.com/puppet/gitlab)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/gitlab.svg)](https://forge.puppetlabs.com/puppet/gitlab)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/gitlab.svg)](https://forge.puppetlabs.com/puppet/gitlab)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/gitlab.svg)](https://forge.puppetlabs.com/puppet/gitlab)

## Table of Contents

1. [Overview](#overview)
1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with GitLab](#setup)
    * [What GitLab affects](#what-gitlab-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with GitLab](#beginning-with-gitlab)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module installs and manages [GitLab][1]. It makes use of the
provided [Omnibus][2] packages and the [packagecloud][3] package repositories.

Please note: The module [vshn/gitlab][4] has been deprecated and is now
available under Vox Pupuli [puppet/gitlab][5].

## Module Description

The module installs the GitLab package from the provided repositories and
creates the configuration file which is then used by `gitlab-ctl reconfigure` to
configure all the services. *Fun fact: This really uses Chef to configure all
the services.*

Supported are Debian based (Ubuntu, Debian) and RedHat based (CentOS, RHEL)
operating systems.

Beaker acceptance tests are run in Travis for supported versions of CentOS and
Ubuntu.

This module is designed to support the most recent versions of the
gitlab-omnibus package (both ce and ee). GitLab will support and release patches
for the last 3 releases. This module can typically support the most recent major
version, as well as the previous major version, but is currently only tested in
the gitlab-supported versions of the module.

If you find configurations or features in gitlab-omnibus that are not supported
by this module, please open an issue or submit a pull request.

Current Support Status

| gitlab-omnibus version | support of gitlab.rb configurations |
| --- | --- |
| 11.x | Mostly implemented, supported configs are stable | will implement any needed enhancements |
| 10.x | All configs implemented and stable | Will implement any enhancements that aren't deprecated or breaking for gitlab 11+ |

For older versions of GitLab, you may find an older version of this module to
work better for you, as this module changes over time to support the valid
configuration of versions of the gitlab-omnibus supported by the gitlab
engineering team. The oldest versions of this puppet module were designed to
support gitlab-omnibus 7.10, and may be unstable even then.

## Setup

### What GitLab affects

* Package repository (APT or YUM)
* Omnibus gitlab package, typically `gitlab-ce` or `gitlab-ee`
* Configuration file `/etc/gitlab/gitlab.rb`
* System service `gitlab-runsvdir`
* GitLab configuration using `gitlab-ctl reconfigure`

### Setup Requirements

Have a look at the official [download page][6] for the required prerequisits
(f.e. Postfix). This module doesn't handle them, that's the job of the specific
modules.

It requires only the [puppetlabs/apt][7] module when using it under a Debian
based OS and the parameter `manage_package_repo` is not false. Furthermore the
`stdlib` module is required.

At least on RedHat based OS versions, it's required that Puppet is configured
with the [`stringify_facts`][8] setting set to `false` (Puppet < 4.0), otherwise
the `$::os` fact used in `install.pp` doesn't work as expected.

### Beginning with GitLab

Just include the class and specify at least `external_url`. If `external_url` is
not specified it will default to the FQDN fact of the system.

```puppet
class { 'gitlab':
  external_url => 'http://gitlab.mydomain.tld',
}
```

The module also supports Hiera, here comes an example:

```yaml
gitlab::external_url: 'http://gitlab.mydomain.tld'
gitlab::gitlab_rails:
  time_zone: 'UTC'
  gitlab_email_enabled: false
  gitlab_default_theme: 4
  gitlab_email_display_name: 'GitLab'
gitlab::sidekiq:
  shutdown_timeout: 5
```

If one wants to install GitLab Enterprise Edition, just define the parameter
`manage_upstream_edition` with the value `ee`:

```puppet
class { 'gitlab':
  external_url => 'http://gitlab.mydomain.tld',
  manage_upstream_edition      => 'ee',
}
```

*Note*: This works only for GitLab version 7.11 and greater. See this blog
entry: [GitLab 7.11 released with Two-factor Authentication and a publicly
viewable Enterprise Edition][9]

## Usage

The main class (`init.pp`) exposes the configuration sections from the
`gitlab.rb` configuration file as hashes. So if there are any parameter changes
in future versions of GitLab, the module should support them right out of the
box. Only if there would be bigger changes to sections, the module would need
some updates.

All possible parameters for `gitlab.rb` can be found here: [gitlab.rb.template][10]

Some examples:

```puppet
class { 'gitlab':
  external_url => 'http://gitlab.mydomain.tld',
  gitlab_rails => {
    'webhook_timeout' => 10,
    'gitlab_default_theme' => 2,
  },
  logging      => {
    'svlogd_size' => '200 * 1024 * 1024',
  },
}
```

### Service management

GitLab Omnibus is designed to manage it's own services internally. The
`gitlab-runsvdir` service isn't a typical service that you would manage with
puppet, it is a monitoring service for the other services gitlab will create
based on your selected configuration. Starting, stopping and restarting the
`gitlab-runsvdir` service should only be done by `gitlab-ctl` commands. Service
restart is also handled implicitly during installation and upgrades, and does
not normally need to be triggered by puppet.

If you find yourself needing to modify this behavior, you can set
`service_manage => true` to have puppet ensure the service is running.

Setting `service_provider_restart => true` will cause puppet to trigger a
`gitlab-ctl restart` command to be issued following any configuration change
managed by puppet.

### Package & Repository Configuration

#### Repository Resource Configuration

This module allows you a great range of options when configuring the repository
and package sources on your host. By default, the gitlab repository will be
configured to use the upstream source from [packagecloud][3]. However, if you
wish to use a different repository source, you can provide your own `yumrepo`,
`apt` or any other package/repository configuration you wish.

This module does this by iterating through configurations provided to
`gitlab::omnibus_package_repository::repository_configuration`. You can provide
any number of repository resource types and configurations you want, as long as
the dependent modules are installed on your basemodulepath.

This approach provides the following advantages:

* means any and all parameters supported by your repository manager module are
  inherently supported by the `gitlab` module
* you aren't required to use a version of a dependency we specify, supporting a
  wide range of versions for modules like `apt`
* you can easily add more required repositories and packages as needed by your
  infrastructure, and ensure ordering is managed within the `gitlab` module
  before any GitLab related packages are installed

In order to provide your own repository configurations, you are required to set
`manage_upstream_edition => disabled`, and provide a hash of repository resource
type configurations in the following format:

```yaml
gitlab::repository_configuration:
  repository_resource_type: #ex... 'apt::source` or `apt::pin` or `yumrepo`
    repository_resource_title:
      repository_resource_attribute1: 'value'
      repository_resource_attribute2: 'value'
```

Examples/defaults for `yumrepo` can be found at `data/RedHat.yaml`, and for
`apt` at `data/Debian.yaml`.

You could also do things like:

* add an additional repository at the same level as
  `internal_mirror_of_gitlab_official_ce` (for example if you wanted to use your
  own package `nginx` instead of the one provided in omnibus-gitlab)
* add any other high level resource types from the `apt` module at the level of
  `apt:source`. (`apt::pin`, `apt::key`, etc...)

Each unique resource provided to the `repository_configuration` setup:

* gets tagged with `gitlab_omnibus_package_resource`
* gets the `before => Class['gitlab::install']` metaparameter.

You can use these tags to further customize ordering within your own catalogs.

#### Selecting Version, edition, and package name

The `package_ensure` parameter is used to control which version of the package
installed. It expects either a version string, or one of the `ensure` values for
the `Package` resource type. Default is `installed`. This value works with the
`package_name` parameter to install the correct package.

If you are using upstream package source, the package name automatically
switches between `gitlab-ce` and `gitlab-ee` depending on the value you have
provided to `manage_upstream_edition`. If `manage_upstream_edition` is set to
`disabled`, you will need to provide the appropriate value to `package_name`
yourself.

This approach of package management has the following advantages:

* more easily adaptable if GitLab changes package naming based on editions
  (won't require you to install new puppet-gitlab module if you're not ready)
* allows you to install custom built packages for gitlab-omnibus that have
  different package name on your host

#### Custom Repository & Package configuration example

As an expanded example of repository and package configuration, let's assume you're:

* using a private mirror of the upstream GitLab‚ package channel
* hosted inside your organizations firewall
* installing gitlab-omnibus enterprise edition

```puppet
class { 'gitlab':
  external_url => 'http://gitlab.mydomain.tld',
  manage_upstream_edition => 'disabled',
  package_name => 'gitlab-ee',
  repository_configuration => {
    'apt::source' => {
      'internal_mirror_of_gitlab_official_ce' => {
        'comment' => 'Internal mirror of upstream GitLab package repository',
        'location' => 'https://my.internal.url/repository/packages.gitlab.com/gitlab/gitlab-ce/debian',
        'key' => {
          'id' => 'F6403F6544A38863DAA0B6E03F01618A51312F3F',
          'source' => 'https://my.internal.url/repository/package.gitlab.com/gpg.key'
        }
      },
    }
  }
}
```

### GitLab secrets

*Note:* `gitlab::secrets` parameter was removed in v3.0.0. See: [Issues#213 -
Remove support for setting content of `gitlab-secrets.json`][11]

When using HA role `application_role`, make sure to add the [appropriate shared
secrets][12] to your `gitlab_rails` and `gitlab_shell` hashes to ensure
front-end nodes are configured to access all backend data-sources and
repositories. If you receive 500 errors on your HA setup, this is one of the
primary causes.

### LDAP configuration example

Here is an example how to configure LDAP using Hiera:

```yaml
gitlab::gitlab_rails:
  ldap_enabled: true
  ldap_servers:
    myldapserver:
      label: 'Company LDAP'
      host: 'ldap.company.tld'
      port: 389
      uid: 'uid'
      method: 'plain' # "tls" or "ssl" or "plain"
      bind_dn: 'MYBINDDN'
      password: 'MYBINDPW'
      active_directory: false
      allow_username_or_email_login: false
      block_auto_created_users: false
      base: 'MYBASEDN'
      group_base: 'MYGROUPBASE'
      user_filter: ''
```

### NGINX Configuration

Configuration of the embedded NGINX instance is handled by the
`/etc/gitlab/gitlab.rb` file. Details on available configuration options are
available at [https://docs.gitlab.com/omnibus/settings/nginx.html][NGINX settings].
Options listed there can be passed in to the `nginx` parameter as a hash.
For example, to enable redirection from HTTP to HTTPS:

```puppet
class { 'gitlab':
  external_url => 'https://gitlab.mydomain.tld',
  nginx        => {
    redirect_http_to_https => true,
  },
}
```

Similarly, the certificate and key location can be configured as follows:

```puppet
class { 'gitlab':
  external_url => 'https://gitlab.mydomain.tld',
  nginx        => {
    ssl_certificate     => '/etc/gitlab/ssl/gitlab.example.com.crt',
    ssl_certificate_key => '/etc/gitlab/ssl/gitlab.example.com.key'
  },
}
```

### Skip Auto Reconfigure (formerly Skip Auto Migrations)

In order to achieve [Zero Downtime Upgrades][14] of your GitLab instance, GitLab
will need to skip the post-install step of the omnibus package that
automatically calls `gitlab-ctl reconfigure` for you. In GitLab < 10.5, GitLab
check for the presence of a file at `/etc/gitlab/skip-auto-migrations`. As of
GitLab `10.6`, this is deprecated, and you are warned to use
`/etc/gitlab/skip-auto-reconfigure` going forward.

Both of these are currently supported in this module, and you should be aware of
which option is right for you based on the version of GitLab Omnibus you are
running.  You will be presented with a deprecation notice in you puppet client
if using the deprecated form.

```puppet
# use 'absent' or 'present' for the skip_auto_reconfigure param
class { 'gitlab':
  skip_auto_reconfigure => 'present'
}

# use true/false for the skip_auto_migrations param
class { 'gitlab':
  skip_auto_migrations => true
}
```

### GitLab Custom Hooks

Manage custom hook files within a GitLab project. Custom hooks can be created as
a pre-receive, post-receive, or update hook. It's possible to create different
custom hook types for the same project - one each for pre-receive, post-receive
and update.

```puppet
gitlab::custom_hook { 'my_custom_hook':
  namespace       => 'my_group',
  project         => 'my_project',
  type            => 'post-receive',
  source          => 'puppet:///modules/my_module/post-receive',
}
```

or via hiera

```yaml
gitlab::custom_hooks:
  my_custom_hook:
    namespace: my_group
    project: my_project
    type: post-receive
    source: 'puppet:///modules/my_module/post-receive'
```

Since GitLab Shell 4.1.0 and GitLab 8.15 Chained hooks are supported. You can
create global hooks which will run for each repository on your server. Global
hooks can be created as a pre-receive, post-receive, or update hook.

```puppet
gitlab::global_hook { 'my_custom_hook':
  type            => 'post-receive',
  source          => 'puppet:///modules/my_module/post-receive',
}
```

or via hiera

```yaml
gitlab::global_hooks:
  my_custom_hook:
    type: post-receive
    source: 'puppet:///modules/my_module/post-receive'
```

### Gitlab System Hooks

A [file hook][22] will run on each event so it's up to you to filter events or
projects within a file hook code. You can have as many file hooks as you want.
Each file hook will be triggered by GitLab asynchronously in case of an event.
For a list of events see the [system hooks documentation][21].

```puppet
gitlab::system_hook { 'my_custom_hook':
  source          => 'puppet:///modules/my_module/file-hook',
}
```

or via hiera

```yaml
gitlab::system_hooks:
  my_custom_hook:
    source: 'puppet:///modules/my_module/file-hook'
```

### Fast Lookup of SSH keys

GitLab instances with a large number of users may notice slowdowns when making
initial connections for ssh operations. GitLab has created a feature that allows
authorized ssh keys to be stored in the db (instead of the `authorized_keys`
file for the `git` user)

You can enable this feature in GitLab using the `store_git_keys_in_db` parameter,
or by enabling `gitlab-sshd` as it is configured to use fast lookup automatically.

Please note, while you can manage [gitlab-sshd][23] (Gitlab's standalone SSH server)
with this module, you can not manage openssh and the sshd service as it is outside
the scope of the module. You will need to configure the AuthorizedKeysCommand
for the `git` user in sshd.server yourself. Instructions for this are provided by
GitLab at [Fast lookup of authorized SSH keys in the databasse][15]

### Setting up GitLab HA

#### pgbouncer Authentication

For use in HA configurations, or when using postgres replication in a
single-node setup, this module supports automated configuration of pgbouncer
authentication. To set this up, set `pgpass_file_ensure => 'present'` and
provide a valid value for `pgbouncer_password`.

```puppet
class {'gitlab':
  pgpass_file_ensure => 'present',
  pgbouncer_password => 'YourPassword'
}
```

By default, this creates a file at `/home/gitlab-consul/.pgpass`, which gitlab
uses to authenticate to the pgbouncer database as the `gitlab-consul` _database_
user. This _does not_ refer to the `gitlab-consul` system user. The location of
the `.pgpass` file can be changed based on how you manage homedirs or based on
your utilization of NFS. This location should be set to be the home directory
you have configured for the `gitlab-consul` system user.

```puppet
class {'gitlab':
  pgpass_file_location => '/homedir/for/gitlab-consul-system-user/.pgpass'
}
```

## Tasks

The GitLab module has a task that allows a user to upgrade the pgsql database
GitLab uses if upgrading from version 9.2.18, which is required to upgrade
GitLab past 10.  When running the tasks on the command line, you will need to
use the `--sudo`, `--run-as-root`, and `--tty` flags to execute the commands as
needed for your environment.

Please refer to to the [PE documentation][16] or [Bolt documentation][17] on how
to execute a task.

## Development

1. Fork on [Github][18]
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request

Make sure your PR passes the Rspec tests.

## Contributors

Have a look at [Github contributors][19] to see a list of all the awesome
contributors to this Puppet module. <3 This module was created and maintained by
[VSHN AG][20] until the end of 2017. It was then donated to Voxpupuli so that a
broader community is able to maintain the module.‚

[1]: https://about.gitlab.com
[2]: https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md
[3]: https://packages.gitlab.com/gitlab
[4]: https://forge.puppet.com/vshn/gitlab
[5]: https://forge.puppet.com/puppet/gitlab
[6]: https://about.gitlab.com/downloads
[7]: https://forge.puppetlabs.com/puppetlabs/apt
[8]: https://docs.puppetlabs.com/references/3.stable/configuration.html#stringifyfacts
[9]: https://about.gitlab.com/2015/05/22/gitlab-7-11-released
[10]: https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template
[11]: https://github.com/voxpupuli/puppet-gitlab/issues/213
[12]: https://docs.gitlab.com/ee/administration/high_availability/gitlab.html#extra-configuration-for-additional-gitlab-application-servers
[13]: https://docs.gitlab.com/omnibus/settings/nginx.html
[14]: https://docs.gitlab.com/omnibus/update/README.html#zero-downtime-updates
[15]: https://docs.gitlab.com/ee/administration/operations/fast_ssh_key_lookup.html
[16]: https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html
[17]: https://puppet.com/docs/bolt/latest/bolt.html
[18]: https://github.com/voxpupuli/puppet-gitlab/fork
[19]: https://github.com/voxpupuli/puppet-gitlab/graphs/contributors
[20]: https://vshn.ch
[21]: https://docs.gitlab.com/ee/system_hooks/system_hooks.html
[22]: https://docs.gitlab.com/ee/administration/file_hooks.html
[23]: https://docs.gitlab.com/ee/administration/operations/gitlab_sshd.html
