module ChimeSdk
  # Class used to initialize configuration object.
  class Config
    # @overload application_name
    #   Return application name for unique key and metadata of Chime SDK meetings and attendees.
    #   @return [Boolean] application name for unique key and metadata of Chime SDK meetings and attendees
    # @overload application_name=(value)
    #   Set application name for unique key and metadata of Chime SDK meetings and attendees.
    #   @param [Boolean] application_name The new application_name
    #   @return [Boolean] application name for unique key and metadata of Chime SDK meetings and attendees
    attr_accessor :application_name

    # @overload media_region
    #   Return media region to host Chime SDK meetings.
    #   @return [Boolean] Media region to host Chime SDK meetings
    # @overload media_region=(value)
    #   Set media region to host Chime SDK meetings.
    #   @param [Boolean] media_region The new media_region
    #   @return [Boolean] Media region to host Chime SDK meetings
    attr_accessor :media_region

    # @overload prefix
    #   Return prefix to make unique key of Chime SDK meetings and attendees.
    #   @return [Boolean] Prefix to make unique key of Chime SDK meetings and attendees
    # @overload prefix=(value)
    #   Set prefix to make unique key of Chime SDK meetings and attendees.
    #   @param [Boolean] prefix The new prefix
    #   @return [Boolean] Prefix to make unique key of Chime SDK meetings and attendees
    attr_accessor :prefix

    # @overload max_attendee_results
    #   Return default max_results value used in list_attendees API.
    #   @return [Boolean] Default max_results value used in list_attendees API
    # @overload max_attendee_results=(value)
    #   Set default max_results value used in list_attendees API.
    #   @param [Boolean] max_attendee_results The new max_attendee_results
    #   @return [Boolean] Default max_results value used in list_attendees API
    attr_accessor :max_attendee_results

    # @overload create_meeting_with_attendee
    #   Return whether the application creates meeting with attendee in meetings#create action.
    #   @return [Boolean] Whether the application creates meeting with attendee in meetings#create action
    # @overload create_meeting_with_attendee=(value)
    #   Set whether the application creates meeting with attendee in meetings#create action.
    #   @param [Boolean] create_meeting_with_attendee The new create_meeting_with_attendee
    #   @return [Boolean] Whether the application creates meeting with attendee in meetings#create action
    attr_accessor :create_meeting_with_attendee

    # @overload create_attendee_from_meeting
    #   Return whether the application creates attendee from meeting in meetings#show action.
    #   @return [Boolean] Whether the application creates attendee from meeting in meetings#show action
    # @overload create_attendee_from_meeting=(value)
    #   Set whether the application creates attendee from meeting in meetings#show action.
    #   @param [Boolean] create_attendee_from_meeting The new create_attendee_from_meeting
    #   @return [Boolean] Whether the application creates attendee from meeting in meetings#show action
    attr_accessor :create_attendee_from_meeting

    # @overload create_meeting_by_get_request
    #   Return whether the application creates meeting in meetings#index action by HTTP GET request.
    #   @return [Boolean] Whether the application creates meeting in meetings#index action by HTTP GET request
    # @overload create_meeting_by_get_request=(value)
    #   Set whether the application creates meeting in meetings#index action by HTTP GET request.
    #   @param [Boolean] create_meeting_by_get_request The new create_meeting_by_get_request
    #   @return [Boolean] Whether the application creates meeting in meetings#index action by HTTP GET request
    attr_accessor :create_meeting_by_get_request

    # Initialize configuration for ChimeSdk.
    # These configuration can be overridden in initializer.
    # @return [Config] A new instance of Config
    def initialize
      @application_name              = 'chime-sdk-rails'
      @media_region                  = 'us-east-1'
      @prefix                        = "#{@application_name}-#{Rails.env}-"
      @max_attendee_results          = 10
      @create_meeting_with_attendee  = true
      @create_attendee_from_meeting  = true
      @create_meeting_by_get_request = false
    end
  end
end