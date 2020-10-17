class Api::MeetingAttendeesController < ::MeetingAttendeesController
  include DeviseTokenAuth::Concerns::SetUserByToken
end