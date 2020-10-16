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
        def index
          list_attendees
          render json: { attendees: @attendees }
        end

        # GET /meetings/:meeting_id/attendees/:attendee_id
        def show
          get_attendee
          render json: @attendee
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