class Api::Public::MeetingsController < ApplicationController
  include ChimeSdk::Controller::Meetings::Mixin

  def index
    render json: { api: 'meetings', status: 'healthy' }
  end

  def application_meeting_metadata(meeting)
    room_id = meeting[:Meeting][:ExternalMeetingId].split('-')[3]
    {
      "MeetingType": "PrivateRoom",
      "PrivateRoom": Room.find_by_id(room_id)
    }
  end

  # This public API for the React Meeting Demo accepts any meeting in the AWS account by its meeting id.
  # Do not disable this verification in your applications unless you authorize access to meetings by yourself.
  def verify_meeting_request_id?
    false
  end
end