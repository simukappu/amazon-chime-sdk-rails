## Develop your Rails Application with Action View

Let's start to build simple Rails application with Action View providing real-time communications in a private room.
For example, create Rails application using [Devise](https://github.com/heartcombo/devise) for user authentication.

### Prepare Rails application

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

### Create private room functions

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

### Develop meeting functions with amazon-chime-sdk-rails

Install *amazon-chime-sdk-rails* and generate your controllers by *Controller Generator*:

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

Bundle Amazon Chime SDK into single amazon-chime-sdk.min.js file and copy it to *app/assets/javascripts* by *Single Javascript Generator* in *amazon-chime-sdk-rails*:

```bash
$ rails g chime_sdk:js
```

Add *amazon-chime-sdk.min.js* to your Asset Pipeline:

```ruby:config/initializers/assets.rb
# config/initializers/assets.rb

Rails.application.config.assets.precompile += %w( amazon-chime-sdk.min.js )
```

Then, generate meeting views by *View Generator* in *amazon-chime-sdk-rails*:

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

Add member management and meeting link to your room view:

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
$ rails s
```

Now ready to take off! Open *http://localhost:3000/* in your browser. Sign up users from *Sign up* header. For example, sign up *ichiro* as *ichiro@example.com* and *stephen* as *stephen@example.com*. Then, create a new room and add *ichiro* and *stephen* as room members.

Now you can create a new meeting from room view.

<kbd>![default-meeting-view-created-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/default_meeting_view_created.png)</kbd>

After creating a new meeting from any private room, you can join the meeting from "*Join the Meeting*" button in your meeting view. Your rails application includes simple online meeting implementation using [Amazon Chime SDK](https://aws.amazon.com/chime/chime-sdk) as a rails view.

<kbd>![default-meeting-view-joined-image](https://raw.githubusercontent.com/simukappu/amazon-chime-sdk-rails/images/default_meeting_view_joined.png)</kbd>

You can also customize your meeting view using [Amazon Chime SDK for JavaScript](https://github.com/aws/amazon-chime-sdk-js). Enjoy your application development!