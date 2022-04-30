class Api::Public::MeetingAttendeesController < ApplicationController
  include ChimeSdk::Controller::Attendees::Mixin

  def application_attendee_metadata(attendee)
    user_id = attendee[:Attendee][:ExternalUserId].split('-')[3]
    {
      "AttendeeType": "User",
      "User": User.find_by_id(user_id)
    }
  end
end