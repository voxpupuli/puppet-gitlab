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

[![Build Status](https://travis-ci.org/vshn/puppet-gitlab.svg)](https://travis-ci.org/vshn/puppet-gitlab)
[![vshn-gitlab](https://img.shields.io/puppetforge/v/vshn/gitlab.svg)](https://forge.puppetlabs.com/vshn/gitlab)

## Module Description

The module installs the Gitlab package from the provided repositories and creates the configuration file
which is then used by `gitlab-ctl reconfigure` to configure all the services. *Fun fact: This really uses
Chef to configure all the services.*

Supported are Debian based (Ubuntu, Debian) and RedHat based (CentOS, RHEL) operating systems. Although the
RedHat based are not yet tested.

As Gitlab is providing the package repo since 7.10+, this module only works with CE edition greater than 7.10.
Also the enterprise edition package is only available since 7.11+. So the EE is supported with versions greater
than 7.11.

## Setup

### What gitlab affects

* Package repository (APT or YUM)
* Package `gitlab-ce` oder `gitlab-ee` (depending on the chosen edition)
* Configuration file `/etc/gitlab/gitlab.rb`
* System service `gitlab-runsvdir`
* Gitlab configuration using `gitlab-ctl reconfigure`

### Setup Requirements

Have a look at the official [download page](https://about.gitlab.com/downloads/) for the required
prerequisits (f.e. Postfix). This module doesn't handle them, that's the job
of the specific modules.

It requires only the [puppetlabs-apt](https://forge.puppetlabs.com/puppetlabs/apt) module when using it under
a Debian based OS and the paramater `manage_package_repo` is not false. Furthermore the `stdlib` module is required.

### Beginning with Gitlab

Just include the class and specify at least `external_url`.

```
class { 'gitlab':
  external_url => 'http://gitlab.mydomain.tld',
}
```

The module also supports Hiera, here comes an example:

```
gitlab::external_url: 'http://gitlab.mydomain.tld'
gitlab::rails:
  time_zone: 'UTC'
  gitlab_email_enabled: false
  gitlab_default_theme: 4
  gitlab_email_display_name: 'Gitlab'
gitlab::sidekiq:
  shutdown_timeout: 5
```

If one wants to install Gitlab Enterprise Edition, just define the parameter `edition` with the value `ee`:
```
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
```
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

## Limitations

The supported operating systems by Gitlab Omnibus are to be found on the official [download page](https://about.gitlab.com/downloads/).
At the moment the module is not yet tested under RPM based operating systems. But in theory it should work
as all the preparations are there.

## Development

1. Fork it (https://github.com/vshn/puppet-gitlab/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Make sure your PR passes the Rspec tests.

## Why another Gitlab module

There exists a great module from @spuder: https://github.com/spuder/puppet-gitlab
Many thanks for the great work done there. Gitlab itself is an ever changing piece of software. Lately
they added the package repository which makes a lot of things easier. This was one reason to rewrite the module.
The other reason was that the other Gitlab module exposes ALL possible parameters of `gitlab.rb` which makes
it a pain to maintain. This module makes it much easier by just exposing the sections. So it is hopefully
much more compatible to upcoming versions of Gitlab.
