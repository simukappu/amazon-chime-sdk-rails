# Top level namespace of amazon-chime-sdk-rails, server-side implementation of Amazon Chime SDK for Ruby on Rails application.
module ChimeSdk
  extend ActiveSupport::Autoload

  autoload :Config            , 'chime_sdk/config'
  autoload :MeetingCoordinator, 'chime_sdk/meeting_coordinator'

  # Returns configuration object of ChimeSdk.
  def self.config
    @config ||= ChimeSdk::Config.new
  end

  # Sets global configuration options for ChimeSdk.
  # Available options and their defaults are in the example below:
  # @example Initializer for Rails
  #   ChimeSdk.configure do |config|
  #     config.appication_name               = 'chime-sdk-rails'
  #     config.media_region                  = 'us-east-1'
  #     config.prefix                        = "#{config.application_name}-#{Rails.env}-"
  #     config.max_attendee_results          = 10
  #     config.create_meeting_with_attendee  = true
  #     config.create_attendee_from_meeting  = true
  #     config.create_meeting_by_get_request = false
  #   end
  def self.configure
    yield(config) if block_given?
  end

  # Load AWS SDK for Amazon Chime SDK meetings
  require 'aws-sdk-chimesdkmeetings'

  # Load ChimeSdk helpers
  require 'chime_sdk/controller/common'
  require 'chime_sdk/controller/meetings'
  require 'chime_sdk/controller/attendees'
end