module ChimeSdk
  # Controllers implementation by amazon-chime-sdk-rails.
  module Controller
    # Common implementation for controllers.
    module Common
      extend ActiveSupport::Concern

      included do
        rescue_from Aws::Chime::Errors::ForbiddenException, with: :render_forbidden
        rescue_from Aws::Chime::Errors::NotFoundException, with: :render_resource_not_found
        rescue_from Aws::Chime::Errors::ValidationException, with: :render_resource_not_found

        class ::String
          # Convets to boolean.
          # Returns true for 'true', '1', 'yes', 'on' and 't'.
          # Returns false for 'false', '0', 'no', 'off' and 'f'.
          # @param [Boolean] default Default value to return when the String is not interpretable
          # @return [Boolean] Convered boolean value
          def to_boolean(default = nil)
            return true if ['true', '1', 'yes', 'on', 't'].include? self
            return false if ['false', '0', 'no', 'off', 'f'].include? self
            return default
          end
        end
      end
  
      protected
      # Return meeting id from @meeting object or meeting id param.
      # @api protected
      # @return [String] Meeting id
      def meeting_id
        @meeting ? @meeting[:Meeting][:MeetingId] : meeting_id_param
      end

      # Return attendee id from @attendee object or attendee id param.
      # @api protected
      # @return [String] Attendee id
      def attendee_id
        @attendee ? @attendee[:Attendee][:AttendeeId] : attendee_id_param
      end

      # List meetings by MeetingCoordinator.
      # @api protected
      # @return [Array<Hash>] Meeting list
      def list_meetings
        @meetings = ChimeSdk::MeetingCoordinator.list_meetings(prefix_filter: meeting_request_id)
        @meetings = @meetings.map { |meeting| merge_application_meeting_metadata(meeting) }
      end

      # Create meeting by MeetingCoordinator.
      # @api protected
      # @return [Hash] Created meeting
      def create_meeting
        @meeting = ChimeSdk::MeetingCoordinator.create_meeting(meeting_request_id, tags: meeting_tags)
        @meeting = merge_application_meeting_metadata(@meeting)
      end

      # Get meeting by MeetingCoordinator.
      # @api protected
      # @return [Hash] Meeting
      def get_meeting
        @meeting = ChimeSdk::MeetingCoordinator.get_meeting(meeting_id)
        @meeting = merge_application_meeting_metadata(@meeting)
      end

      # Delete meeting by MeetingCoordinator.
      # @api protected
      # @return [void]
      def delete_meeting
        ChimeSdk::MeetingCoordinator.delete_meeting(meeting_id)
      end

      # List attendees by MeetingCoordinator.
      # @api protected
      # @return [Array<Hash>] Attendee list
      def list_attendees
        @attendees = ChimeSdk::MeetingCoordinator.list_attendees(meeting_id)
        @attendees = @attendees.map { |attendee| merge_application_attendee_metadata(attendee) }
      end

      # Create attendee by MeetingCoordinator.
      # @api protected
      # @return [Hash] Created attendee
      def create_attendee
        @attendee = ChimeSdk::MeetingCoordinator.create_attendee(meeting_id, attendee_request_id, tags: attendee_tags)
        @attendee = merge_application_attendee_metadata(@attendee)
      end

      # Get attendee by MeetingCoordinator.
      # @api protected
      # @return [Hash] Attendee
      def get_attendee
        @attendee = ChimeSdk::MeetingCoordinator.get_attendee(meeting_id, attendee_id)
        @attendee = merge_application_attendee_metadata(@attendee)
      end

      # Delete attendee by MeetingCoordinator.
      # @api protected
      # @return [void]
      def delete_attendee
        ChimeSdk::MeetingCoordinator.delete_attendee(meeting_id, attendee_id)
      end

      # Create meeting with attendee by MeetingCoordinator.
      # @api protected
      # @return [Hash] Created meeting
      def create_meeting_with_attendee
        create_meeting
        create_attendee_from_meeting
        @meeting
      end

      # Create attendee from meeting by MeetingCoordinator.
      # @api protected
      # @return [Hash] Created attendee
      def create_attendee_from_meeting
        create_attendee
        @meeting = @meeting.merge(@attendee)
        @meeting = merge_application_attendee_metadata(@meeting)
        @meeting = merge_application_attendee_metadata(@meeting)
        @attendee = merge_application_attendee_metadata(@attendee)
      end

      # Return common tags for meetings and attendees.
      # @api protected
      # @return [Array<Hash>] Common tags
      def tags
        [
          {
            key: "Application",
            value: ChimeSdk.config.application_name
          },
          {
            key: "Environment",
            value: Rails.env
          }
        ]
      end

      # Return tags for meetings from defined optional_meeting_tags.
      # @api protected
      # @return [Array<Hash>] Tags for meetings
      def meeting_tags
        tags + optional_meeting_tags
      end

      # Return tags for attendees from defined optional_attendee_tags.
      # @api protected
      # @return [Array<Hash>] Tags for attendees
      def attendee_tags
        tags + optional_attendee_tags
      end

      # Merge application metadata into meeting instance and return.
      # @api protected
      # @param [Hash] meeting Meeting JSON object as hash
      # @return [Hash] Merged meeting
      def merge_application_meeting_metadata(meeting)
        meeting[:Meeting][:ApplicationMetadata] = application_meeting_metadata(meeting)
        meeting
      end

      # Merge application metadata into attendee instance and return.
      # @api protected
      # @param [Hash] attendee Attendee JSON object as hash
      # @return [Hash] Merged attendee
      def merge_application_attendee_metadata(attendee)
        attendee[:Attendee][:ApplicationMetadata] = application_attendee_metadata(attendee)
        attendee
      end

      # Returns error response as Hash
      # @api protected
      # @return [Hash] Error message
      def error_response(error_info = {})
        { gem: "chime-sdk-rails", error: error_info }
      end

      # Render Forbidden error with 403 status
      # @api protected
      # @return [void]
      def render_forbidden(error = nil)
        message_type = error.respond_to?(:message) ? error.message : error
        respond_to do |format|
          format.html { redirect_to meeting_resources_path, notice: "Forbidden: #{message_type}" }
          format.json { render status: 403, json: error_response(code: 403, message: "Forbidden", type: message_type) }
        end
      end

      # Render Resource Not Found error with 404 status
      # @api protected
      # @return [void]
      def render_resource_not_found(error = nil)
        message_type = error.respond_to?(:message) ? error.message : error
        respond_to do |format|
          format.html { redirect_to meeting_resources_path, notice: "Resource not found: #{message_type}" }
          format.json { render status: 404, json: error_response(code: 404, message: "Resource not found", type: message_type) }
        end
      end
    end
  end
end