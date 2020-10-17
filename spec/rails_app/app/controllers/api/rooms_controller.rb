class Api::RoomsController < ::RoomsController
  include DeviseTokenAuth::Concerns::SetUserByToken
end
