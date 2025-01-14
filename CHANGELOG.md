## 2.0.1 / 2025-01-14
[Full Changelog](http://github.com/simukappu/amazon-chime-sdk-rails/compare/v2.0.0...v2.0.1)

Enhancements:

* Remove unmaintained Rails 6.1 from test cases
* Update test case with Rails 7.2 and Rails 8.0

## 2.0.0 / 2024-02-28
[Full Changelog](http://github.com/simukappu/amazon-chime-sdk-rails/compare/v1.1.1...v2.0.0)

Enhancements:

* Update [API namespace from Chime to ChimeSDKMeetings](https://docs.aws.amazon.com/chime-sdk/latest/dg/migrate-from-chm-namespace.html)
* Update embedded [Chime SDK from v2 to v3](https://aws.github.io/amazon-chime-sdk-js/modules/migrationto_3_0.html)
* Update test case with Rails 7.1

## 1.1.1 / 2023-07-17
[Full Changelog](http://github.com/simukappu/amazon-chime-sdk-rails/compare/v1.1.0...v1.1.1)

Enhancements:

* Remove unmaintained Rails versions from test cases
* Update test case with Rails 7.0

Bug Fixes:

* Remove unnecessary log for debug

## 1.1.0 / 2022-05-04
[Full Changelog](http://github.com/simukappu/amazon-chime-sdk-rails/compare/v1.0.0...v1.1.0)

Enhancements:

* Use [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js) v2 as default
* Test use with Rails 6.1 and 7.0
* Enable to specify [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js) version in *Single Javascript Generator*
* Enable negative request parameters for meetings controller against positive config parameters

Enhancements for exmaple applications:
* Integrate [customized React Meeting Demo](https://github.com/simukappu/amazon-chime-sdk/tree/main/apps/meeting#readme---react-meeting-demo) with example Rails application
* Add Dockerfile and AWS deployment for example Rails application
* Remove sample single page application using Vue.js

Bug Fixes:

* Fix *Single Javascript Generator* along with [Single JS](https://github.com/aws-samples/amazon-chime-sdk/tree/main/utils/singlejs) repository move

## 1.0.0 / 2020-10-17

* First release
