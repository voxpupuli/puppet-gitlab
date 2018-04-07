# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v2.0.0](https://github.com/voxpupuli/puppet-gitlab/tree/v2.0.0) (2018-04-07)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.16.1...v2.0.0)

**Breaking changes:**

- git\_data\_dirs not documented, deprecate git\_data\_dir [\#159](https://github.com/voxpupuli/puppet-gitlab/issues/159)
- remove auto-execution of gitlab:setup [\#210](https://github.com/voxpupuli/puppet-gitlab/pull/210) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- remove git\_data\_dir [\#209](https://github.com/voxpupuli/puppet-gitlab/pull/209) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))

**Implemented enhancements:**

- Migrate Puppet Module to Voxpupuli [\#171](https://github.com/voxpupuli/puppet-gitlab/issues/171)
- Feature: Allow database to index git authorized\_keys [\#168](https://github.com/voxpupuli/puppet-gitlab/issues/168)
- data dir changes in gitlab 9 [\#137](https://github.com/voxpupuli/puppet-gitlab/issues/137)
- add letsencrypt section to gitlab.rb [\#200](https://github.com/voxpupuli/puppet-gitlab/pull/200) ([costela](https://github.com/costela))
- Add ha roles [\#186](https://github.com/voxpupuli/puppet-gitlab/pull/186) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- drop legacy is\_hash method, replace topscope fact with facts hash [\#107](https://github.com/voxpupuli/puppet-gitlab/pull/107) ([james-powis](https://github.com/james-powis))

**Fixed bugs:**

- RHEL 7.2 Installation Failure \(Possibly GPG Key URL\) [\#196](https://github.com/voxpupuli/puppet-gitlab/issues/196)
- After upgrade to GitLab 10.4.3 each puppet run wants to remove  [\#195](https://github.com/voxpupuli/puppet-gitlab/issues/195)
- Fixed redhat installation [\#198](https://github.com/voxpupuli/puppet-gitlab/pull/198) ([dsavell](https://github.com/dsavell))

**Closed issues:**

- Backup cron configuration will trigger gitlab restart [\#204](https://github.com/voxpupuli/puppet-gitlab/issues/204)
- YUM GPG keys are invalid [\#203](https://github.com/voxpupuli/puppet-gitlab/issues/203)
- add support for letsencrypt options [\#199](https://github.com/voxpupuli/puppet-gitlab/issues/199)
- RPM gpg key verification failure on install [\#194](https://github.com/voxpupuli/puppet-gitlab/issues/194)

**Merged pull requests:**

- bump puppet to latest supported version 4.10.0 [\#208](https://github.com/voxpupuli/puppet-gitlab/pull/208) ([bastelfreak](https://github.com/bastelfreak))
- Move backup to its own class [\#205](https://github.com/voxpupuli/puppet-gitlab/pull/205) ([baurmatt](https://github.com/baurmatt))
- Propose small spelling change [\#185](https://github.com/voxpupuli/puppet-gitlab/pull/185) ([jeis2497052](https://github.com/jeis2497052))
- Allow managing backup cron w/o managing the config file [\#180](https://github.com/voxpupuli/puppet-gitlab/pull/180) ([mhyzon](https://github.com/mhyzon))
- Db indexing for git authorized keys [\#177](https://github.com/voxpupuli/puppet-gitlab/pull/177) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- Remove deprecated hiera and validation functions [\#119](https://github.com/voxpupuli/puppet-gitlab/pull/119) ([jkroepke](https://github.com/jkroepke))

## [v1.16.1](https://github.com/voxpupuli/puppet-gitlab/tree/v1.16.1) (2018-02-07)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.16.0...v1.16.1)

**Merged pull requests:**

- modulesync 1.7.0 take 2 [\#193](https://github.com/voxpupuli/puppet-gitlab/pull/193) ([tobru](https://github.com/tobru))
- release 1.16.1 [\#192](https://github.com/voxpupuli/puppet-gitlab/pull/192) ([tobru](https://github.com/tobru))
- modulesync 1.7.0 [\#191](https://github.com/voxpupuli/puppet-gitlab/pull/191) ([tobru](https://github.com/tobru))

## [v1.16.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.16.0) (2018-02-07)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.15.2...v1.16.0)

**Implemented enhancements:**

- Verify package signatures on RedHat [\#163](https://github.com/voxpupuli/puppet-gitlab/issues/163)

**Fixed bugs:**

- Regression: yum $releasever results in 404 error for RHEL yum repo [\#153](https://github.com/voxpupuli/puppet-gitlab/issues/153)

**Closed issues:**

- Deploy current version of GitLab Runner [\#166](https://github.com/voxpupuli/puppet-gitlab/issues/166)
- GitLab 10: Your git\_dta\_dirs settings is deprecated [\#162](https://github.com/voxpupuli/puppet-gitlab/issues/162)
- Support new package repo [\#157](https://github.com/voxpupuli/puppet-gitlab/issues/157)
- puppet-gitlab requires outdated module dependencies [\#152](https://github.com/voxpupuli/puppet-gitlab/issues/152)
- Broken LDAP  [\#138](https://github.com/voxpupuli/puppet-gitlab/issues/138)

**Merged pull requests:**

- Release 1.16.0 [\#190](https://github.com/voxpupuli/puppet-gitlab/pull/190) ([tobru](https://github.com/tobru))
- Ensure spec test use hiera fixtures. [\#181](https://github.com/voxpupuli/puppet-gitlab/pull/181) ([andrekeller](https://github.com/andrekeller))
- Update for rubocop compliance [\#179](https://github.com/voxpupuli/puppet-gitlab/pull/179) ([mterzo](https://github.com/mterzo))
- Fixes via rubocop -a [\#176](https://github.com/voxpupuli/puppet-gitlab/pull/176) ([kallies](https://github.com/kallies))
- fix typo [\#175](https://github.com/voxpupuli/puppet-gitlab/pull/175) ([bc-bjoern](https://github.com/bc-bjoern))
- initial modulesync [\#174](https://github.com/voxpupuli/puppet-gitlab/pull/174) ([tobru](https://github.com/tobru))
- Transfer module to Vox Pupuli [\#173](https://github.com/voxpupuli/puppet-gitlab/pull/173) ([tobru](https://github.com/tobru))
- Fix repo URL for RHEL 7.  Enable gpgcheck and add in gitlab-ee key. [\#172](https://github.com/voxpupuli/puppet-gitlab/pull/172) ([mhyzon](https://github.com/mhyzon))
- apt dep version bump [\#169](https://github.com/voxpupuli/puppet-gitlab/pull/169) ([minorOffense](https://github.com/minorOffense))
- Add support for metrics\_server in CI Runner [\#167](https://github.com/voxpupuli/puppet-gitlab/pull/167) ([djjudas21](https://github.com/djjudas21))
- Fix for new git\_data\_dirs syntax in Gitlab 10 [\#164](https://github.com/voxpupuli/puppet-gitlab/pull/164) ([flyinbutrs](https://github.com/flyinbutrs))
- Add backup job [\#155](https://github.com/voxpupuli/puppet-gitlab/pull/155) ([b4ldr](https://github.com/b4ldr))
- add support for chained global hooks [\#154](https://github.com/voxpupuli/puppet-gitlab/pull/154) ([hboomsma](https://github.com/hboomsma))

## [v1.15.2](https://github.com/voxpupuli/puppet-gitlab/tree/v1.15.2) (2017-09-28)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.15.1...v1.15.2)

**Closed issues:**

- Different directory name inside the Forge package [\#151](https://github.com/voxpupuli/puppet-gitlab/issues/151)

**Merged pull requests:**

- Add 'package\_name' param to cirunner class [\#160](https://github.com/voxpupuli/puppet-gitlab/pull/160) ([dandunckelman](https://github.com/dandunckelman))

## [v1.15.1](https://github.com/voxpupuli/puppet-gitlab/tree/v1.15.1) (2017-07-28)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.15.0...v1.15.1)

## [v1.15.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.15.0) (2017-07-28)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.14.0...v1.15.0)

**Closed issues:**

- pages support [\#145](https://github.com/voxpupuli/puppet-gitlab/issues/145)
- xz-utils [\#139](https://github.com/voxpupuli/puppet-gitlab/issues/139)
- Puppet forge release [\#133](https://github.com/voxpupuli/puppet-gitlab/issues/133)

**Merged pull requests:**

- Gitlab geo [\#149](https://github.com/voxpupuli/puppet-gitlab/pull/149) ([shaheed121](https://github.com/shaheed121))
- Drop warning about RPM support [\#142](https://github.com/voxpupuli/puppet-gitlab/pull/142) ([djjudas21](https://github.com/djjudas21))

## [v1.14.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.14.0) (2017-05-22)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.13.3...v1.14.0)

**Implemented enhancements:**

- Review gitlab.rb Template [\#103](https://github.com/voxpupuli/puppet-gitlab/issues/103)

**Closed issues:**

- Unable to disable prometheus monitoring due to template [\#135](https://github.com/voxpupuli/puppet-gitlab/issues/135)
- Module Compatible on Enterprise Linux ? [\#134](https://github.com/voxpupuli/puppet-gitlab/issues/134)
- Add parameter to allow to skip auto migrations [\#132](https://github.com/voxpupuli/puppet-gitlab/issues/132)
- registry\_external\_url not recognised in hiera [\#113](https://github.com/voxpupuli/puppet-gitlab/issues/113)
- Feature: re-enable signup disable [\#112](https://github.com/voxpupuli/puppet-gitlab/issues/112)
- When specifying LDAP configuration, puppet creates a gitlab.rb file with the wrong syntax [\#92](https://github.com/voxpupuli/puppet-gitlab/issues/92)

**Merged pull requests:**

- Refactor unit tests to iterate over all supported OS's [\#131](https://github.com/voxpupuli/puppet-gitlab/pull/131) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- Added Gitaly related params + fixed template for redis/sentinel related data. [\#130](https://github.com/voxpupuli/puppet-gitlab/pull/130) ([shaheed121](https://github.com/shaheed121))
- Adding support to confifure redis HA while using omnibus package [\#129](https://github.com/voxpupuli/puppet-gitlab/pull/129) ([shaheed121](https://github.com/shaheed121))
- Fix spec test [\#128](https://github.com/voxpupuli/puppet-gitlab/pull/128) ([op-ct](https://github.com/op-ct))
- Adds ability to specify git\_data\_dirs [\#110](https://github.com/voxpupuli/puppet-gitlab/pull/110) ([logicminds](https://github.com/logicminds))

## [v1.13.3](https://github.com/voxpupuli/puppet-gitlab/tree/v1.13.3) (2017-04-04)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.13.2...v1.13.3)

## [v1.13.2](https://github.com/voxpupuli/puppet-gitlab/tree/v1.13.2) (2017-04-03)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.13.1...v1.13.2)

## [v1.13.1](https://github.com/voxpupuli/puppet-gitlab/tree/v1.13.1) (2017-04-03)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.13.0...v1.13.1)

## [v1.13.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.13.0) (2017-04-03)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.12.0...v1.13.0)

## [v1.12.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.12.0) (2017-04-03)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.11.0...v1.12.0)

**Closed issues:**

- Registry Configuration incorrectly formatted [\#127](https://github.com/voxpupuli/puppet-gitlab/issues/127)
- Omnibus overwrites `gitlab-secrets.json` [\#122](https://github.com/voxpupuli/puppet-gitlab/issues/122)
- CI Runner options [\#117](https://github.com/voxpupuli/puppet-gitlab/issues/117)
- xz-utils incorrect name for CentOS [\#114](https://github.com/voxpupuli/puppet-gitlab/issues/114)

**Merged pull requests:**

- add possibility to config prometheus exporters [\#126](https://github.com/voxpupuli/puppet-gitlab/pull/126) ([cristifalcas](https://github.com/cristifalcas))
- fixed method for sorting hashes in gitlab.rb to sort ldap hashes too [\#116](https://github.com/voxpupuli/puppet-gitlab/pull/116) ([rwuest](https://github.com/rwuest))
- In CentOS land - this is just xz [\#115](https://github.com/voxpupuli/puppet-gitlab/pull/115) ([mlosapio](https://github.com/mlosapio))
- Add settings for Prometheus [\#111](https://github.com/voxpupuli/puppet-gitlab/pull/111) ([mansong1](https://github.com/mansong1))
- fixed the use of Integers in gitlab\_rails Settings inside gitlab.rb [\#109](https://github.com/voxpupuli/puppet-gitlab/pull/109) ([rwuest](https://github.com/rwuest))
- cirunner: merge hashes for runner configuration [\#108](https://github.com/voxpupuli/puppet-gitlab/pull/108) ([knackaron](https://github.com/knackaron))
- cirunner: add missing hard dependency for xz-utils [\#105](https://github.com/voxpupuli/puppet-gitlab/pull/105) ([roock](https://github.com/roock))
- cirunner: fix missing dependency to apt-transport-https [\#104](https://github.com/voxpupuli/puppet-gitlab/pull/104) ([roock](https://github.com/roock))

## [v1.11.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.11.0) (2016-12-23)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.10.0...v1.11.0)

**Implemented enhancements:**

- Add Beaker acceptance tests [\#88](https://github.com/voxpupuli/puppet-gitlab/issues/88)
- Upgrade from CE to EE doesn't work without manual work [\#82](https://github.com/voxpupuli/puppet-gitlab/issues/82)

**Closed issues:**

- Release soon? [\#101](https://github.com/voxpupuli/puppet-gitlab/issues/101)
- Updating Gitlab CE [\#98](https://github.com/voxpupuli/puppet-gitlab/issues/98)

**Merged pull requests:**

- Fix \#82 [\#102](https://github.com/voxpupuli/puppet-gitlab/pull/102) ([dhollinger](https://github.com/dhollinger))
- Fix incorrect syntax in "gitlab\_rails\['ldap\_servers'\]" field [\#100](https://github.com/voxpupuli/puppet-gitlab/pull/100) ([jnicholas1](https://github.com/jnicholas1))
- External url [\#97](https://github.com/voxpupuli/puppet-gitlab/pull/97) ([willtome](https://github.com/willtome))
- Refactor beaker tests for Travis [\#96](https://github.com/voxpupuli/puppet-gitlab/pull/96) ([petems](https://github.com/petems))
- Fixes beaker tests [\#95](https://github.com/voxpupuli/puppet-gitlab/pull/95) ([petems](https://github.com/petems))
- Add systemd\_compatibility [\#94](https://github.com/voxpupuli/puppet-gitlab/pull/94) ([petems](https://github.com/petems))
- Added external\_port parameter [\#93](https://github.com/voxpupuli/puppet-gitlab/pull/93) ([blakejakopovic](https://github.com/blakejakopovic))
- Allow "Disable storage directories management" [\#91](https://github.com/voxpupuli/puppet-gitlab/pull/91) ([gdowmont](https://github.com/gdowmont))
- Add Beaker Travis acceptance tests [\#89](https://github.com/voxpupuli/puppet-gitlab/pull/89) ([petems](https://github.com/petems))

## [v1.10.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.10.0) (2016-08-10)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.9.2...v1.10.0)

**Implemented enhancements:**

- shortcut to SSL, anyone? [\#75](https://github.com/voxpupuli/puppet-gitlab/issues/75)
- Manage concurrent setting for gitlab-runner [\#71](https://github.com/voxpupuli/puppet-gitlab/issues/71)

**Fixed bugs:**

- Issues with Puppet 4.5.3 and Rspec-Puppet [\#85](https://github.com/voxpupuli/puppet-gitlab/issues/85)

**Closed issues:**

- gitlab-secrets.json is destroyed and recreated on every puppet run [\#87](https://github.com/voxpupuli/puppet-gitlab/issues/87)
- parametirize the repo path [\#86](https://github.com/voxpupuli/puppet-gitlab/issues/86)
- unrecognized option '--version' [\#65](https://github.com/voxpupuli/puppet-gitlab/issues/65)
- Failed to call refresh: Could not restart Service\[gitlab-runsvdir\] [\#64](https://github.com/voxpupuli/puppet-gitlab/issues/64)
- yum repo is incompatible for Amazon Linux  [\#46](https://github.com/voxpupuli/puppet-gitlab/issues/46)

**Merged pull requests:**

- Added registry configuration hash option [\#84](https://github.com/voxpupuli/puppet-gitlab/pull/84) ([jkroepke](https://github.com/jkroepke))
- Typo fix: 'oder' -\> 'or' [\#83](https://github.com/voxpupuli/puppet-gitlab/pull/83) ([Anovadea](https://github.com/Anovadea))
- Allow settings of custom gitlab.rb config file [\#69](https://github.com/voxpupuli/puppet-gitlab/pull/69) ([agray1017](https://github.com/agray1017))

## [v1.9.2](https://github.com/voxpupuli/puppet-gitlab/tree/v1.9.2) (2016-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.9.1...v1.9.2)

**Closed issues:**

- Bump version to \> 1.8.0 [\#78](https://github.com/voxpupuli/puppet-gitlab/issues/78)

## [v1.9.1](https://github.com/voxpupuli/puppet-gitlab/tree/v1.9.1) (2016-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.9.0...v1.9.1)

**Merged pull requests:**

- Make config file management configurable [\#80](https://github.com/voxpupuli/puppet-gitlab/pull/80) ([divansantana](https://github.com/divansantana))

## [v1.9.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.9.0) (2016-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.8.0...v1.9.0)

**Implemented enhancements:**

- Add support for Docker registry [\#74](https://github.com/voxpupuli/puppet-gitlab/issues/74)

**Closed issues:**

- Invalid parameter registry\_external\_url on Class\[Gitlab\] [\#81](https://github.com/voxpupuli/puppet-gitlab/issues/81)
- Make config file management configurable [\#79](https://github.com/voxpupuli/puppet-gitlab/issues/79)
- Error: Execution of '/usr/sbin/update-rc.d gitlab-runsvdir defaults' returned 1: update-rc.d: error: unable to read /etc/init.d/gitlab-runsvdir [\#72](https://github.com/voxpupuli/puppet-gitlab/issues/72)
- gitlab::gitlab\_rails hash merge not working [\#66](https://github.com/voxpupuli/puppet-gitlab/issues/66)

**Merged pull requests:**

- Add support for Registry [\#76](https://github.com/voxpupuli/puppet-gitlab/pull/76) ([llauren](https://github.com/llauren))
- Add package\_ensure parameter for gitlab-ci-multi-runner package. [\#70](https://github.com/voxpupuli/puppet-gitlab/pull/70) ([thlapin](https://github.com/thlapin))
- Fix cirunner failure-message for unsupported OS families [\#68](https://github.com/voxpupuli/puppet-gitlab/pull/68) ([gerhardsam](https://github.com/gerhardsam))
- add documentation [\#63](https://github.com/voxpupuli/puppet-gitlab/pull/63) ([b4ldr](https://github.com/b4ldr))

## [v1.8.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.8.0) (2016-03-11)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.7.2...v1.8.0)

**Implemented enhancements:**

- Add support for pages [\#60](https://github.com/voxpupuli/puppet-gitlab/issues/60)
- Add support for gitlab-workhorse configuration. [\#59](https://github.com/voxpupuli/puppet-gitlab/issues/59)
- Cleanup CI parameters [\#37](https://github.com/voxpupuli/puppet-gitlab/issues/37)

**Closed issues:**

- ldap\_servers hash order [\#51](https://github.com/voxpupuli/puppet-gitlab/issues/51)
- Service enabled check fails on CentOS 6 [\#50](https://github.com/voxpupuli/puppet-gitlab/issues/50)
- Make sure apt-transport-https is installed on Debian OS [\#47](https://github.com/voxpupuli/puppet-gitlab/issues/47)

**Merged pull requests:**

- 59 gitlab workhorse [\#62](https://github.com/voxpupuli/puppet-gitlab/pull/62) ([tunasalat](https://github.com/tunasalat))
- Do not enable service by default on RHEL6 [\#58](https://github.com/voxpupuli/puppet-gitlab/pull/58) ([petems](https://github.com/petems))
- Fix rspec tests [\#57](https://github.com/voxpupuli/puppet-gitlab/pull/57) ([petems](https://github.com/petems))
- Fixes Beaker hosts and test [\#55](https://github.com/voxpupuli/puppet-gitlab/pull/55) ([petems](https://github.com/petems))
- add custom hooks [\#54](https://github.com/voxpupuli/puppet-gitlab/pull/54) ([b4ldr](https://github.com/b4ldr))
- Add RedHat support for cirunner [\#53](https://github.com/voxpupuli/puppet-gitlab/pull/53) ([petems](https://github.com/petems))

## [v1.7.2](https://github.com/voxpupuli/puppet-gitlab/tree/v1.7.2) (2016-01-22)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.7.1...v1.7.2)

**Closed issues:**

- More detail on configuring NGINX? [\#48](https://github.com/voxpupuli/puppet-gitlab/issues/48)
- RHEL 6.7 baseurl for yum repo expands incorrectly [\#42](https://github.com/voxpupuli/puppet-gitlab/issues/42)

**Merged pull requests:**

- As this template is writing a config file based on some hashes and ha… [\#52](https://github.com/voxpupuli/puppet-gitlab/pull/52) ([msutter](https://github.com/msutter))
- Add information about how the module handles NGINX configuration. [\#49](https://github.com/voxpupuli/puppet-gitlab/pull/49) ([bgshacklett](https://github.com/bgshacklett))
- Cleanup coding-style issues. [\#45](https://github.com/voxpupuli/puppet-gitlab/pull/45) ([andrekeller](https://github.com/andrekeller))

## [v1.7.1](https://github.com/voxpupuli/puppet-gitlab/tree/v1.7.1) (2015-12-23)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.7.0...v1.7.1)

**Implemented enhancements:**

- Add CI multi runner installation and configuration [\#21](https://github.com/voxpupuli/puppet-gitlab/issues/21)

**Closed issues:**

- gitlab-runsvdir.service not enabled running on CentOS 7 [\#27](https://github.com/voxpupuli/puppet-gitlab/issues/27)

**Merged pull requests:**

- service enabled for all distro's \#27 [\#43](https://github.com/voxpupuli/puppet-gitlab/pull/43) ([witjoh](https://github.com/witjoh))
- Fix this module should work with out having to set the stringify\_facts option [\#41](https://github.com/voxpupuli/puppet-gitlab/pull/41) ([jcsmith](https://github.com/jcsmith))

## [v1.7.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.7.0) (2015-11-25)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.6.0...v1.7.0)

**Closed issues:**

- support for omniauth configuration [\#38](https://github.com/voxpupuli/puppet-gitlab/issues/38)

**Merged pull requests:**

- Add 'manage\_package' parameter [\#40](https://github.com/voxpupuli/puppet-gitlab/pull/40) ([iamjamestl](https://github.com/iamjamestl))
- Gitlab CI Runner [\#39](https://github.com/voxpupuli/puppet-gitlab/pull/39) ([maetthu-indermuehle](https://github.com/maetthu-indermuehle))

## [v1.6.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.6.0) (2015-11-06)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.5.0...v1.6.0)

**Fixed bugs:**

- Decorator Creates to many quotes [\#36](https://github.com/voxpupuli/puppet-gitlab/issues/36)

**Closed issues:**

- gitlab version support [\#32](https://github.com/voxpupuli/puppet-gitlab/issues/32)
- gitlab ldap\_servers [\#28](https://github.com/voxpupuli/puppet-gitlab/issues/28)
- Add parameter for Mattermost [\#26](https://github.com/voxpupuli/puppet-gitlab/issues/26)

**Merged pull requests:**

- allow disabling of omnibus user management [\#34](https://github.com/voxpupuli/puppet-gitlab/pull/34) ([alexsmithhp](https://github.com/alexsmithhp))
- Fix issues with deprecated values in apt::source [\#33](https://github.com/voxpupuli/puppet-gitlab/pull/33) ([b4ldr](https://github.com/b4ldr))
- Added the sym-link to the GitLab service executable in the /etc/init.d/. [\#31](https://github.com/voxpupuli/puppet-gitlab/pull/31) ([valdemon](https://github.com/valdemon))
- Fix unrecognized datatypes inside array in decorate method [\#29](https://github.com/voxpupuli/puppet-gitlab/pull/29) ([deadratfink](https://github.com/deadratfink))

## [v1.5.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.5.0) (2015-08-27)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.4.0...v1.5.0)

**Closed issues:**

- Question: can i configure ldap for gitlab with this puppet module?  [\#23](https://github.com/voxpupuli/puppet-gitlab/issues/23)
- Question: Would this module work with puppet 3.6.2? [\#20](https://github.com/voxpupuli/puppet-gitlab/issues/20)

**Merged pull requests:**

- Add retries to gitlab-ctl reconfigure [\#25](https://github.com/voxpupuli/puppet-gitlab/pull/25) ([npwalker](https://github.com/npwalker))

## [v1.4.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.4.0) (2015-07-24)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.3.0...v1.4.0)

**Closed issues:**

- Add 'db\_key\_base' for Gitlab CI 7.13 [\#22](https://github.com/voxpupuli/puppet-gitlab/issues/22)

**Merged pull requests:**

- Fix rails parameter in hiera example. [\#19](https://github.com/voxpupuli/puppet-gitlab/pull/19) ([thlapin](https://github.com/thlapin))
- Simplify the decorator for hashes. This allows nested hashes to be output correctly. [\#18](https://github.com/voxpupuli/puppet-gitlab/pull/18) ([thlapin](https://github.com/thlapin))

## [v1.3.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.3.0) (2015-07-17)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.2.2...v1.3.0)

**Closed issues:**

- Not working on RHEL7? [\#17](https://github.com/voxpupuli/puppet-gitlab/issues/17)
- bump puppetlabs-apt supported version [\#16](https://github.com/voxpupuli/puppet-gitlab/issues/16)
- Wrong package url for Debian [\#11](https://github.com/voxpupuli/puppet-gitlab/issues/11)
- Will this puppet module be maintained?  [\#8](https://github.com/voxpupuli/puppet-gitlab/issues/8)

**Merged pull requests:**

- Added check for external database [\#15](https://github.com/voxpupuli/puppet-gitlab/pull/15) ([sd-robbruce](https://github.com/sd-robbruce))
- RedHat releasever [\#14](https://github.com/voxpupuli/puppet-gitlab/pull/14) ([sd-robbruce](https://github.com/sd-robbruce))
- Updated erb template to accomodate for values being hashes [\#13](https://github.com/voxpupuli/puppet-gitlab/pull/13) ([sd-robbruce](https://github.com/sd-robbruce))
- Fixed bug with gitlab.rb.erb template for use with git\_data\_dir [\#10](https://github.com/voxpupuli/puppet-gitlab/pull/10) ([sd-robbruce](https://github.com/sd-robbruce))
-  Adds vagrant file [\#9](https://github.com/voxpupuli/puppet-gitlab/pull/9) ([spuder](https://github.com/spuder))

## [v1.2.2](https://github.com/voxpupuli/puppet-gitlab/tree/v1.2.2) (2015-07-07)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.2.1...v1.2.2)

**Merged pull requests:**

- Omnibus service fix and template improvement [\#7](https://github.com/voxpupuli/puppet-gitlab/pull/7) ([jrwesolo](https://github.com/jrwesolo))
- Added Tags to the metadata [\#6](https://github.com/voxpupuli/puppet-gitlab/pull/6) ([maetthu-indermuehle](https://github.com/maetthu-indermuehle))

## [v1.2.1](https://github.com/voxpupuli/puppet-gitlab/tree/v1.2.1) (2015-06-29)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.2.0...v1.2.1)

## [v1.2.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.2.0) (2015-06-23)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.1.0...v1.2.0)

**Closed issues:**

- rails vs gitlab\_rails? [\#3](https://github.com/voxpupuli/puppet-gitlab/issues/3)

**Merged pull requests:**

- Remove rails; it's a duplicate of gitlab\_rails. [\#5](https://github.com/voxpupuli/puppet-gitlab/pull/5) ([tdb](https://github.com/tdb))
- Add high\_availability config section. [\#4](https://github.com/voxpupuli/puppet-gitlab/pull/4) ([tdb](https://github.com/tdb))

## [v1.1.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.1.0) (2015-06-17)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.0.3...v1.1.0)

**Merged pull requests:**

- RHEL 7 support [\#2](https://github.com/voxpupuli/puppet-gitlab/pull/2) ([danfoster](https://github.com/danfoster))

## [v1.0.3](https://github.com/voxpupuli/puppet-gitlab/tree/v1.0.3) (2015-06-16)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.0.2...v1.0.3)

## [v1.0.2](https://github.com/voxpupuli/puppet-gitlab/tree/v1.0.2) (2015-05-29)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.0.1...v1.0.2)

## [v1.0.1](https://github.com/voxpupuli/puppet-gitlab/tree/v1.0.1) (2015-05-29)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/voxpupuli/puppet-gitlab/tree/v1.0.0) (2015-05-29)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab/compare/b4544b0052d91d0f59c13a23de0e983babf599a5...v1.0.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*