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
end