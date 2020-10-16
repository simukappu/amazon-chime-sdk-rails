require 'rails/generators/base'

module ChimeSdk
  module Generators
    # View generator to copy customizable meetings view files from templates.
    # @example Run view generator as default name
    #   rails generate chime_sdk:views
    # @example Run view generator as room prefix
    #   rails generate chime_sdk:views rooms
    class ViewsGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Create meetings views for Amazon Chime SDK in your app/views folder.

        Example:

          rails generate chime_sdk:views

        Views files will be generated in app/views/meetings directory.
        You can also specify prefix of views name like this:

          rails generate chime_sdk:views room

        Then, views files will be generated in app/views/room_meetings directory.
      DESC

      # Views to be generated
      VIEWS = [:meetings].freeze

      source_root File.expand_path("../../templates/views", __FILE__)
      argument :prefix, required: false,
        desc: "Prefix of view directory name, e.g. room"

      # Generate view files in application directory
      def generate_views
        target_views = VIEWS
        file_prefix = prefix.blank? ? '' : prefix.singularize.underscore + '_'
        target_views.each do |name|
          directory name, "app/views/#{file_prefix}#{name}"
        end
      end
    end
  end
end