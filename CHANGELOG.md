## 2.2.0 / Unreleased
[Full Changelog](http://github.com/simukappu/amazon-chime-sdk-rails/compare/v2.1.0...v2.2.0)

Security Fixes:

* Verify that requested meetings belong to the requesting resource. Meetings and attendees controllers now respond with 404 when the meeting's `ExternalMeetingId` is not `config.prefix + meeting_request_id`, so users can no longer get, delete, or join meetings of other resources (such as other private rooms) by meeting ID
  * Attendees controllers must now define `meeting_request_id` with the same value as the meetings controller. The generated attendees controller template includes it
  * Set `config.verify_meeting_request_id = false`, or override `verify_meeting_request_id?` in a controller, to restore the previous behavior
* Do not return `JoinToken` from attendees `index` and `show` actions. A join token is the credential to join a meeting as that attendee, so other participants could impersonate the attendee
* Do not create meetings or attendees by HTTP GET request parameters. `create_meeting` in meetings `index` and `create_attendee_from_meeting` in meetings `show` can now only disable the creation enabled by `config.create_meeting_by_get_request` and `config.create_attendee_from_meeting`, since GET requests are not protected from CSRF
* Raise `NotImplementedError` from `attendee_request_id` unless it is defined in your controllers. The previous default `"default"` made every user join meetings as the same attendee with the same join token. The generated controller templates also raise it until you define `attendee_request_id`
* Build the attendee list in the generated meeting view with `textContent` instead of `innerHTML`, so attendee names from application metadata cannot inject HTML
* Remove the unpinned axios script loaded from unpkg in the generated meeting view and use `fetch` instead
* Pin the aws-samples/amazon-chime-sdk commit that `rails g chime_sdk:js` clones and runs npm scripts in

## 2.1.0 / 2026-04-11
[Full Changelog](http://github.com/simukappu/amazon-chime-sdk-rails/compare/v2.0.1...v2.1.0)

Enhancements:

* Support Rails 8.1
* Update CI configuration and documentation

Dependencies:

* Require Ruby 3.1+ and Rails 7.0+
* Update development dependencies

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
