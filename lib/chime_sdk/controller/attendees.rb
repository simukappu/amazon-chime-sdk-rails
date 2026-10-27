module ChimeSdk
  module Controller
    # Attendees controller implementation by amazon-chime-sdk-rails.
    module Attendees
      # Controller implementation to be included in custom attendees controllers.
      module Mixin
        extend ActiveSupport::Concern

        included do
          include ChimeSdk::Controller::Common
          include ActionController::MimeResponds
        end
    
        # GET /meetings/:meeting_id/attendees
        # Join tokens are omitted since they are credentials of each attendee.
        def index
          list_attendees
          render json: { attendees: @attendees.map { |attendee| without_join_token(attendee) } }
        end

        # GET /meetings/:meeting_id/attendees/:attendee_id
        # The join token is omitted since it is a credential of the attendee.
        def show
          get_attendee
          render json: without_join_token(@attendee)
        end

        # POST /meetings/:meeting_id/attendees
        def create
          create_attendee
          render status: 201, json: @attendee
        end

        # DELETE /meetings/:meeting_id/attendees/:attendee_id
        def destroy
          delete_attendee
          head 204
        end

        protected
        # Override the following functions in your controllers
        # :nocov:

        # Request parameter representing meeting id such as params[:meeting_id].
        # Configure it depending on your application routes.
        # @api protected
        # @return [String, Integer] Meeting id from request parameter
        def meeting_id_param
          params[:meeting_id]
        end

        # Request parameter representing attendee id such as params[:id].
        # Configure it depending on your application routes.
        # @api protected
        # @return [String, Integer] Attendee id from request parameter
        def attendee_id_param
          params[:id]
        end

        # Unique meeting request id to identify meeting by Amazon Chime.
        # Configure it depending on your application resources to identify meeting.
        # For example, set "PrivateRoom-#{@room.id}" by Room model.
        # Requested meetings are verified with this id when ChimeSdk.config.verify_meeting_request_id is enabled.
        # @api protected
        # @return [String] Unique meeting request id to identify meeting by Amazon Chime
        def meeting_request_id
          "default"
        end

        # Unique attendee request id to identify attendee by Amazon Chime.
        # Configure it depending on your application resources to identify attendee.
        # For example, set "User-#{current_user.id}" by User model.
        # Each user must have a different value, since users with the same value join meetings as the same attendee.
        # @api protected
        # @return [String] Unique attendee request id to identify attendee by Amazon Chime
        # @raise [NotImplementedError] Unless overridden in your controllers
        def attendee_request_id
          raise NotImplementedError, "Define attendee_request_id in #{self.class.name} to identify each attendee, e.g. \"User-\#{current_user.id}\""
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

        # Optional attendee tags to pass to Amazon Chime.
        # This is an optional parameter and configure it depending on your application.
        # @api protected
        # @return [Array<Hash>] Optional tags for attendees
        def optional_attendee_tags
          []
        end

        # Appication metadata that attendees API returns as JSON response included in attendee resource.
        # This is an optional parameter and configure it depending on your application.
        # @api protected
        # @param [Hash] attendee Attendee JSON object as hash
        # @return [Hash] Appication metadata for attendees
        def application_attendee_metadata(attendee)
          {}
        end

        # :nocov:
      end
    end
  end
end