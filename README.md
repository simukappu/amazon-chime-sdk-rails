# amazon-chime-sdk-rails

[![Build Status](https://travis-ci.org/simukappu/amazon-chime-sdk-rails.svg?branch=master)](https://travis-ci.org/simukappu/amazon-chime-sdk-rails)
[![Coverage Status](https://coveralls.io/repos/github/simukappu/amazon-chime-sdk-rails/badge.svg?branch=master)](https://coveralls.io/github/simukappu/amazon-chime-sdk-rails?branch=master)
[![Dependency](https://img.shields.io/depfu/simukappu/amazon-chime-sdk-rails.svg)](https://depfu.com/repos/simukappu/amazon-chime-sdk-rails)
[![Inline Docs](http://inch-ci.org/github/simukappu/amazon-chime-sdk-rails.svg?branch=master)](http://inch-ci.org/github/simukappu/amazon-chime-sdk-rails)
[![Gem Version](https://badge.fury.io/rb/amazon-chime-sdk-rails.svg)](https://rubygems.org/gems/amazon-chime-sdk-rails)
[![Gem Downloads](https://img.shields.io/gem/dt/amazon-chime-sdk-rails.svg)](https://rubygems.org/gems/amazon-chime-sdk-rails)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

*amazon-chime-sdk-rails* brings server-side implementation of [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk) to your [Ruby on Rails](https://rubyonrails.org) application. [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk) provides client-side implementation to build real-time communications for your application, and *amazon-chime-sdk-rails* enables you to easily add server-side implementation to your Rails application.

*amazon-chime-sdk-rails* supports both of [Rails API Application](https://guides.rubyonrails.org/api_app.html) and [Rails Application with Action View](https://guides.rubyonrails.org/action_view_overview.html). The gem provides following functions:
* Meeting Coordinator - Wrapper client module of [AWS SDK for Ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html), which simulates [AWS SDK for JavaScript](https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Chime.html) to communicate with Amazon Chime SDK client implementation by JSON format.
* Controller Templates - Mixin module implementation for meetings and attendees controllers.
* Rails Generators
  * Controller Generator - Generator to create customizable meetings and attendees controllers in your Rails application.
  * View Generator - Generator to create customizable meetings views for your Rails application with Action View.
  * Single Javascript Generator - Generator to [bundle Amazon Chime SDK into single .js file](https://github.com/aws/amazon-chime-sdk-js/tree/master/demos/singlejs) and put it into [Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html) for your Rails application with Action View.


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

*amazon-chime-sdk-rails* requires following IAM permissions:

* [chime:TagResource](https://docs.aws.amazon.com/chime/latest/APIReference/API_TagResource.html)
* [chime:UntagResource](https://docs.aws.amazon.com/chime/latest/APIReference/API_UntagResource.html)
* [chime:CreateMeeting](https://docs.aws.amazon.com/chime/latest/APIReference/API_CreateMeeting.html)
* [chime:GetMeeting](https://docs.aws.amazon.com/chime/latest/APIReference/API_GetMeeting.html)
* [chime:ListMeetings](https://docs.aws.amazon.com/chime/latest/APIReference/API_ListMeetings.html) (if necessary)
* [chime:DeleteMeeting](https://docs.aws.amazon.com/chime/latest/APIReference/API_DeleteMeeting.html) (if necessary)
* [chime:CreateAttendee](https://docs.aws.amazon.com/chime/latest/APIReference/API_CreateAttendee.html)
* [chime:GetAttendee](https://docs.aws.amazon.com/chime/latest/APIReference/API_GetAttendee.html)
* [chime:ListAttendees](https://docs.aws.amazon.com/chime/latest/APIReference/API_ListAttendees.html) (if necessary)
* [chime:DeleteAttendee](https://docs.aws.amazon.com/chime/latest/APIReference/API_DeleteAttendee.html) (if necessary)

See [Actions defined by Amazon Chime](https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonchime.html#amazonchime-actions-as-permissions) for more details.

### A: Develop your Rails API Application

Let's start to building simple Rails API application providing real-time communications in a private room.
For example, create Rails API application using [Devise Token Auth](https://github.com/lynndylanhurley/devise_token_auth) for user authentication.

#### Prepare Rails API application

At first, create new Rails application:

```bash
$ rails new chime_api_app --api
$ cd chime_api_app
```

Add gems to your Gemfile:

```ruby:Gemfile
# Gemfile

gem 'devise_token_auth'
gem 'amazon-chime-sdk-rails'
```

Then, install *devise_token_auth*:

```bash
$ bundle install
$ rails g devise:install
$ rails g devise_token_auth:install User auth
```

Update your `application_controller.rb` like this:

```ruby:app/controllers/application_controller.rb
# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  include ActionController::Helpers
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end 
end
```

Update your `user.rb` to remove unnecessary options like this:

```ruby:app/models/user.rb
# app/models/user.rb

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable
  include DeviseTokenAuth::Concerns::User
end
```

Update *devise_token_auth* configuration in `devise_token_auth.rb` to keep authorization headers:

```ruby:config/initializers/devise_token_auth.rb
# config/initializers/devise_token_auth.rb

DeviseTokenAuth.setup do |config|
  # Uncomment and update
  config.change_headers_on_each_request = false
end
```

#### Create private room functions

Create models and controllers by generator:

```bash
$ rails g model room name:string
$ rails g scaffold_controller api/rooms name:string --model-name=room
$ rails g model entry room:references user:references
$ rails g scaffold_controller api/entries room:references user:references --model-name=entry
$ rake db:migrate
```

Update your `room.rb` like this:

```ruby:app/models/room.rb
# app/models/room.rb

class Room < ApplicationRecord
  has_many :entries, dependent: :destroy
  has_many :members, through: :entries, source: :user

  def member?(user)
    members.include?(user)
  end

  def as_json(options = {})
    super options.merge(:methods => [:members])
  end
end
```

Add uniqueness validation to your `entry.rb` like this:

```ruby:app/models/entry.rb
# app/models/entry.rb

class Entry < ApplicationRecord
  belongs_to :room
  belongs_to :user
  # Add uniqueness validation
  validates :user, uniqueness: { scope: :room }
end
```

Remove location header from your `rooms_controller.rb` and `entries_controller.rb` like this:

```ruby:app/controllers/api/rooms_controller.rb
# app/controllers/api/rooms_controller.rb

# POST /rooms
def create
  @room = Room.new(room_params)

  if @room.save
    render json: @room, status: :created # Remove location header
  else
    render json: @room.errors, status: :unprocessable_entity
  end
end
```

```ruby:app/controllers/api/entries_controller.rb
# app/controllers/api/entries_controller.rb

# POST /entries
def create
  @entry = Entry.new(entry_params)

  if @entry.save
    render json: @entry, status: :created # Remove location header
  else
    render json: @entry.errors, status: :unprocessable_entity
  end
end
```

#### Develop meeting functions with amazon-chime-sdk-rails

Install *amazon-chime-sdk-rails* and generates your controllers:

```bash
$ rails g chime_sdk:install
$ rails g chime_sdk:controllers -r room -n api
```

Add and uncomment several functions in generated `meetings_controller.rb` and `meeting_attendees_controller.rb` for your app configurations:

```ruby:app/controllers/api/meetings_controller.rb
# app/controllers/api/meetings_controller.rb

class Api::MeetingsController < ApplicationController
  before_action :authenticate_api_user!
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :set_room
  before_action :check_membership

  include ChimeSdk::Controller::Meetings::Mixin

  private
  # Add
  def set_room
    @room = Room.find(params[:room_id])
  end

  # Add
  def check_membership
    unless @room.member?(current_api_user)
      message = 'Unauthorized: you are not a member of this private room.'
      render json: { room: @room, notice: message }, status: :forbidden
    end
  end

  # Uncomment
  def meeting_request_id
    "PrivateRoom-#{@room.id}"
  end

  # Uncomment and update
  def attendee_request_id
    "User-#{current_api_user.id}"
  end

  # Uncomment
  def application_meeting_metadata(meeting)
    {
      "MeetingType": "PrivateRoom",
      "Room": @room
    }
  end

  # Uncomment
  def application_attendee_metadata(attendee)
    user_id = attendee[:Attendee][:ExternalUserId].split('-')[3]
    {
      "AttendeeType": "User",
      "User": User.find_by_id(user_id)
    }
  end
end
```

```ruby:app/controllers/api/meeting_attendees_controller.rb
# app/controllers/api/meeting_attendees_controller.rb

class Api::MeetingAttendeesController < ApplicationController
  before_action :authenticate_api_user!
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :set_room
  before_action :check_membership

  include ChimeSdk::Controller::Attendees::Mixin

  private
  # Add
  def set_room
    @room = Room.find(params[:room_id])
  end

  # Add
  def check_membership
    unless @room.member?(current_api_user)
      message = 'Unauthorized: you are not a member of this private room.'
      render json: { room: @room, notice: message }, status: :forbidden
    end
  end

  # Uncomment and update
  def attendee_request_id
    "User-#{current_api_user.id}"
  end

  # Uncomment
  def application_attendee_metadata(attendee)
    user_id = attendee[:Attendee][:ExternalUserId].split('-')[3]
    {
      "AttendeeType": "User",
      "User": User.find_by_id(user_id)
    }
  end
end
```

Then, update your `routes.rb` like this:

```ruby:config/routes.rb
# config/routes.rb

Rails.application.routes.draw do
  namespace :api do
    scope :"v1" do
      mount_devise_token_auth_for 'User', at: 'auth'
      resources :rooms do
        resources :entries, only: [:create, :destroy]
        resources :meetings, defaults: { format: :json }, only: [:index, :show, :create, :destroy] do
          resources :meeting_attendees, as: :attendees, path: :attendees, only: [:index, :show, :create, :destroy]
        end
      end
    end
  end
end
```

Note that you need to set up AWS credentials or IAM role for *amazon-chime-sdk-rails*. See [Set up AWS credentials](#set-up-aws-credentials) for more details.

Finally, start rails server:

```bash
$ rails server
```

Now ready to take off!

#### Get meeting configurations through Rails API

Created Rails API works like this:

```bash
# Sign up users

$ curl localhost:3000/api/v1/auth -X POST -H "content-type:application/json" -d '{"email":"ichiro@example.com", "password":"password", "password_confirmation":"password", "name":"ichiro"}'

{"status":"success","data":{"id":1,"provider":"email","uid":"ichiro@example.com","allow_password_change":false,"name":"ichiro","nickname":null,"image":null,"email":"ichiro@example.com","created_at":"2020-10-16T11:14:48.731Z","updated_at":"2020-10-16T11:14:48.827Z"}}

$ curl localhost:3000/api/v1/auth -X POST -H "content-type:application/json" -d '{"email":"stephen@example.com", "password":"password", "password_confirmation":"password", "name":"stephen"}'

{"status":"success","data":{"id":2,"provider":"email","uid":"stephen@example.com","allow_password_change":false,"name":"stephen","nickname":null,"image":null,"email":"stephen@example.com","created_at":"2020-10-16T11:15:33.226Z","updated_at":"2020-10-16T11:15:33.314Z"}}

# Create private room

$ curl localhost:3000/api/v1/rooms -X POST -H "content-type:application/json" -d '{"room":{"name":"PrivateRoom-1"}}'

{"id":1,"name":"PrivateRoom-1","created_at":"2020-10-16T11:15:56.223Z","updated_at":"2020-10-16T11:15:56.223Z","members":[]}

# You cannot create meeting yet because the user is not signed in

$ curl localhost:3000/api/v1/rooms/3/meetings -X POST -H "content-type:application/json"

{"errors":["You need to sign in or sign up before continuing."]}

# Sign in as ichiro

$ curl localhost:3000/api/v1/auth/sign_in -X POST -H "content-type:application/json" -D auth_headers.txt -d '{"email":"ichiro@example.com", "password":"password"}'

{"data":{"id":1,"email":"ichiro@example.com","provider":"email","uid":"ichiro@example.com","allow_password_change":false,"name":"ichiro","nickname":null,"image":null}}

$ _ACCESS_TOKEN=$(cat auth_headers.txt | grep access-token | rev | cut -c 2- | rev)
$ _CLIENT=$(cat auth_headers.txt | grep client | rev | cut -c 2- | rev)
$ _UID=$(cat auth_headers.txt | grep uid | rev | cut -c 2- | rev)

# You cannot create meeting yet because the user is not a member of the private room

$ curl localhost:3000/api/v1/rooms/1/meetings -X POST -H "content-type:application/json" -H "${_ACCESS_TOKEN}" -H "${_CLIENT}" -H "${_UID}"

{"room":{"id":1,"name":"PrivateRoom-1","created_at":"2020-10-16T11:15:56.223Z","updated_at":"2020-10-16T11:15:56.223Z","members":[]},"notice":"Unauthorized: you are not a member of this private room."}

# Add users to the private room

$ curl localhost:3000/api/v1/rooms/1/entries -X POST -H "content-type:application/json" -d '{"entry":{"room_id":1,"user_id":1}}'

{"id":1,"room_id":1,"user_id":1,"created_at":"2020-10-16T11:18:22.839Z","updated_at":"2020-10-16T11:18:22.839Z"}

$ curl localhost:3000/api/v1/rooms/1/entries -X POST -H "content-type:application/json" -d '{"entry":{"room_id":1,"user_id":2}}'

{"id":2,"room_id":1,"user_id":2,"created_at":"2020-10-16T11:18:41.116Z","updated_at":"2020-10-16T11:18:41.116Z"}

# Now you can create meeting as a member of the private room

$ curl localhost:3000/api/v1/rooms/1/meetings -X POST -H "content-type:application/json" -H "${_ACCESS_TOKEN}" -H "${_CLIENT}" -H "${_UID}" | jq .

{
  "Meeting": {
    "MeetingId": "2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
    "ExternalMeetingId": "ChimeSdkRailsApp-development-PrivateRoom-1",
    "MediaPlacement": {
      "AudioHostUrl": "d3175d855e633b72aedbXXXXXXXXXXXX.k.m2.ue1.app.chime.aws:3478",
      "AudioFallbackUrl": "wss://haxrp.m2.ue1.app.chime.aws:443/calls/2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "ScreenDataUrl": "wss://bitpw.m2.ue1.app.chime.aws:443/v2/screen/2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "ScreenSharingUrl": "wss://bitpw.m2.ue1.app.chime.aws:443/v2/screen/2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "ScreenViewingUrl": "wss://bitpw.m2.ue1.app.chime.aws:443/ws/connect?passcode=null&viewer_uuid=null&X-BitHub-Call-Id=2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "SignalingUrl": "wss://signal.m2.ue1.app.chime.aws/control/2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "TurnControlUrl": "https://ccp.cp.ue1.app.chime.aws/v2/turn_sessions"
    },
    "MediaRegion": "us-east-1",
    "ApplicationMetadata": {
      "MeetingType": "PrivateRoom",
      "Room": {
        "id": 1,
        "name": "PrivateRoom-1",
        "created_at": "2020-10-16T11:15:56.223Z",
        "updated_at": "2020-10-16T11:15:56.223Z",
        "members": [
          {
            "id": 1,
            "provider": "email",
            "uid": "ichiro@example.com",
            "allow_password_change": false,
            "name": "ichiro",
            "nickname": null,
            "image": null,
            "email": "ichiro@example.com",
            "created_at": "2020-10-16T11:14:48.731Z",
            "updated_at": "2020-10-16T11:16:56.927Z"
          },
          {
            "id": 2,
            "provider": "email",
            "uid": "stephen@example.com",
            "allow_password_change": false,
            "name": "stephen",
            "nickname": null,
            "image": null,
            "email": "stephen@example.com",
            "created_at": "2020-10-16T11:15:33.226Z",
            "updated_at": "2020-10-16T11:15:33.314Z"
          }
        ]
      }
    }
  },
  "Attendee": {
    "ExternalUserId": "ChimeSdkRailsApp-development-User-1",
    "AttendeeId": "b581c46d-661f-92bb-d80e-XXXXXXXXXXXX",
    "JoinToken": "YjU4MWM0NmQtNjYxZi05MmJiLWQ4MGUtZjRiMTU3ZDk1ZmU5OjgyZmM2NTMxLTIwMjctNGMxMS04OTE0LTQwZjXXXXXXXXXXXX",
    "ApplicationMetadata": {
      "AttendeeType": "User",
      "User": {
        "id": 1,
        "provider": "email",
        "uid": "ichiro@example.com",
        "allow_password_change": false,
        "name": "ichiro",
        "nickname": null,
        "image": null,
        "email": "ichiro@example.com",
        "created_at": "2020-10-16T11:14:48.731Z",
        "updated_at": "2020-10-16T11:16:56.927Z"
      }
    }
  }
}

# Get attendee data from created meeting ID

$ MEETING_ID=$(curl localhost:3000/api/v1/rooms/1/meetings -X POST -H "content-type:application/json" -H "${_ACCESS_TOKEN}" -H "${_CLIENT}" -H "${_UID}" | jq -r .Meeting.MeetingId)

$ curl localhost:3000/api/v1/rooms/1/meetings/${MEETING_ID}/attendees -H "content-type:application/json" -H "${_ACCESS_TOKEN}" -H "${_CLIENT}" -H "${_UID}" | jq .

{
  "attendees": [
    {
      "Attendee": {
        "ExternalUserId": "ChimeSdkRailsApp-development-User-1",
        "AttendeeId": "b581c46d-661f-92bb-d80e-XXXXXXXXXXXX",
        "JoinToken": "YjU4MWM0NmQtNjYxZi05MmJiLWQ4MGUtZjRiMTU3ZDk1ZmU5OjgyZmM2NTMxLTIwMjctNGMxMS04OTE0LTQwZjXXXXXXXXXXXX",
        "ApplicationMetadata": {
          "AttendeeType": "User",
          "User": {
            "id": 1,
            "provider": "email",
            "uid": "ichiro@example.com",
            "allow_password_change": false,
            "name": "ichiro",
            "nickname": null,
            "image": null,
            "email": "ichiro@example.com",
            "created_at": "2020-10-16T11:14:48.731Z",
            "updated_at": "2020-10-16T11:16:56.927Z"
          }
        }
      }
    }
  ]
}

$ ATTENDEE_ID=$(curl localhost:3000/api/v1/rooms/1/meetings/${MEETING_ID}/attendees -X GET -H "content-type:application/json" -H "${_ACCESS_TOKEN}" -H "${_CLIENT}" -H "${_UID}" | jq -r .attendees[0].Attendee.AttendeeId)

$ curl localhost:3000/api/v1/rooms/1/meetings/${MEETING_ID}/attendees/${ATTENDEE_ID} -H "content-type:application/json" -H "${_ACCESS_TOKEN}" -H "${_CLIENT}" -H "${_UID}" | jq .

{
  "Attendee": {
    "ExternalUserId": "ChimeSdkRailsApp-development-User-1",
    "AttendeeId": "b581c46d-661f-92bb-d80e-XXXXXXXXXXXX",
    "JoinToken": "YjU4MWM0NmQtNjYxZi05MmJiLWQ4MGUtZjRiMTU3ZDk1ZmU5OjgyZmM2NTMxLTIwMjctNGMxMS04OTE0LTQwZjXXXXXXXXXXXX",
    "ApplicationMetadata": {
      "AttendeeType": "User",
      "User": {
        "id": 1,
        "provider": "email",
        "uid": "ichiro@example.com",
        "allow_password_change": false,
        "name": "ichiro",
        "nickname": null,
        "image": null,
        "email": "ichiro@example.com",
        "created_at": "2020-10-16T11:14:48.731Z",
        "updated_at": "2020-10-16T11:16:56.927Z"
      }
    }
  }
}

# Sign in as stephen

$ curl localhost:3000/api/v1/auth/sign_in -X POST -H "content-type:application/json" -D auth_headers.txt -d '{"email":"stephen@example.com", "password":"password"}'

{"data":{"id":2,"email":"stephen@example.com","provider":"email","uid":"stephen@example.com","allow_password_change":false,"name":"stephen","nickname":null,"image":null}}

$ _ACCESS_TOKEN=$(cat auth_headers.txt | grep access-token | rev | cut -c 2- | rev)
$ _CLIENT=$(cat auth_headers.txt | grep client | rev | cut -c 2- | rev)
$ _UID=$(cat auth_headers.txt | grep uid | rev | cut -c 2- | rev)

# Confirm attending same meeting in the private room as different attendee

$ curl localhost:3000/api/v1/rooms/1/meetings -X POST -H "content-type:application/json" -H "${_ACCESS_TOKEN}" -H "${_CLIENT}" -H "${_UID}" | jq .

{
  "Meeting": {
    "MeetingId": "2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
    "ExternalMeetingId": "ChimeSdkRailsApp-development-PrivateRoom-1",
    "MediaPlacement": {
      "AudioHostUrl": "d3175d855e633b72aedbXXXXXXXXXXXX.k.m2.ue1.app.chime.aws:3478",
      "AudioFallbackUrl": "wss://haxrp.m2.ue1.app.chime.aws:443/calls/2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "ScreenDataUrl": "wss://bitpw.m2.ue1.app.chime.aws:443/v2/screen/2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "ScreenSharingUrl": "wss://bitpw.m2.ue1.app.chime.aws:443/v2/screen/2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "ScreenViewingUrl": "wss://bitpw.m2.ue1.app.chime.aws:443/ws/connect?passcode=null&viewer_uuid=null&X-BitHub-Call-Id=2f550432-579c-4058-XXXXXXXXXXXX",
      "SignalingUrl": "wss://signal.m2.ue1.app.chime.aws/control/2f550432-579c-4058-bbb9-XXXXXXXXXXXX",
      "TurnControlUrl": "https://ccp.cp.ue1.app.chime.aws/v2/turn_sessions"
    },
    "MediaRegion": "us-east-1",
    "ApplicationMetadata": {
      "MeetingType": "PrivateRoom",
      "Room": {
        "id": 1,
        "name": "PrivateRoom-1",
        "created_at": "2020-10-16T11:15:56.223Z",
        "updated_at": "2020-10-16T11:15:56.223Z",
        "members": [
          {
            "id": 1,
            "provider": "email",
            "uid": "ichiro@example.com",
            "allow_password_change": false,
            "name": "ichiro",
            "nickname": null,
            "image": null,
            "email": "ichiro@example.com",
            "created_at": "2020-10-16T11:14:48.731Z",
            "updated_at": "2020-10-16T11:16:56.927Z"
          },
          {
            "id": 2,
            "provider": "email",
            "uid": "stephen@example.com",
            "allow_password_change": false,
            "name": "stephen",
            "nickname": null,
            "image": null,
            "email": "stephen@example.com",
            "created_at": "2020-10-16T11:15:33.226Z",
            "updated_at": "2020-10-16T11:21:46.011Z"
          }
        ]
      }
    }
  },
  "Attendee": {
    "ExternalUserId": "ChimeSdkRailsApp-development-User-2",
    "AttendeeId": "986886fc-dcbc-1d44-4708-XXXXXXXXXXXX",
    "JoinToken": "OTg2ODg2ZmMtZGNiYy0xZDQ0LTQ3MDgtOTE3YWIyMzExN2RlOjNjNjAzM2E5LWFlNGUtNGVmZi1iNjZjLWMwY2XXXXXXXXXXXX",
    "ApplicationMetadata": {
      "AttendeeType": "User",
      "User": {
        "id": 2,
        "provider": "email",
        "uid": "stephen@example.com",
        "allow_password_change": false,
        "name": "stephen",
        "nickname": null,
        "image": null,
        "email": "stephen@example.com",
        "created_at": "2020-10-16T11:15:33.226Z",
        "updated_at": "2020-10-16T11:21:46.011Z"
      }
    }
  }
}

$ MEETING_ID_2=$(curl localhost:3000/api/v1/rooms/1/meetings -X POST -H "content-type:application/json" -H "${_ACCESS_TOKEN}" -H "${_CLIENT}" -H "${_UID}" | jq -r .Meeting.MeetingId)

$ echo ${MEETING_ID}

2f550432-579c-4058-bbb9-XXXXXXXXXXXX

$ echo ${MEETING_ID_2}

2f550432-579c-4058-bbb9-XXXXXXXXXXXX
```

Now you can start online meeting using [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk) client-side implementation with this responded *Meeting* and *Attendee* data.

You can see [sample single page application](/spec/rails_app/app/javascript/) using [Vue.js](https://vuejs.org) and [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js) as a part of [example Rails application](#examples).


### B: Develop your Rails Application with Action View

Let's start to building simple Rails application with Action View providing real-time communications in a private room.
For example, create Rails application using [Devise](https://github.com/heartcombo/devise) for user authentication.

#### Prepare Rails application

At first, create new Rails application:

```bash
$ rails new chime_view_app
$ cd chime_view_app
```

Add gems to your Gemfile:

```ruby:Gemfile
# Gemfile

gem 'devise'
gem 'amazon-chime-sdk-rails'
```

Then, install *devise*:

```bash
$ bundle install
$ rails g devise:install
$ rails g devise User
$ rails g migration add_name_to_users name:string
$ rails g devise:views User
```

Update your `application_controller.rb` like this:

```ruby:app/controllers/application_controller.rb
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end 
end
```

Add user name form to your `app/views/users/registrations/new.html.erb` view template like this:

```erb:app/views/users/registrations/new.html.erb
# app/views/users/registrations/new.html.erb

<div class="field">
  <%= f.label :name %><br />
  <%= f.text_field :name, autocomplete: "name" %>
</div>

<div class="field">
  <%= f.label :email %><br />
  <%= f.email_field :email, autofocus: true, autocomplete: "email" %>
</div>
```

Update *devise* configuration in `devise.rb` to use scoped views:

```ruby:config/initializers/devise.rb
# config/initializers/devise.rb

Devise.setup do |config|
  # Uncomment and update
  config.scoped_views = true
end
```

Add login header to your application. Create new `app/views/layouts/_header.html.erb` and update your `app/views/layouts/application.html.erb` like this:

```erb:app/views/layouts/_header.html.erb
# app/views/layouts/_header.html.erb

<header>
  <div>
    <div>
      <strong>Rails Application for Amazon Chime SDK Meeting (Rails App with Action View)</strong>
    </div>
    <div>
      <% if user_signed_in? %>
        <%= current_user.name %>
        <%= link_to 'Logout', destroy_user_session_path, method: :delete %>
      <% else %>
        <%= link_to "Sign up", new_user_registration_path %>
        <%= link_to 'Login', new_user_session_path %>
      <% end %>
    </div>
  </div>
</header>
```

```erb:app/views/layouts/application.html.erb
# app/views/layouts/application.html.erb

<!DOCTYPE html>
<html>
  <head>
    <title>Rails Application for Amazon Chime SDK Meeting</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= yield(:javascript_pack_tag) %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <div id="app">
      <%= render 'layouts/header' %>
      <%= yield %>
    <div>
  </body>
</html>
```

#### Create private room functions

Create MVC by generator:

```bash
$ rails g scaffold room name:string
$ rails g scaffold entry room:references user:references
$ rake db:migrate
```

Update your `room.rb` like this:

```ruby:app/models/room.rb
# app/models/room.rb

class Room < ApplicationRecord
  has_many :entries, dependent: :destroy
  has_many :members, through: :entries, source: :user

  def member?(user)
    members.include?(user)
  end
end
```

Add uniqueness validation to your `entry.rb` like this:

```ruby:app/models/entry.rb
# app/models/entry.rb

class Entry < ApplicationRecord
  belongs_to :room
  belongs_to :user
  # Add uniqueness validation
  validates :user, uniqueness: { scope: :room }
end
```

Update *create* and *destroy* method in your `entries_controller.rb` like this:

```ruby:app/controllers/entries_controller.rb
# app/controllers/entries_controller.rb

class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :set_entry, only: [:destroy]

  # POST /entries
  # POST /entries.json
  def create
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to @room, notice: 'Member was successfully added.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { redirect_to @room, notice: @entry.errors }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to @room, notice: 'Member was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_room
    @room = Room.find(params[:room_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_entry
    @entry = Entry.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def entry_params
    params.require(:entry).permit(:room_id, :user_id)
  end
end
```

#### Develop meeting functions with amazon-chime-sdk-rails

Install *amazon-chime-sdk-rails* and generates your controllers:

```bash
$ rails g chime_sdk:install
$ rails g chime_sdk:controllers -r room
```

Add and uncomment several functions in generated `meetings_controller.rb` and `meeting_attendees_controller.rb` for your app configurations:

```ruby:app/controllers/api/meetings_controller.rb
# app/controllers/api/meetings_controller.rb

class MeetingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :check_membership

  include ChimeSdk::Controller::Meetings::Mixin

  private
  # Add
  def set_room
    @room = Room.find(params[:room_id])
  end

  # Add
  def check_membership
    unless @room.member?(current_user)
      message = 'Unauthorized: you are not a member of this private room.'
      redirect_to @room, notice: message
    end
  end

  # Uncomment
  def meeting_request_id
    "PrivateRoom-#{@room.id}"
  end

  # Uncomment
  def attendee_request_id
    "User-#{current_user.id}"
  end

  # Uncomment
  def application_meeting_metadata(meeting)
    {
      "MeetingType": "PrivateRoom",
      "Room": @room
    }
  end

  # Uncomment
  def application_attendee_metadata(attendee)
    user_id = attendee[:Attendee][:ExternalUserId].split('-')[3]
    {
      "AttendeeType": "User",
      "User": User.find_by_id(user_id)
    }
  end

  # Uncomment
  def application_attendee_metadata(attendee)
    user_id = attendee[:Attendee][:ExternalUserId].split('-')[3]
    {
      "AttendeeType": "User",
      "User": User.find_by_id(user_id)
    }
  end
end
```

```ruby:app/controllers/api/meeting_attendees_controller.rb
# app/controllers/api/meeting_attendees_controller.rb

class MeetingAttendeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :check_membership

  include ChimeSdk::Controller::Attendees::Mixin

  private
  # Add
  def set_room
    @room = Room.find(params[:room_id])
  end

  # Add
  def check_membership
    unless @room.member?(current_user)
      message = 'Unauthorized: you are not a member of this private room.'
      redirect_to @room, notice: message
    end
  end

  # Uncomment
  def attendee_request_id
    "User-#{current_user.id}"
  end

  # Uncomment
  def application_attendee_metadata(attendee)
    user_id = attendee[:Attendee][:ExternalUserId].split('-')[3]
    {
      "AttendeeType": "User",
      "User": User.find_by_id(user_id)
    }
  end
end
```

Generates meeting views by *amazon-chime-sdk-rails* generator:

```bash
$ rails g chime_sdk:views
```

Simply customize your meeting view generated *app/views/meetings/show.html.erb*:

```javascript
// app/views/meetings/show.html.erb

function showApplicationUserName(attendee) {
  // Comment
  // return attendee.Attendee.AttendeeId;
  // Uncomment
  return `${attendee.Attendee.ApplicationMetadata.User.name} (${attendee.Attendee.AttendeeId})`;
}
```

Bundle Amazon Chime SDK into single amazon-chime-sdk.min.js file and copy it to *app/assets/javascripts* by *amazon-chime-sdk-rails* generator:

```bash
$ rails g chime_sdk:js
```

Add *amazon-chime-sdk.min.js* to your Asset Pipeline:

```ruby:config/initializers/assets.rb
# config/initializers/assets.rb

Rails.application.config.assets.precompile += %w( amazon-chime-sdk.min.js )
```

Then, add member management and meeting link to your room view:

```erb:app/views/rooms/show.html.erb
# app/views/rooms/show.html.erb

<p id="notice"><%= notice %></p>

<p>
  <strong>Name:</strong>
  <%= @room.name %>
</p>

<p>
  <strong>Private Meeting:</strong>
  <p><%= link_to 'Show Meetings', room_meetings_path(@room) %></p>
  <p><%= link_to 'Join the Meeting', room_meetings_path(@room), method: :post %></p>
</p>

<p>
  <strong>Members:</strong>
  <table>
    <tbody>
      <% @room.entries.each do |entry| %>
        <tr>
          <td><%= entry.user.name %></td>
          <td><%= link_to 'Remove', [@room, entry], method: :delete, data: { confirm: 'Are you sure?' } %></td>
        </tr>
      <% end %>
    </tbody>
  </table>
</p>

<p>
  <strong>Add members:</strong>
  <%= form_for [@room, Entry.new] do |f| %>
    <%= f.hidden_field :room_id, value: @room.id %>
    <%= f.collection_select :user_id, User.all, :id, :name %>
    <%= f.submit "Add" %>
  <% end %>
</p>

<%= link_to 'Edit', edit_room_path(@room) %> |
<%= link_to 'Back', rooms_path %>
```

Update your `routes.rb` like this:

```ruby:config/routes.rb
# config/routes.rb

Rails.application.routes.draw do
  root "rooms#index"
  devise_for :users
  resources :rooms do
    resources :entries, only: [:create, :destroy]
    resources :meetings, only: [:index, :show, :create, :destroy] do
      resources :meeting_attendees, as: :attendees, path: :attendees, only: [:index, :show]
    end
  end
end
```

Note that you need to set up AWS credentials or IAM role for *amazon-chime-sdk-rails*. See [Set up AWS credentials](#set-up-aws-credentials) for more details.

Finally, start rails server:

```bash
$ rails server
```

Now ready to take off!

#### Start meeting with your Rails application

Access *http://localhost:3000/* through your web browser.

Sign up users from *Sign up* header. For example, sign up *ichiro* as *ichiro@example.com* and *stephen* as *stephen@example.com*.

Create new room and add *ichiro* and *stephen* as a room member.

Now you can join the meeting from *"Join the Meeting"* link in your room view. Your rails application includes simple online meeting implementation using [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk) as a Rails view.

##### The meeting has been created

<kbd>![meeting-created-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/meeting_created.png)</kbd>

##### Ichiro and Stephen have joined the meeting

<kbd>![meeting-created-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/meeting_joined.png)</kbd>

You should customize your meeting view using [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js). See [sample Rails application](/spec/rails_app/) using [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js) as a part of [example Rails application](#examples).


## Documentation

See [API Reference](http://www.rubydoc.info/github/simukappu/amazon-chime-sdk-rails/index) for more details.


## Examples

See example Rails application in *[/spec/rails_app](/spec/rails_app)*. You can run this example Rails application by the following steps:

```bash
$ git clone https://github.com/simukappu/amazon-chime-sdk-rails.git
$ cd amazon-chime-sdk-rails
$ bundle install
$ cd spec/rails_app
$ bin/rake db:migrate
$ bin/rake db:seed
$ bin/rails g chime_sdk:js
$ npm install
$ bin/rails server
```


## License

*amazon-chime-sdk-rails* project rocks and uses [MIT License](LICENSE).
