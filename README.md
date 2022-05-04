# amazon-chime-sdk-rails

[![Build Status](https://github.com/simukappu/amazon-chime-sdk-rails/actions/workflows/build.yml/badge.svg)](https://github.com/simukappu/amazon-chime-sdk-rails/actions/workflows/build.yml)
[![Coverage Status](https://coveralls.io/repos/github/simukappu/amazon-chime-sdk-rails/badge.svg?branch=master)](https://coveralls.io/github/simukappu/amazon-chime-sdk-rails?branch=master)
[![Dependency](https://img.shields.io/depfu/simukappu/amazon-chime-sdk-rails.svg)](https://depfu.com/repos/simukappu/amazon-chime-sdk-rails)
[![Inline Docs](http://inch-ci.org/github/simukappu/amazon-chime-sdk-rails.svg?branch=master)](http://inch-ci.org/github/simukappu/amazon-chime-sdk-rails)
[![Gem Version](https://badge.fury.io/rb/amazon-chime-sdk-rails.svg)](https://rubygems.org/gems/amazon-chime-sdk-rails)
[![Gem Downloads](https://img.shields.io/gem/dt/amazon-chime-sdk-rails.svg)](https://rubygems.org/gems/amazon-chime-sdk-rails)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

*amazon-chime-sdk-rails* brings server-side implementation of [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk) to your [Ruby on Rails](https://rubyonrails.org) application. [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk) provides client-side implementation to build real-time communications for your application, and *amazon-chime-sdk-rails* enables you to easily add server-side implementation to your Rails application.

<kbd>![cloud-react-meeting-demo-joined-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/cloud_react_meeting_demo_joined.png)</kbd>

*amazon-chime-sdk-rails* supports both of [Rails API Application](https://guides.rubyonrails.org/api_app.html) and [Rails Application with Action View](https://guides.rubyonrails.org/action_view_overview.html). The gem provides following functions:
* *Meeting Coordinator* - Wrapper client module of [AWS SDK for Ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html), which simulates [AWS SDK for JavaScript](https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Chime.html) to communicate with Amazon Chime SDK client implementation by JSON format.
* *Controller Templates* - Mixin module implementation for meetings and attendees controllers.
* *Rails Generators*
  * *Controller Generator* - Generator to create customizable meetings and attendees controllers in your Rails application.
  * *Single Javascript Generator* - Generator to [bundle Amazon Chime SDK into a single .js file](https://github.com/aws-samples/amazon-chime-sdk/tree/main/utils/singlejs) and put it into [Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html) for your Rails application with Action View.
  * *View Generator* - Generator to create customizable meetings views for your Rails application with Action View.


## Getting Started

### Installation

Add *amazon-chime-sdk-rails* to your app’s Gemfile:

```ruby:Gemfile
gem 'amazon-chime-sdk-rails'
```

Then, in your project directory:

```bash
$ bundle install
$ rails g chime_sdk:install
```

The install generator will generate an initializer which describes all configuration options of *amazon-chime-sdk-rails*.

### Set up AWS credentials

You need to set up AWS credentials or IAM role for *amazon-chime-sdk-rails* in your Rails app. See [Configuring the AWS SDK for Ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html) for more details.

*amazon-chime-sdk-rails* requires IAM permissions defined as [AWSChimeSDK AWS managed policy](https://docs.aws.amazon.com/chime-sdk/latest/dg/iam-users-roles.html). Grant these permissions to your IAM policy and assign it to your IAM user or role. This ensures that you have the necessary permissions for *amazon-chime-sdk-rails* in your server-side application. See [Actions defined by Amazon Chime](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonchime.html#amazonchime-actions-as-permissions) for more details.

### [Option 1] Develop your Rails API Application

See [Develop your Rails API Application](/docs/Develop_Rails_API_Application.md#develop-your-rails-api-application) for step-by-step instructions.

You can build your Rails API application working with front-end application using [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk). *amazon-chime-sdk-rails* provides *Controller Generator* to create customizable meetings and attendees controllers in your Rails API application.

```bash
$ rails g chime_sdk:controllers -r room -n api
```

*amazon-chime-sdk-rails* includes example Rails application in *[/spec/rails_app](/spec/rails_app)*. This example application provides API integration with [customized React Meeting Demo](https://github.com/simukappu/amazon-chime-sdk/tree/main/apps/meeting#readme---react-meeting-demo) as a sample single page application using [React](https://reactjs.org/) and [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js). See [Examples](#examples) for more details.

### [Option 2] Develop your Rails Application with Action View

See [Develop your Rails Application with Action View](/docs/Develop_Rails_View_Application.md#develop-your-rails-application-with-action-view) for step-by-step instructions.

You can build your Rails application with Action View using *amazon-chime-sdk-rails*. In addition to *Controller Generator*, *Single Javascript Generator* will [bundle Amazon Chime SDK into a single .js file](https://github.com/aws-samples/amazon-chime-sdk/tree/main/utils/singlejs) and put it into [Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html) for your Rails application. Then, *View Generator* will create customizable meetings views which includes bundled Amazon Chime SDK from Asset Pipeline.

```bash
$ rails g chime_sdk:controllers -r room
$ rails g chime_sdk:js
$ rails g chime_sdk:views
```

You can also customize your meeting view using [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js). See [Examples](#examples) for more details.


## Examples

You can see example Rails application in *[/spec/rails_app](/spec/rails_app)*. This example Rails application is integrated with [customized React Meeting Demo](https://github.com/simukappu/amazon-chime-sdk/tree/main/apps/meeting#readme---react-meeting-demo) as a sample single page application using [React](https://reactjs.org/) and [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js). You can run customized React Meeting Demo and example Rails application by the following steps.

### Run application in your local environment

Run customized React Meeting Demo in your local environment:

```bash
$ cd <YOUR-WORKING-DIR-FOR-LOCAL>
$ git clone https://github.com/simukappu/amazon-chime-sdk.git
$ cd amazon-chime-sdk/apps/meeting
$ npm install
$ npm start
```

You can open *https://localhost:9000* in your browser to access React Meeting Demo.

<kbd>![local-react-meeting-demo-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/local_react_meeting_demo.png)</kbd>

Then, run example Rails application in your local environment:

```bash
$ cd <YOUR-WORKING-DIR-FOR-LOCAL>
$ git clone https://github.com/simukappu/amazon-chime-sdk-rails.git
$ cd amazon-chime-sdk-rails
$ bundle install
$ cd spec/rails_app
$ echo "REACT_MEETING_DEMO_URL=https://localhost:9000" > .env
$ bin/rake db:migrate
$ bin/rake db:seed
$ bin/rails g chime_sdk:js
$ bin/rails s
```

Now you can access example Rails application as *http://localhost:3000* in your browser.

<kbd>![local-example-rails-app-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/local_example_rails_app.png)</kbd>

Login as the following test users to experience example Rails application by *amazon-chime-sdk-rails*:

| Email | Password | Initial member of Private Room 1 |
|:---:|:---:|:---:|
| ichiro@example.com  | changeit | Yes |
| stephen@example.com | changeit | Yes |
| klay@example.com    | changeit |     |
| kevin@example.com   | changeit |     |

After creating a new meeting from any private room, you can join the meeting from "*Join the Meeting*" button in your meeting view.


<kbd>![local-example-rails-app-joined-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/local_example_rails_app_joined.png)</kbd>

You can also try integration with customized React Meeting Demo from "*Open React Meeting Demo*" button.

<kbd>![local-react-meeting-demo-api-integration-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/local_react_meeting_demo_api_integration.png)</kbd>

Push "Continue" and go to the private meeting room!

<kbd>![local-react-meeting-demo-joined-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/local_react_meeting_demo_joined.png)</kbd>


### Deploy application to your AWS environment

At first, [install the latest version of AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [set up AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) in your local environment.

Deploy customized React Meeting Demo to your AWS environment:

```bash
$ cd <YOUR-WORKING-DIR-FOR-CLOUD>
$ git clone https://github.com/simukappu/amazon-chime-sdk.git
$ cd amazon-chime-sdk/apps/meeting
$ npm install
$ cd serverless
$ node ./deploy.js -r us-east-1 -b <YOUR-S3-BUCKET-NAME-FOR-MEETING-DEMO> -s react-meeting-demo
```

You can see *Amazon Chime SDK Meeting Demo URL* in your deployment output. Open your meeting demo URL in your browser to access React Meeting Demo.

<kbd>![cloud-react-meeting-demo-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/cloud_react_meeting_demo.png)</kbd>

Then, deploy example Rails application to your AWS environment. This deployment example uses [AWS Copilot CLI](https://aws.github.io/copilot-cli/). [Install AWS Copilot CLI](https://aws.github.io/copilot-cli/docs/overview/) before you start to deploy.

***Optional***: To avoid [mixed content](https://web.dev/what-is-mixed-content/) in your customized React Meeting Demo, you have to publish example Rails application as HTTPS content. Currently in order to make your application HTTPS content from AWS Copilot CLI, you need your domain or subdomain mamaged as [Amazon Route 53 public hosted zones](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html) and [domain association with AWS Copilot CLI](https://aws.github.io/copilot-cli/docs/developing/domain/). You can associate your domain with `--domain` option in running `copilot app init` before you run `copilot init`.

Now deploy example Rails application as the following steps:

```bash
$ cd <YOUR-WORKING-DIR-FOR-CLOUD>
$ git clone https://github.com/simukappu/amazon-chime-sdk-rails.git
$ cd amazon-chime-sdk-rails
$ copilot app init --domain <YOUR_REGISTERED_DOMAIN> # --domain option is optional, but required to avoid mixed content
    What would you like to name your application? [? for help] amazon-chime-sdk-rails
$ copilot init
    Which workload type best represents your architecture?  [Use arrows to move, type to filter, ? for more help]
      Request-Driven Web Service  (App Runner)
    > Load Balanced Web Service   (Internet to ECS on Fargate)
      Backend Service             (ECS on Fargate)
      Worker Service              (Events to SQS to ECS on Fargate)
      Scheduled Job               (Scheduled event to State Machine to Fargate)
    What do you want to name this service? [? for help] rails-app
    Which Dockerfile would you like to use for rails-app?  [Use arrows to move, type to filter, ? for more help]
    > ./Dockerfile
      Enter custom path for your Dockerfile
      Use an existing image instead
    Would you like to deploy a test environment? [? for help] (y/N) no
$ mkdir copilot/rails-app/addons && cp templates/amazon-chime-sdk-policy.yml copilot/rails-app/addons/
$ copilot env init --name test --profile default --app amazon-chime-sdk-rails
    Would you like to use the default configuration for a new environment?
      - A new VPC with 2 AZs, 2 public subnets and 2 private subnets
      - A new ECS Cluster
      - New IAM Roles to manage services and jobs in your environment
    [Use arrows to move, type to filter]
    > Yes, use default.
      Yes, but I'd like configure the default resources (CIDR ranges, AZs).
      No, I'd like to import existing resources (VPC, subnets).
$ REACT_MEETING_DEMO_URL=`aws cloudformation describe-stacks --region us-east-1 --stack-name react-meeting-demo | jq -r '.Stacks[].Outputs[].OutputValue'`
$ gsed -i "s/#variables:/variables:/g" copilot/rails-app/manifest.yml
$ gsed -i "/variables:/a\  REACT_MEETING_DEMO_URL: $REACT_MEETING_DEMO_URL" copilot/rails-app/manifest.yml
$ copilot deploy
```

You can see *your service URL* in your deployment output. Now you can access example Rails application as this service URL in your browser.

<kbd>![cloud-example-rails-app-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/cloud_example_rails_app.png)</kbd>

Login as the test users to experience example Rails application by *amazon-chime-sdk-rails*:

| Email | Password | Initial member of Private Room 1 |
|:---:|:---:|:---:|
| ichiro@example.com  | changeit | Yes |
| stephen@example.com | changeit | Yes |
| klay@example.com    | changeit |     |
| kevin@example.com   | changeit |     |

After creating a new meeting from any private room, you can join the meeting from "*Join the Meeting*" button in your meeting view.

<kbd>![cloud-example-rails-app-joined-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/cloud_example_rails_app_joined.png)</kbd>

You can also try integration with customized React Meeting Demo from "*Open React Meeting Demo*" button. Enjoy your real-time communications in the private room on the cloud!

<kbd>![cloud-react-meeting-demo-joined-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/cloud_react_meeting_demo_joined.png)</kbd>

Finally, clean up your AWS environment:

```bash
$ copilot app delete
    Are you sure you want to delete application amazon-chime-sdk-rails? [? for help] (Y/n) yes
$ aws cloudformation delete-stack --region us-east-1 --stack-name react-meeting-demo
$ aws s3 rb s3://<YOUR-S3-BUCKET-NAME-FOR-MEETING-DEMO> --force
```


## Documentation

See [API Reference](http://www.rubydoc.info/github/simukappu/amazon-chime-sdk-rails/index) for more details.


## License

*amazon-chime-sdk-rails* project rocks and uses [MIT License](LICENSE).
