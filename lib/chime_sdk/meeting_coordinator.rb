module ChimeSdk
  # Meeting coordinator as a wrapper module of AWS SDK for Ruby, which simulates AWS SDK for JavaScript.
  # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html Aws::ChimeSDKMeetings::Client of AWS SDK for Ruby
  # @see https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/ChimeSDKMeetings.html AWS.ChimeSDKMeetings of AWS SDK for JavaScript
  module MeetingCoordinator
    require 'aws-sdk-chimesdkmeetings'

    # Return initialized Aws::ChimeSDKMeetings::Client.
    # You must use "us-east-1" as the region for Chime API and set the endpoint.
    # @return [Aws::ChimeSDKMeetings::Client] Initialized Aws::ChimeSDKMeetings::Client instance
    # @see https://aws.github.io/amazon-chime-sdk-js/modules/gettingstarted.html
    def self.client
      @@client ||= Aws::ChimeSDKMeetings::Client.new(region: 'us-east-1')
    end

    # Reset client with initialized Aws::ChimeSDKMeetings::Client instance.
    # @param [Aws::ChimeSDKMeetings::Client] client Initialized Aws::ChimeSDKMeetings::Client instance
    # @return [Aws::ChimeSDKMeetings::Client] Initialized Aws::ChimeSDKMeetings::Client instance
    def self.reset_client(client)
      @@client = client
    end

    # Wrapper of Aws::ChimeSDKMeetings::Client#create_meeting method.
    # This method uses 'ChimeSdk.config.prefix + meeting_request_id' for client_request_token and external_meeting_id.
    # @param [required, String] meeting_request_id The unique identifier for the client request. Use a different token for different meetings.
    # @param [String] media_region (ChimeSdk.config.media_region) The Region in which to create the meeting
    # @param [String] meeting_host_id (nil) Reserved
    # @param [Aws::ChimeSDKMeetings::Types::MeetingNotificationConfiguration] notifications_configuration (nil) The configuration for resource targets to receive notifications when meeting and attendee events occur
    # @param [Aws::ChimeSDKMeetings::Types::MeetingFeaturesConfiguration] meeting_features (nil) Lists the audio and video features enabled for a meeting, such as echo reduction
    # @param [String] primary_meeting_id (nil) When specified, replicates the media from the primary meeting to the new meeting
    # @param [Array<String>] tenant_ids (nil) A consistent and opaque identifier, created and maintained by the builder to represent a segment of their users
    # @param [Array<Aws::ChimeSDKMeetings::Types::Tag>] tags (nil) Applies one or more tags to an Amazon Chime SDK meeting
    # @return [Hash] Created meeting JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#create_meeting-instance_method Aws::ChimeSDKMeetings::Client#create_meeting of AWS SDK for Ruby
    def self.create_meeting(meeting_request_id,
      media_region: ChimeSdk.config.media_region,
      meeting_host_id: nil,
      notifications_configuration: {},
      meeting_features: {},
      primary_meeting_id: nil,
      tenant_ids: nil,
      tags: []
    )
      resp = client.create_meeting({
        client_request_token: ChimeSdk.config.prefix + meeting_request_id,
        media_region: media_region,
        meeting_host_id: meeting_host_id,
        external_meeting_id: ChimeSdk.config.prefix + meeting_request_id,
        notifications_configuration: notifications_configuration,
        meeting_features: meeting_features,
        primary_meeting_id: primary_meeting_id,
        tenant_ids: tenant_ids,
        tags: tags
      })
      meeting_as_json(resp.meeting)
    end

    # Wrapper of Aws::ChimeSDKMeetings::Client#get_meeting method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @return [Hash] Meeting JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#get_meeting-instance_method Aws::ChimeSDKMeetings::Client#get_meeting of AWS SDK for Ruby
    def self.get_meeting(meeting_id)
      resp = client.get_meeting({
        meeting_id: meeting_id
      })
      meeting_as_json(resp.meeting)
    end

    # Wrapper of Aws::ChimeSDKMeetings::Client#delete_meeting method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @return [void]
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#delete_meeting-instance_method Aws::ChimeSDKMeetings::Client#delete_meeting of AWS SDK for Ruby
    def self.delete_meeting(meeting_id)
      client.delete_meeting({
        meeting_id: meeting_id
      })
    end

    # Wrapper of Aws::ChimeSDKMeetings::Client#list_attendees method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @param [Integer] max_results (ChimeSdk.config.max_attendee_results) The maximum number of results to return in a single call
    # @return [Array<Hash>] Array of attendee JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#list_attendees-instance_method Aws::ChimeSDKMeetings::Client#list_attendees of AWS SDK for Ruby
    def self.list_attendees(meeting_id,
      max_results: ChimeSdk.config.max_attendee_results
    )
      # attendees = [], next_token = nil
      # loop do
        resp = client.list_attendees({
          meeting_id: meeting_id,
          # next_token: next_token,
          max_results: max_results
        })
      #   next_token = resp.next_token
      #   attendees += resp.attendees
      #   break if next_token.nil?
      # end
      # attendees.map { |attendee| attendee_as_json(attendee) }
      resp.attendees.map { |attendee| attendee_as_json(attendee) }
    end

    # Wrapper of Aws::ChimeSDKMeetings::Client#create_attendee method.
    # This method uses 'ChimeSdk.config.prefix + attendee_request_id' for external_user_id.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @param [required, String] attendee_request_id Part of the Amazon Chime SDK external user ID. Links the attendee to an identity managed by a builder application.
    # @param [Aws::ChimeSDKMeetings::Types::AttendeeCapabilities] capabilities The capabilities (audio, video, or content) that you want to grant an attendee
    # @return [Hash] Created attendee JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#create_attendee-instance_method Aws::ChimeSDKMeetings::Client#create_attendee of AWS SDK for Ruby
    def self.create_attendee(meeting_id, attendee_request_id, capabilities: nil)
      resp = client.create_attendee({
        meeting_id: meeting_id,
        external_user_id: ChimeSdk.config.prefix + attendee_request_id,
        capabilities: capabilities
      })
      attendee_as_json(resp.attendee)
    end

    # Wrapper of Aws::ChimeSDKMeetings::Client#get_attendee method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @param [required, String] attendee_id The Amazon Chime SDK attendee ID
    # @return [Hash] Attendee JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#get_attendee-instance_method Aws::ChimeSDKMeetings::Client#get_attendee of AWS SDK for Ruby
    def self.get_attendee(meeting_id, attendee_id)
      resp = client.get_attendee({
        meeting_id: meeting_id,
        attendee_id: attendee_id
      })
      attendee_as_json(resp.attendee)
    end

    # Wrapper of Aws::ChimeSDKMeetings::Client#delete_attendee method.
    # @param [required, String] meeting_id The Amazon Chime SDK meeting ID
    # @param [required, String] attendee_id The Amazon Chime SDK attendee ID
    # @return [void]
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#delete_attendee-instance_method Aws::ChimeSDKMeetings::Client#delete_attendee of AWS SDK for Ruby
    def self.delete_attendee(meeting_id, attendee_id)
      client.delete_attendee({
        meeting_id: meeting_id,
        attendee_id: attendee_id
      })
    end
    
    # Build meeting JSON object as hash from Aws::ChimeSDKMeetings::Types::Meeting object
    # @param [required, Aws::ChimeSDKMeetings::Types::Meeting] meeting Meeting response as Aws::ChimeSDKMeetings::Types::Meeting object
    # @return [Hash] Meeting JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#get_meeting-instance_method Aws::ChimeSDKMeetings::Client#get_meeting of AWS SDK for Ruby
    # @see https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/ChimeSDKMeetings.html#getMeeting-property AWS.Chime#getMeeting of AWS SDK for JavaScript
    def self.meeting_as_json(meeting)
      return {} unless meeting.is_a?(Aws::ChimeSDKMeetings::Types::Meeting)
      meeting_json = {
        "Meeting": {
          "MeetingId": meeting.meeting_id,
          "MeetingHostId": meeting.meeting_host_id,
          "ExternalMeetingId": meeting.external_meeting_id,
          "MediaRegion": meeting.media_region,
          "MediaPlacement": {
            "AudioHostUrl": meeting.media_placement.audio_host_url,
            "AudioFallbackUrl": meeting.media_placement.audio_fallback_url,
            "SignalingUrl": meeting.media_placement.signaling_url,
            "TurnControlUrl": meeting.media_placement.turn_control_url,
            # This parameter is deprecated and no longer used by the Amazon Chime SDK
            "ScreenDataUrl": meeting.media_placement.screen_data_url,
            # This parameter is deprecated and no longer used by the Amazon Chime SDK
            "ScreenViewingUrl": meeting.media_placement.screen_viewing_url,
            # This parameter is deprecated and no longer used by the Amazon Chime SDK
            "ScreenSharingUrl": meeting.media_placement.screen_sharing_url,
            # This parameter is deprecated and no longer used by the Amazon Chime SDK
            "EventIngestionUrl": meeting.media_placement.event_ingestion_url
          },
          "PrimaryMeetingId": meeting.primary_meeting_id,
          "TenantIds": meeting.tenant_ids,
          "MeetingArn": meeting.meeting_arn
        }
      }
      unless meeting.meeting_features.nil?
        meeting_json[:Meeting]["MeetingFeatures"] = {
          "Audio": {
            "EchoReduction": meeting.meeting_features.audio.echo_reduction
          },
          "Video": {
            "MaxResolution": meeting.meeting_features.video.max_resolution
          },
          "Content": {
            "MaxResolution": meeting.meeting_features.content.max_resolution
          },
          "Attendee": {
            "MaxCount": meeting.meeting_features.attendee.max_count
          }
        }
      end
      meeting_json
    end

    # Build attendee JSON object as hash from Aws::ChimeSDKMeetings::Types::Attendee object
    # @param [required, Aws::ChimeSDKMeetings::Types::Attendee] attendee Attendee response as Aws::ChimeSDKMeetings::Types::Attendee object
    # @return [Hash] Attendee JSON object as hash
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ChimeSDKMeetings/Client.html#get_attendee-instance_method Aws::ChimeSDKMeetings::Client#get_attendee of AWS SDK for Ruby
    # @see https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/ChimeSDKMeetings.html#getAttendee-property AWS.Chime#getAttendee of AWS SDK for JavaScript
    def self.attendee_as_json(attendee)
      return {} unless attendee.is_a?(Aws::ChimeSDKMeetings::Types::Attendee)
      attendee_json = {
        "Attendee": {
          "ExternalUserId": attendee.external_user_id,
          "AttendeeId": attendee.attendee_id,
          "JoinToken": attendee.join_token
        }
      }
      unless attendee.capabilities.nil?
        attendee_json[:Attendee]["Capabilities"] = {
          "Audio": attendee.capabilities.audio,
          "Video": attendee.capabilities.video,
          "Content": attendee.capabilities.content
        }
      end
      attendee_json
    end
  end
end