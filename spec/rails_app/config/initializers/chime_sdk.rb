ChimeSdk.configure do |config|
  # Configure application name for unique key and metadata of Chime SDK meetings and attendees.
  # Do not use '-' in this application name since it is a delimiter.
  config.application_name = 'ChimeSdkRailsApp'

  # Configure media region to host Chime SDK meetings.
  # Default value is 'us-east-1'.
  config.media_region = 'us-east-1'

  # Configure prefix to make unique key of Chime SDK meetings and attendees.
  # Default value is "#{config.application_name}-#{Rails.env}-".
  config.prefix = "#{config.application_name}-#{Rails.env}-"

  # Configure default max_results value used in list_meetings API.
  config.max_meeting_results = 10

  # Configure default max_results value used in list_attendees API.
  config.max_attendee_results = 10

  # Configure whether the application creates meeting with attendee in meetings#create action.
  config.create_meeting_with_attendee = true

  # Configure whether the application creates attendee from meeting in meetings#show action.
  config.create_attendee_from_meeting = true

  # Configure whether the application creates meeting in meetings#index action by HTTP GET request.
  config.create_meeting_by_get_request = false
end