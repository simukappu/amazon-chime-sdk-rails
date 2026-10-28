class Api::Public::MeetingAttendeesController < ApplicationController
  include ChimeSdk::Controller::Attendees::Mixin

  def application_attendee_metadata(attendee)
    user_id = attendee[:Attendee][:ExternalUserId].delete_prefix(ChimeSdk.config.prefix)[/\AUser-(\d+)\z/, 1]
    {
      "AttendeeType": "User",
      "User": User.find_by_id(user_id)&.slice(:id, :name)
    }
  end

  # This public API for the React Meeting Demo accepts any meeting in the AWS account by its meeting id.
  # Do not disable this verification in your applications unless you authorize access to meetings by yourself.
  def verify_meeting_request_id?
    false
  end
end