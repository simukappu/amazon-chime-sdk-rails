## Develop your Rails API Application

Let's start to build simple Rails API application providing real-time communications in a private room.
For example, create Rails API application using [Devise Token Auth](https://github.com/lynndylanhurley/devise_token_auth) for user authentication.

### Prepare Rails API application

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

### Create private room functions

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

### Develop meeting functions with amazon-chime-sdk-rails

Install *amazon-chime-sdk-rails* and generate your controllers by *Controller Generator*:

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
      "PrivateRoom": @room
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
$ rails s
```

Now ready to take off!

### Get meeting configurations through Rails API

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

Now you can start online meeting using [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk) client-side implementation with this responded *Meeting* and *Attendee* data. You can see [customized React Meeting Demo](https://github.com/simukappu/amazon-chime-sdk/tree/main/apps/meeting) as a sample single page application using [React](https://reactjs.org/) and [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js). Enjoy your application development!