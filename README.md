#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with gitlab](#setup)
    * [What gitlab affects](#what-gitlab-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with gitlab](#beginning-with-gitlab)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module installs and manages [Gitlab](https://about.gitlab.com/).
It makes use of the provided [Omnibus](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md) packages and the [packagecloud package repositories](https://packages.gitlab.com/gitlab).

[![Build Status](https://api.travis-ci.org/voxpupuli/puppet-gitlab.svg?branch=master)](https://travis-ci.org/voxpupuli/puppet-gitlab)
[![puppet-gitlab](https://img.shields.io/puppetforge/v/puppet/gitlab.svg)](https://forge.puppetlabs.com/puppet/gitlab)

Please note: The module [vshn/gitlab](https://forge.puppet.com/vshn/gitlab) has been deprecated
and is now available under Vox Pupuli [puppet/gitlab](https://forge.puppet.com/puppet/gitlab).

## Module Description

The module installs the Gitlab package from the provided repositories and creates the configuration file
which is then used by `gitlab-ctl reconfigure` to configure all the services. *Fun fact: This really uses
Chef to configure all the services.*

Supported are Debian based (Ubuntu, Debian) and RedHat based (CentOS, RHEL) operating systems.

Beaker acceptance tests are run in Travis for CentOS 6 and Ubuntu 12.04.

As Gitlab is providing the package repo since 7.10+, this module only works with CE edition greater than 7.10.
Also the enterprise edition package is only available since 7.11+. So the EE is supported with versions greater
than 7.11.

## Setup

### What gitlab affects

* Package repository (APT or YUM)
* Omnibus gitlab package, typically `gitlab-ce` or `gitlab-ee`
* Configuration file `/etc/gitlab/gitlab.rb`
* System service `gitlab-runsvdir`
* Gitlab configuration using `gitlab-ctl reconfigure`

### Setup Requirements

Have a look at the official [download page](https://about.gitlab.com/downloads/) for the required
prerequisits (f.e. Postfix). This module doesn't handle them, that's the job
of the specific modules.

It requires only the [puppetlabs-apt](https://forge.puppetlabs.com/puppetlabs/apt) module when using it under
a Debian based OS and the parameter `manage_package_repo` is not false. Furthermore the `stdlib` module is required.

At least on RedHat based OS versions, it's required that Puppet is configured with
the [`stringify_facts`](https://docs.puppetlabs.com/references/3.stable/configuration.html#stringifyfacts) setting set to `false` (Puppet < 4.0), otherwise
the `$::os` fact used in `install.pp` doesn't work as expected.

### Beginning with Gitlab

Just include the class and specify at least `external_url`. If `external_url` is not specified it will default to the FQDN fact of the system.

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
  gitlab_email_display_name: 'Gitlab'
gitlab::sidekiq:
  shutdown_timeout: 5
```

If one wants to install Gitlab Enterprise Edition, just define the parameter `manage_upstream_edition` with the value `ee`:

```puppet
class { 'gitlab':
  external_url => 'http://gitlab.mydomain.tld',
  manage_upstream_edition      => 'ee',
}
```

*Note*: This works only for Gitlab version 7.11 and greater. See this blog entry: [GitLab 7.11 released with Two-factor Authentication and a publicly viewable Enterprise Edition](https://about.gitlab.com/2015/05/22/gitlab-7-11-released/)


## Usage

The main class (`init.pp`) exposes the configuration sections from the `gitlab.rb` configuration file
as hashes. So if there are any parameter changes in future versions of Gitlab, the module should support
them right out of the box. Only if there would be bigger changes to sections, the module would need
some updates.

All possible parameters for `gitlab.rb` can be found here: [gitlab.rb.template](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template)

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

### Package & Repository Configuration

#### Repository Resource Configuration

This module allows you a great range of options when configuring the repository and package sources on your host. By default,
the gitlab repository will be configured to use the upstream source from [https://packages.gitlab.com][]. However, if you wish
to use a different repository source, you can provide your own `yumrepo`, `apt` or any other package/repository configuration you wish.

This module does this by iterating through configurations provided to `gitlab::omnibus_package_repository::repository_configuration`. You
can provide any number of repository resource types and configurations you want, as long as the dependent modules are installed on your basemodulepath.

This approach provides the following advantages:
 - means any and all parameters supported by your repository manager module are inherently supported by the `gitlab` module
 - you aren't required to use a version of a dependency we specify, supporting a wide range of versions for modules like `apt`
 - you can easily add more required repositories and packages as needed by your infrastructure, and ensure ordering is managed
 within the gitlab module before any gitlab related packages are installed

In order to provide your own repository configurations, you are required to set `manage_upstream_edition => disabled`, and provide a hash
of repository resource type configurations in the following format:

```
repository_resource_type: #ex... 'apt::source` or `apt::pin` or `yumrepo`
  repository_resource_title:
    repository_resource_attribute1: 'value'
    repository_resource_attribute2: 'value'
```

Examples/defaults for `yumrepo` can be found at `data/RedHat.yaml`, and for `apt` at `data/Debian.yaml`.


You could also do things like:
 - add an additional repository at the same level as `internal_mirror_of_gitlab_official_ce` (for example if you wanted to use your own package `nginx` instead of
 the one provided in omnibus-gitlab)
 - add any other high level resource types from the `apt` module at the level of `apt:source`. (`apt::pin`, `apt::key`, etc...)

Each unique resource provided to the `repository_configuration` setup:
 - gets tagged with `gitlab_omnibus_package_resource`
 - gets the `before => Class['gitlab::install']` metaparameter.

You can use these tags to further customize ordering within your own catalogs.

#### Selecting Version, edition, and package name

The `package_ensure` parameter is used to control which version of the package installed. It expects either a version string, or one of the `ensure`
values for the `Package` resource type. Default is `installed`. This value works with the `package_name` parameter to install the correct package.

If you are using upstream package source, the package name automatically switches between `gitlab-ce` and `gitlab-ee` depending on the value you have
provided to `manage_upstream_edition`. If `manage_upstream_edition` is set to `disabled`, you will need to provide the appropriate value to `package_name`
yourself.

This approach of package management has the following advantages:
 - more easily adaptable if gitlab changes package naming based on editions (won't require you to install new puppet-gitlab module if you're not ready)
 - allows you to install custom built packages for gitlab-omnibus that have different package name on your host

#### Custom Repository & Package configuraiton example

As an expanded example of repository and package configuration, let's assume you're:
 - using a private mirror of the upstream gitlab package channel
 - hosted inside your organizations firewall
 - installing gitlab-omnibus enterprise edition

```
class { 'gitlab':
  external_url => 'http://gitlab.mydomain.tld',
  manage_upstream_edition => 'disabled',
}

class { 'gitlab::install':
  package_name => 'gitlab-ee'
}

class { 'gitlab::omnibus_package_repository':
  repository_configuration => {
    'apt::source' => {
      'internal_mirror_of_gitlab_official_ce' => {
        'comment' => 'Internal mirror of upstream gitlab package repository',
        'location' => 'https://my.internal.url/repository/packages.gitlab.com/gitlab/gitlab-ce/debian',
        'key' => {
          'id' => '1A4C919DB987D435939638B914219A96E15E78F4',
          'source' => 'https://my.internal.url/repository/package.gitlab.com/gpg.key'
        }
      },
    }
  }
}
```
### Gitlab secrets

*Note:* `gitlab::secrets` parameter was removed in v3.0.0. See: [Issues#213 - Remove support for setting content of `gitlab-secrets.json`](https://github.com/voxpupuli/puppet-gitlab/issues/213)

When using HA role `application_role`, make sure to add the [appropriate shared secrets](https://docs.gitlab.com/ee/administration/high_availability/gitlab.html#extra-configuration-for-additional-gitlab-application-servers) to your `gitlab_rails` and `gitlab_shell` hashes to ensure front-end nodes
are configured to access all backend data-sources and repositories. If you receive 500 errors on your HA setup, this is one of the primary causes.

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

### Gitlab CI Runner Config

Here is an example how to configure Gitlab CI runners using Hiera:

To use the Gitlab CI runners it is required to have the [puppetlabs/docker](https://forge.puppetlabs.com/puppetlabs/docker) module.

`$manage_docker` can be set to false if docker is managed externally.

```yaml
classes:
  - gitlab::cirunner

gitlab::cirunner::concurrent: 4

gitlab::cirunner::metrics_server: "localhost:8888"

gitlab_ci_runners:
  test_runner1:{}
  test_runner2:{}
  test_runner3:
    url: "https://git.alternative.org/ci"
    registration-token: "abcdef1234567890"

gitlab_ci_runners_defaults:
  url: "https://git.example.com/ci"
  registration-token: "1234567890abcdef"
  executor: "docker"
  docker-image: "ubuntu:trusty"
```

To unregister a specific runner you may use `ensure` param:

```yaml
gitlab_ci_runners:
  test_runner1:{}
  test_runner2:{}
  test_runner3:
    url: "https://git.alternative.org/ci"
    registration-token: "abcdef1234567890"
    ensure: absent
```


### NGINX Configuration

Configuration of the embedded NGINX instance is handled by the `/etc/gitlab/gitlab.rb` file. Details on available configuration options are available at http://doc.gitlab.com/omnibus/settings/nginx.html. Options listed here can be passed in to the `nginx` parameter as a hash. For example, to enable ssh redirection:

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

In order to achieve [Zero Downtime Upgrades](https://docs.gitlab.com/omnibus/update/README.html#zero-downtime-updates)
of your GitLab instance, GitLab will need to skip the post-install step of the omnibus package that automatically calls
`gitlab-ctl reconfigure` for you. In GitLab < 10.5, GitLab check for the presence of a file at `/etc/gitlab/skip-auto-migrations`.
As of GitLab `10.6`, this is deprecated, and you are warned to use `/etc/gitlab/skip-auto-reconfigure` going forward.

Both of these are currently supported in this module, and you should be aware of which option is right for you
based on the version of GitLab Omnibus you are running.  You will be presented with a deprecation notice in you
puppet client if using the deprecated form.

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

### Gitlab Custom Hooks

Manage custom hook files within a GitLab project. Custom hooks can be created
as a pre-receive, post-receive, or update hook. It's possible to create
different custom hook types for the same project - one each for pre-receive,
post-receive and update.

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

### Fast Lookup of SSH keys

GitLab instances with a large number of users may notice slowdowns when making initial connections for ssh operations.
GitLab has created a feature that allows authorized ssh keys to be stored in the db (instead of the `authorized_keys`
file for the `git` user)

You can enable this feature in GitLab using the `store_git_keys_in_db` parameter.

Please note, managing the sshd service and openssh is outside the scope of this module.
You will need to configure the AuthorizedKeysCommand for the `git` user in sshd.server yourself.
Instructions for this are provided by GitLab at
[Fast lookup of authorized SSH keys in the databasse](https://docs.gitlab.com/ee/administration/operations/fast_ssh_key_lookup.html)

### Gitlab CI Runner Limitations

The Gitlab CI runner installation is at the moment only tested on Ubuntu 14.04.

## Tasks

The Gitlab module has a task that allows a user to upgrade the pgsql database Gitlab uses if upgrading from version 9.2.18, which is required to upgrade Gitlab past 10.  When running the tasks on the command line, you will need to use the `--sudo`, `--run-as-root`, and `--tty` flags to execute the commands as needed for your environment.


Please refer to to the [PE documentation](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html) or [Bolt documentation](https://puppet.com/docs/bolt/latest/bolt.html) on how to execute a task.

## Development

1. Fork it (https://github.com/voxpupuli/puppet-gitlab/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Make sure your PR passes the Rspec tests.

## Contributors

Have a look at [Github contributors](https://github.com/voxpupuli/puppet-gitlab/graphs/contributors) to see a list of all the awesome contributors to this Puppet module. <3
This module was created and maintained by [VSHN AG](https://vshn.ch/) until the end of 2017. It was then donated
to Voxpupuli so that a broader community is able to maintain the module.
