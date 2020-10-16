module ChimeSdk
  # Meeting coordinator as a wrapper module of AWS SDK for Ruby, which simulates AWS SDK for JavaScript.
  # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html Aws::Chime::Client of AWS SDK for Ruby
  # @see https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Chime.html AWS.Chime of AWS SDK for JavaScript
  module MeetingCoordinator
    require 'aws-sdk-chime'

    # Return initialized Aws::Chime::Client.
    # You must use "us-east-1" as the region for Chime API and set the endpoint.
    # @return [Aws::Chime::Client] Initialized Aws::Chime::Client instance
    # @see https://aws.github.io/amazon-chime-sdk-js/modules/gettingstarted.html
    def self.client
      @@client ||= Aws::Chime::Client.new(region: 'us-east-1')
    end

    # Reset client with initialized Aws::Chime::Client instance.
    # @param [Aws::Chime::Client] client Initialized Aws::Chime::Client instance
    # @return [Aws::Chime::Client] Initialized Aws::Chime::Client instance
    def self.reset_client(client)
      @@client = client
    end

    # Wrapper of Aws::Chime::Client#list_meetings method.
    # This function also provides prefix match filter of external_meeting_id.
    # This method filters the result with ChimeSdk.config.prefix to return only meetings in your application.
    # @param [Integer] max_results (ChimeSdk.config.max_meeting_results) The maximum number of results to return in a single call
    # @param [String] prefix_filter (nil) Additional string for prefix match filter of external_meeting_id
    # @return [Array<Hash>] Array of filtered meeting JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#list_meetings-instance_method Aws::Chime::Client#list_meetings of AWS SDK for Ruby
    def self.list_meetings(
      max_results: ChimeSdk.config.max_meeting_results,
      prefix_filter: nil
    )
      resp = client.list_meetings({
        max_results: max_results
      })
      meetings = resp.meetings
      meetings = meetings.select { |meeting| meeting.external_meeting_id.start_with?(ChimeSdk.config.prefix + prefix_filter) } if prefix_filter
      meetings.map { |meeting| meeting_as_json(meeting) }
    end

    # Wrapper of Aws::Chime::Client#create_meeting method.
    # This method uses 'ChimeSdk.config.prefix + meeting_request_id' for client_request_token and external_meeting_id.
    # @param [required, String] meeting_request_id The unique identifier for the client request. Use a different token for different meetings.
    # @param [String] meeting_host_id (nil) Reserved
    # @param [String] media_region (ChimeSdk.config.media_region) The Region in which to create the meeting
    # @param [Array<Aws::Chime::Types::Tag>] tags (nil) The tag key-value pairs
    # @param [Aws::Chime::Types::MeetingNotificationConfiguration] notifications_configuration (nil) The configuration for resource targets to receive notifications when meeting and attendee events occur
    # @return [Hash] Created meeting JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#create_meeting-instance_method Aws::Chime::Client#create_meeting of AWS SDK for Ruby
    def self.create_meeting(meeting_request_id,
      meeting_host_id: nil,
      media_region: ChimeSdk.config.media_region,
      tags: [],
      notifications_configuration: {}
    )
      resp = client.create_meeting({
        client_request_token: ChimeSdk.config.prefix + meeting_request_id,
        external_meeting_id: ChimeSdk.config.prefix + meeting_request_id,
        meeting_host_id: meeting_host_id,
        media_region: media_region,
        tags: tags,
        notifications_configuration: notifications_configuration
      })
      meeting_as_json(resp.meeting)
    end

    # Wrapper of Aws::Chime::Client#get_meeting method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @return [Hash] Meeting JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#get_meeting-instance_method Aws::Chime::Client#get_meeting of AWS SDK for Ruby
    def self.get_meeting(meeting_id)
      resp = client.get_meeting({
        meeting_id: meeting_id
      })
      meeting_as_json(resp.meeting)
    end

    # Wrapper of Aws::Chime::Client#delete_meeting method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @return [void]
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#delete_meeting-instance_method Aws::Chime::Client#delete_meeting of AWS SDK for Ruby
    def self.delete_meeting(meeting_id)
      client.delete_meeting({
        meeting_id: meeting_id
      })
    end

    # Wrapper of Aws::Chime::Client#list_attendees method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @param [Integer] max_results (ChimeSdk.config.max_attendee_results) The maximum number of results to return in a single call
    # @return [Array<Hash>] Array of attendee JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#list_attendees-instance_method Aws::Chime::Client#list_attendees of AWS SDK for Ruby
    def self.list_attendees(meeting_id,
      max_results: ChimeSdk.config.max_attendee_results
    )
      resp = client.list_attendees({
        meeting_id: meeting_id,
        max_results: max_results
      })
      resp.attendees.map { |attendee| attendee_as_json(attendee) }
    end

    # Wrapper of Aws::Chime::Client#create_attendee method.
    # This method uses 'ChimeSdk.config.prefix + attendee_request_id' for external_user_id.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @param [required, String] attendee_request_id Part of the Amazon Chime SDK external user ID. Links the attendee to an identity managed by a builder application.
    # @return [Hash] Created attendee JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#create_attendee-instance_method Aws::Chime::Client#create_attendee of AWS SDK for Ruby
    def self.create_attendee(meeting_id, attendee_request_id, tags: [])
      resp = client.create_attendee({
        meeting_id: meeting_id,
        external_user_id: ChimeSdk.config.prefix + attendee_request_id,
        tags: tags
      })
      attendee_as_json(resp.attendee)
    end

    # Wrapper of Aws::Chime::Client#get_attendee method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @param [required, String] attendee_id The Amazon Chime SDK attendee ID
    # @return [Hash] Attendee JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#get_attendee-instance_method Aws::Chime::Client#get_attendee of AWS SDK for Ruby
    def self.get_attendee(meeting_id, attendee_id)
      resp = client.get_attendee({
        meeting_id: meeting_id,
        attendee_id: attendee_id
      })
      attendee_as_json(resp.attendee)
    end

    # Wrapper of Aws::Chime::Client#delete_attendee method.
    # @param [required, String] attendee_id The Amazon Chime SDK attendee ID
    # @return [void]
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#delete_attendee-instance_method Aws::Chime::Client#delete_attendee of AWS SDK for Ruby
    def self.delete_attendee(meeting_id, attendee_id)
      client.delete_attendee({
        meeting_id: meeting_id,
        attendee_id: attendee_id
      })
    end
    
    # Build meeting JSON object as hash from Aws::Chime::Types::Meeting object
    # @param [required, Aws::Chime::Types::Meeting] meeting Meeting response as Aws::Chime::Types::Meeting object
    # @return [Hash] Meeting JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#get_meeting-instance_method Aws::Chime::Client#get_meeting of AWS SDK for Ruby
    # @see https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Chime.html#getMeeting-property AWS.Chime#getMeeting of AWS SDK for JavaScript
    def self.meeting_as_json(meeting)
      return {} unless meeting.is_a?(Aws::Chime::Types::Meeting)
      {
        "Meeting": {
          "MeetingId": meeting.meeting_id,
          "ExternalMeetingId": meeting.external_meeting_id,
          "MediaPlacement": {
            "AudioHostUrl": meeting.media_placement.audio_host_url,
            "AudioFallbackUrl": meeting.media_placement.audio_fallback_url,
            "ScreenDataUrl": meeting.media_placement.screen_data_url,
            "ScreenSharingUrl": meeting.media_placement.screen_sharing_url,
            "ScreenViewingUrl": meeting.media_placement.screen_viewing_url,
            "SignalingUrl": meeting.media_placement.signaling_url,
            "TurnControlUrl": meeting.media_placement.turn_control_url
          },
          "MediaRegion": meeting.media_region
        }
      }
    end

    # Build attendee JSON object as hash from Aws::Chime::Types::Attendee object
    # @param [required, Aws::Chime::Types::Attendee] attendee Attendee response as Aws::Chime::Types::Attendee object
    # @return [Hash] Attendee JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Chime/Client.html#get_attendee-instance_method Aws::Chime::Client#get_attendee of AWS SDK for Ruby
    # @see https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Chime.html#getAttendee-property AWS.Chime#getAttendee of AWS SDK for JavaScript
    def self.attendee_as_json(attendee)
      return {} unless attendee.is_a?(Aws::Chime::Types::Attendee)
      {
        "Attendee": {
          "ExternalUserId": attendee.external_user_id,
          "AttendeeId": attendee.attendee_id,
          "JoinToken": attendee.join_token
        }
      }
    end
  end
end