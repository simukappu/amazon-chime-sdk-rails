class Api::MeetingsController < ::MeetingsController
  include DeviseTokenAuth::Concerns::SetUserByToken
end