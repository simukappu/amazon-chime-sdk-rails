require 'rails/generators/base'

module ChimeSdk
  module Generators
    # Amazon Chime SDK single .js file generator.
    # Bundle Amazon Chime SDK into single amazon-chime-sdk.min.js file and copy it to app/assets/javascripts directory.
    # @example Run Amazon Chime SDK single .js file generator
    #   rails generate chime_sdk:js
    class JsGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Bundle Amazon Chime SDK into single amazon-chime-sdk.min.js file and copy it to app/assets/javascripts directory.

        Example:

          rails generate chime_sdk:js

        This generator requires npm installation.

      DESC

      source_root File.expand_path('./')

      # Build amazon-chime-sdk.min.js and copy it to app/assets/javascripts directory
      def build_and_copy_chime_sdk_js
        begin
          npm_version = Gem::Version.new(`npm -v`)
        rescue StandardError => e
          # :nocov:
          puts "Amazon Chime SDK single .js file generator requires npm. Install npm before running."
          return
          # :nocov:
        end
        puts "Found npm v#{npm_version}"

        `mkdir -p tmp`
        puts "Cloning into 'amazon-chime-sdk-js' git repository in tmp directory ..."
        `cd tmp; git clone https://github.com/aws/amazon-chime-sdk-js.git > /dev/null 2>&1`
        puts "Running 'npm install @rollup/plugin-commonjs' in the repository ..."
        `cd tmp/amazon-chime-sdk-js/demos/singlejs; npm install @rollup/plugin-commonjs > /dev/null 2>&1`
        puts "Running 'npm run bundle' in the repository ..."
        `cd tmp/amazon-chime-sdk-js/demos/singlejs; npm run bundle > /dev/null 2>&1`
        puts "Built Amazon Chime SDK as amazon-chime-sdk.min.js"
        copy_file "tmp/amazon-chime-sdk-js/demos/singlejs/build/amazon-chime-sdk.min.js", "app/assets/javascripts/amazon-chime-sdk.min.js"
        copy_file "tmp/amazon-chime-sdk-js/demos/singlejs/build/amazon-chime-sdk.min.js.map", "app/assets/javascripts/amazon-chime-sdk.min.js.map"
        `rm -rf tmp/amazon-chime-sdk-js`
        puts "Cleaned up the repository in tmp directory"
        puts "Completed"
      end
    end
  end
end