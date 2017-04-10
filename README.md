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

[![Build Status](https://api.travis-ci.org/vshn/puppet-gitlab.svg?branch=master)](https://travis-ci.org/vshn/puppet-gitlab)
[![vshn-gitlab](https://img.shields.io/puppetforge/v/vshn/gitlab.svg)](https://forge.puppetlabs.com/vshn/gitlab)

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
* Package `gitlab-ce` or `gitlab-ee` (depending on the chosen edition)
* Configuration file `/etc/gitlab/gitlab.rb`
* System service `gitlab-runsvdir`
* Gitlab configuration using `gitlab-ctl reconfigure`

### Setup Requirements

Have a look at the official [download page](https://about.gitlab.com/downloads/) for the required
prerequisits (f.e. Postfix). This module doesn't handle them, that's the job
of the specific modules.

It requires only the [puppetlabs-apt](https://forge.puppetlabs.com/puppetlabs/apt) module when using it under
a Debian based OS and the paramater `manage_package_repo` is not false. Furthermore the `stdlib` module is required.

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

If one wants to install Gitlab Enterprise Edition, just define the parameter `edition` with the value `ee`:

```puppet
class { 'gitlab':
  external_url => 'http://gitlab.mydomain.tld',
  edition      => 'ee',
}
```

*Note*: This works only for Gitlab version 7.11 and greater. See this blog entry: [GitLab 7.11 released with Two-factor Authentication and a publicly viewable Enterprise Edition](https://about.gitlab.com/2015/05/22/gitlab-7-11-released/)


## Usage

To find the default values, have a look at `params.pp`. All other parameters are documented
inside `init.pp`.

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

### Gitlab secrets

To manage `/etc/gitlab/gitlab-secrets.json` the parameter `secrets` accepts a hash.
Here is an example how to use it with Hiera:

```yaml
gitlab::secrets:
  gitlab_shell:
    secret_token: 'asecrettoken1234567890'
  gitlab_rails:
    secret_token: 'asecrettoken123456789010'
  gitlab_ci:
    secret_token: null
    secret_key_base: 'asecrettoken123456789011'
    db_key_base: 'asecrettoken123456789012'
```

*Hint 1*: This secret tokens can be generated f.e. using Ruby with `SecureRandom.hex(64)`, or
taken out of an installation without having `secrets` used.
*Hint 2*: When using the `gitlab_ci` parameter to specify the `gitlab_server`, then this parameters
must be added also to the `secrets` hash (Omnibus overrides `gitlab-secrets.json`).

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

### Enable Gitlab Embedded Prometheus

Currently there is not a lot to be done here, as Gitlab pretty much only support on or off (default). To do with Hiera:

```yaml
gitlab::prometheus:
  enable: true
```

If you are using Gitlab 8.17, you can change the listening address with:

```yaml
gitlab::prometheus:
  enable: true
  listen_address: 'localhost:9091'
```

### Gitlab CI Runner Config

Here is an example how to configure Gitlab CI runners using Hiera:

To use the Gitlab CI runners it is required to have the [garethr/docker](https://forge.puppetlabs.com/garethr/docker) module.

`$manage_docker` can be set to false if docker is managed externaly.

```yaml
classes:
  - gitlab::cirunner

gitlab::cirunner::concurrent: 4

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

## Limitations

The supported operating systems by Gitlab Omnibus are to be found on the official [download page](https://about.gitlab.com/downloads/).
At the moment the module is not yet tested under RPM based operating systems. But in theory it should work
as all the preparations are there.

### Gitlab CI Runner Limitations

The Gitlab CI runner installation is at the moment only tested on Ubuntu 14.04.

## Development

1. Fork it (https://github.com/vshn/puppet-gitlab/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Make sure your PR passes the Rspec tests.

## Contributors

Have a look at [Github contributors](https://github.com/vshn/puppet-gitlab/graphs/contributors) to see a list of all the awesome contributors to this Puppet module. <3

