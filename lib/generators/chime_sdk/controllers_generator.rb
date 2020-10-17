require 'rails/generators/base'

module ChimeSdk
  module Generators
    # Controller generator to copy customizable meetings and attendees controller files from templates.
    # @example Run controller generator as default name
    #   rails generate chime_sdk:controllers
    # @example Run controller generator with prefix as 'room'
    #   rails generate chime_sdk:controllers room
    # @example Run controller generator with parent option as 'room'
    #   rails generate chime_sdk:controllers -r room
    # @example Run controller generator with namespace option as 'api'
    #   rails generate chime_sdk:controllers -n api
    class ControllersGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Create meetings and attendees controllers for Amazon Chime SDK in your app/controllers folder.

        Example:

          rails generate chime_sdk:controllers

        You can specify prefix of controllers name like this:

          rails generate chime_sdk:controllers room

        Then, meeting controller class will be generated as app/controllers/room_meetings_controller.rb like this:

          class RoomMeetingsController < ApplicationController
            include ChimeSdk::Controller::Meetings::Mixin
            def meeting_resources_path(params = {})
              room_meetings_path(@room, params)
            end
            ...
          end

        Use --parent option to specify parent resource of meetings. If you specify prefix of controllers name, parent option will be ignored.

          rails generate chime_sdk:controllers --parent room

        Then, meeting controller class will be generated as app/controllers/meetings_controller.rb like this:

          class MeetingsController < ApplicationController
            include ChimeSdk::Controller::Meetings::Mixin
            def meeting_resources_path(params = {})
              room_meetings_path(@room, params)
            end
            ...
          end

        Use --namespace option to specify namespace of generated controllers.

          rails generate chime_sdk:controllers --namespace api
  
        Then, meeting controller class will be generated as app/controllers/api/meetings_controller.rb like this:

          class Api::MeetingsController < ApplicationController
            include ChimeSdk::Controller::Meetings::Mixin
            def meeting_resources_path(params = {})
              api_meetings_path(params)
            end
            ...
          end

        Use --controllers option to specify which controller you want to generate. If you do no specify a controller, all controllers will be created.

          rails generate chime_sdk:controllers --controllers meetings
      DESC

      # Controllers to be generated
      CONTROLLERS = ['meetings', 'meeting_attendees'].freeze

      source_root File.expand_path("../../templates/controllers", __FILE__)
      argument :prefix, required: false,
        desc: "Prefix of controllers name, e.g. room"
      class_option :parent, aliases: "-r", type: :string,
        desc: "Parent resource of generated controllers, e.g. room"
      class_option :namespace, aliases: "-n", type: :string,
        desc: "Namespace of generated controllers, e.g. api"
      class_option :controllers, aliases: "-c", type: :array,
        desc: "Select specific controllers to generate (#{CONTROLLERS.join(', ')})"

      # Generate controller files in application directory
      def generate_controllers
        @namespace = options[:namespace].blank? ? '' : "#{options[:namespace].camelize}::"
        @class_name_prefix = prefix.blank? ? '' : prefix.singularize.camelize
        @param_name_prefix = prefix.blank? ? '' : "#{prefix.singularize.underscore}_"
        parent_resource = prefix.present? ? prefix.singularize.underscore : (options[:parent].blank? ? '' : options[:parent].singularize.underscore)
        @path_name_prefix = (options[:namespace].blank? ? '' : "#{options[:namespace].singularize.underscore}_") + (parent_resource.blank? ? '' : "#{parent_resource}_")
        @path_args_prefix = parent_resource.blank? ? '' : "@#{parent_resource}, "
        @default_meeting_request_id = parent_resource.blank? ? 'default' : "#{parent_resource.camelize}-#{'#'}{@#{parent_resource}.id}"
        file_name_prefix = (options[:namespace].blank? ? '' : "#{options[:namespace].underscore}/") + @param_name_prefix
        controllers = options[:controllers] || CONTROLLERS
        controllers.each do |name|
          template "#{name}_controller.rb", "app/controllers/#{file_name_prefix}#{name}_controller.rb"
        end
      end

      # Show readme after generated controllers
      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end