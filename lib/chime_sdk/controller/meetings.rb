module ChimeSdk
  module Controller
    # Meetings controller implementation by amazon-chime-sdk-rails.
    module Meetings
      # Controller implementation to be included in custom meetings controllers.
      module Mixin
        extend ActiveSupport::Concern

        included do
          include ChimeSdk::Controller::Common
          include ActionController::MimeResponds
          helper_method :meeting_resources_path, :meeting_resource_path, :attendee_resources_path, :attendee_resource_path, :application_attendee_name
        end

        # GET /meetings
        # GET /meetings.json
        # @overload index(params)
        #   @param [Hash] params Request parameter options
        #   @option params [String] :create_meeting (ChimeSdk.config.create_meeting_by_get_request) Whether the application creates meeting in this meetings#index action by HTTP GET request
        def index
          if params[:create_meeting].to_s.to_boolean(false) || ChimeSdk.config.create_meeting_by_get_request && params[:create_meeting].to_s.to_boolean(true)
            create
          else
            list_meetings
            respond_to do |format|
              format.html
              format.json { render json: { meetings: @meetings } }
            end
          end
        end

        # GET /meetings/:meeting_id
        # GET /meetings/:meeting_id.json
        # @overload show(params)
        #   @param [Hash] params Request parameter options
        #   @option params [String] :create_attendee_from_meeting (ChimeSdk.config.create_attendee_from_meeting) Whether the application creates attendee from meeting in meetings#show action
        def show
          get_meeting
          if params[:create_attendee_from_meeting].to_s.to_boolean(false) || ChimeSdk.config.create_attendee_from_meeting && params[:create_attendee_from_meeting].to_s.to_boolean(true)
            create_attendee_from_meeting
          end
          respond_to do |format|
            format.html
            format.json { render json: @meeting }
          end
        end

        # POST /meetings
        # POST /meetings.json
        # @overload create(params)
        #   @param [Hash] params Request parameter options
        #   @option params [String] :create_meeting_with_attendee (ChimeSdk.config.create_meeting_with_attendee) Whether the application creates meeting with attendee in this meetings#create action
        def create
          if params[:create_meeting_with_attendee].to_s.to_boolean(false) || ChimeSdk.config.create_meeting_with_attendee && params[:create_meeting_with_attendee].to_s.to_boolean(true)
            create_meeting_with_attendee
          else
            create_meeting
          end
          respond_to do |format|
            format.html { redirect_to meeting_resource_path(meeting_id), notice: "Meeting <#{meeting_id}> was successfully created." }
            format.json { render status: 201, json: @meeting.merge(@attendee || {}) }
          end
        end

        # DELETE /meetings/:meeting_id
        # DELETE /meetings/:meeting_id.json
        def destroy
          delete_meeting
          respond_to do |format|
            format.html { redirect_to meeting_resources_path, notice: "Meeting <#{meeting_id}> was successfully destroyed." }
            format.json { head 204 }
          end
        end

        protected
        # Override the following functions in your controllers
        # :nocov:

        # Request parameter representing meeting id such as params[:id].
        # Configure it depending on your application routes.
        # @api protected
        # @return [String, Integer] Meeting id from request parameter
        def meeting_id_param
          params[:id]
        end

        # Unique meeting request id to identify meeting by Amazon Chime.
        # Configure it depending on your application resources to identify meeting.
        # For example, set "PrivateRoom-#{@room.id}" by Room model.
        # @api protected
        # @return [String] Unique meeting request id to identify meeting by Amazon Chime
        def meeting_request_id
          "default"
        end

        # Unique attendee request id to identify attendee by Amazon Chime.
        # Configure it depending on your application resources to identify attendee.
        # For example, set "User-#{current_user.id}" by User model.
        # @api protected
        # @return [String] Unique attendee request id to identify attendee by Amazon Chime
        def attendee_request_id
          "default"
        end

        # Path for meetings#index action such as meetings_path.
        # Configure it depending on your application routes.
        # @api protected
        # @param [Hash] params Request parameters for path method
        # @return [String] Path for meetings#index action such as meetings_path
        def meeting_resources_path(params = {})
          meetings_path(params)
        end

        # Path for meetings#show action such as meeting_path(meeting_id).
        # Configure it depending on your application routes.
        # @api protected
        # @param [String] meeting_id Meeting id
        # @param [Hash] params Request parameters for path method
        # @return [String] Path for meetings#show action such as meeting_path(meeting_id)
        def meeting_resource_path(meeting_id, params = {})
          meeting_path(meeting_id, params)
        end

        # Path for attendees#index action such as attendees_path(meeting_id).
        # Configure it depending on your application routes.
        # @api protected
        # @param [String] meeting_id Meeting id
        # @param [Hash] params Request parameters for path method
        # @return [String] Path for attendees#index action such as attendees_path(meeting_id)
        def attendee_resources_path(meeting_id, params = {})
          attendees_path(meeting_id, params)
        end

        # Path for attendees#show action such as attendee_path(meeting_id, attendee_id).
        # Configure it depending on your application routes.
        # @api protected
        # @param [String] meeting_id Meeting id
        # @param [String] attendee_id Attendee id
        # @param [Hash] params Request parameters for path method
        # @return [String] Path for attendees#index action such as attendees_path(meeting_id)
        def attendee_resource_path(meeting_id, attendee_id, params = {})
          attendee_path(meeting_id, attendee_id, params)
        end

        # Optional meeting tags to pass to Amazon Chime.
        # This is an optional parameter and configure it depending on your application.
        # @api protected
        # @return [Array<Hash>] Optional tags for meetings
        def optional_meeting_tags
          []
        end

        # Optional attendee tags to pass to Amazon Chime.
        # This is an optional parameter and configure it depending on your application.
        # @api protected
        # @return [Array<Hash>] Optional tags for attendees
        def optional_attendee_tags
          []
        end

        # Appication metadata that meetings API returns as JSON response included in meeting resource.
        # This is an optional parameter and configure it depending on your application.
        # @api protected
        # @param [Hash] meeting Meeting JSON object as hash
        # @return [Hash] Appication metadata for meetings
        def application_meeting_metadata(meeting)
          {}
        end

        # Appication metadata that attendees API returns as JSON response included in attendee resource.
        # This is an optional parameter and configure it depending on your application.
        # @api protected
        # @param [Hash] attendee Attendee JSON object as hash
        # @return [Hash] Appication metadata for attendees
        def application_attendee_metadata(attendee)
          {}
        end

        # Application attendee name to resolve from attendee object in your view.
        # This is an optional parameter and configure it depending on your application.
        # @api protected
        # @param [Hash] attendee Attendee JSON object as hash
        # @return [String] Appication attendee name to resolve from attendee object in your view
        def application_attendee_name(attendee)
          attendee[:Attendee][:AttendeeId]
        end

        # :nocov:
      end
    end
  end
end