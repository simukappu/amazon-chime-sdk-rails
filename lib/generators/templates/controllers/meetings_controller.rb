# Generated by amazon-chime-sdk-rails

class <%= @namespace %><%= @class_name_prefix %>MeetingsController < ApplicationController

  include ChimeSdk::Controller::Meetings::Mixin

  private
  # Override the following functions in your controllers.

  # Request parameter representing meeting id such as params[:id].
  # Configure it depending on your application routes.
  # @api protected
  # @return [String, Integer] Meeting id from request parameter
  # def meeting_id_param
  #   params[:id]
  # end

  # Unique meeting request id to identify meeting by Amazon Chime.
  # Configure it depending on your application resources to identify meeting.
  # For example, set "PrivateRoom-#{@room.id}" by Room model.
  # @api protected
  # @return [String] Unique meeting request id to identify meeting by Amazon Chime
  def meeting_request_id
    # "PrivateRoom-#{@room.id}"
    "<%= @default_meeting_request_id %>"
  end

  # Unique attendee request id to identify attendee by Amazon Chime.
  # Configure it depending on your application resources to identify attendee.
  # For example, set "User-#{current_user.id}" by User model.
  # @api protected
  # @return [String] Unique attendee request id to identify attendee by Amazon Chime
  def attendee_request_id
    # "User-#{current_user.id}"
    "default"
  end

  # Path for meetings#index action such as meetings_path.
  # Configure it depending on your application routes.
  # @api protected
  # @param [Hash] params Request parameters for path method
  # @return [String] Path for meetings#index action such as meetings_path
  def meeting_resources_path(params = {})
    <%= @path_name_prefix %>meetings_path(<%= @path_args_prefix %>params)
  end

  # Path for meetings#show action such as meeting_path(meeting_id).
  # Configure it depending on your application routes.
  # @api protected
  # @param [String] meeting_id Meeting id
  # @param [Hash] params Request parameters for path method
  # @return [String] Path for meetings#show action such as meeting_path(meeting_id)
  def meeting_resource_path(meeting_id, params = {})
    <%= @path_name_prefix %>meeting_path(<%= @path_args_prefix %>meeting_id, params)
  end

  # Path for attendees#index action such as attendees_path(meeting_id).
  # Configure it depending on your application routes.
  # @api protected
  # @param [String] meeting_id Meeting id
  # @param [Hash] params Request parameters for path method
  # @return [String] Path for attendees#index action such as attendees_path(meeting_id)
  def attendee_resources_path(meeting_id, params = {})
    <%= @path_name_prefix %>meeting_attendees_path(<%= @path_args_prefix %>meeting_id, params)
  end

  # Path for attendees#show action such as attendee_path(meeting_id, attendee_id).
  # Configure it depending on your application routes.
  # @api protected
  # @param [String] meeting_id Meeting id
  # @param [String] attendee_id Attendee id
  # @param [Hash] params Request parameters for path method
  # @return [String] Path for attendees#index action such as attendees_path(meeting_id)
  def attendee_resource_path(meeting_id, attendee_id, params = {})
    <%= @path_name_prefix %>meeting_attendee_path(<%= @path_args_prefix %>meeting_id, attendee_id, params)
  end

  # Optional meeting tags to pass to Amazon Chime.
  # This is an optional parameter and configure it depending on your application.
  # @api protected
  # @return [Array<Hash>] Optional tags for meetings
  # def optional_meeting_tags
  #   [
  #     {
  #       key: "MeetingType",
  #       value: "PrivateRoom"
  #     },
  #     {
  #       key: "RoomId",
  #       value: @room.id.to_s
  #     }
  #   ]
  # end

  # Optional attendee tags to pass to Amazon Chime.
  # This is an optional parameter and configure it depending on your application.
  # @api protected
  # @return [Array<Hash>] Optional tags for attendees
  # def optional_attendee_tags
  #   [
  #     {
  #       key: "AttendeeType",
  #       value: "User"
  #     },
  #     {
  #       key: "UserId",
  #       value: current_user.id.to_s
  #     }
  #   ]
  # end

  # Appication metadata that meetings API returns as JSON response included in meeting resource.
  # This is an optional parameter and configure it depending on your application.
  # @api protected
  # @param [Hash] meeting Meeting JSON object as hash
  # @return [Hash] Appication metadata for meetings
  # def application_meeting_metadata(meeting)
  #   {
  #     "MeetingType": "PrivateRoom",
  #     "PrivateRoom": @room
  #   }
  # end

  # Appication metadata that attendees API returns as JSON response included in attendee resource.
  # This is an optional parameter and configure it depending on your application.
  # @api protected
  # @param [Hash] meeting Attendee JSON object as hash
  # @return [Hash] Appication metadata for attendees
  # def application_attendee_metadata(attendee)
  #   user_id = attendee[:Attendee][:ExternalUserId].split('-')[3]
  #   {
  #     "AttendeeType": "User",
  #     "User": User.find_by_id(user_id)
  #   }
  # end

  # Application attendee name to resolve from attendee object in your view.
  # This is an optional parameter and configure it depending on your application.
  # @api protected
  # @param [Hash] meeting Attendee JSON object as hash
  # @return [String] Appication attendee name to resolve from attendee object in your view
  def application_attendee_name(attendee)
    # attendee[:Attendee][:ApplicationMetadata][:User][:name]
    attendee[:Attendee][:AttendeeId]
  end
end