require 'rails/generators/base'

module ChimeSdk
  # Generators implementation by amazon-chime-sdk-rails.
  module Generators #:nodoc:
    # Install generator to copy initializer to rails application.
    # @example Run install generator
    #   rails generate chime_sdk:install
    class InstallGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Create chime_sdk initializer in your application.

        Example:

          rails generate chime_sdk:insall

      DESC

      source_root File.expand_path("../../templates", __FILE__)

      # Copies initializer file in application directory
      def copy_initializer
        template "chime_sdk.rb", "config/initializers/chime_sdk.rb"
      end
    end
  end
end