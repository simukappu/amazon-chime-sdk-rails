require 'rails/generators/base'

module ChimeSdk
  module Generators
    # Amazon Chime SDK single .js file generator.
    # Bundle Amazon Chime SDK into single amazon-chime-sdk.min.js file and copy it to app/assets/javascripts directory.
    # @example Run Amazon Chime SDK single .js file generator with the latest version from master branch
    #   rails generate chime_sdk:js
    # @example Run Amazon Chime SDK single .js file generator with specified version
    #   rails generate chime_sdk:js 2.8.0
    # @see https://github.com/aws/amazon-chime-sdk-js/tree/master/demos/singlejs
    # @see https://github.com/aws/amazon-chime-sdk-js/tags
    class JsGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Bundle Amazon Chime SDK into single amazon-chime-sdk.min.js file and copy it to app/assets/javascripts directory.

        Example:

          rails generate chime_sdk:js

        You can also specify version of amazon-chime-sdk-js like this:

          rails generate chime_sdk:js 2.8.0

        This generator requires npm installation.

      DESC

      source_root File.expand_path('./')
      argument :version, required: false,
        desc: "Specific version of amazon-chime-sdk-js, e.g. 2.8.0"

      # Build amazon-chime-sdk.min.js and copy it to app/assets/javascripts directory
      def build_and_copy_chime_sdk_js
        # :nocov:
        begin
          node_version = Gem::Version.new(`node -v`.delete("v"))
          puts "Found Node v#{node_version}"
          if node_version < Gem::Version.new("10")
            puts "Amazon Chime SDK single .js file generator requires Node 10+. Update Node before running."
            return
          end
        rescue StandardError => e
          puts "Amazon Chime SDK single .js file generator requires Node. Install Node before running."
          return
        end
        begin
          npm_version = Gem::Version.new(`npm -v`)
          puts "Found npm v#{npm_version}"
          if npm_version < Gem::Version.new("6.11")
            puts "Amazon Chime SDK single .js file generator requires npm 6.11+. Update npm before running."
            return
          end
        rescue StandardError => e
          puts "Amazon Chime SDK single .js file generator requires npm. Install npm before running."
          return
        end
        # :nocov:

        if version.present?
          begin
            sdk_version = Gem::Version.new(version)
            # https://github.com/aws/amazon-chime-sdk-js/commit/6bf1d64529827970992ad5ce1ec26b2729a4595c
            if sdk_version < Gem::Version.new("1.3.0")
              puts "Specify 1.3.0 or later as amazon-chime-sdk-js version."
              return
            # https://github.com/aws/amazon-chime-sdk-js/tags
            elsif sdk_version < Gem::Version.new("1.19.14")
              version_tag = "amazon-chime-sdk-js@#{sdk_version}"
            else
              version_tag = "v#{sdk_version}"
            end
            puts "Specified v#{sdk_version} as amazon-chime-sdk-js version"
          rescue StandardError => e
            puts "Wrong amazon-chime-sdk-js version was specified."
            return
          end
        end

        system "mkdir -p tmp"
        puts "Cloning into 'amazon-chime-sdk-js' git repository in tmp directory ..."
        system "cd tmp; git clone https://github.com/aws/amazon-chime-sdk-js.git > /dev/null 2>&1"
        if version_tag.present?
          if system "cd tmp/amazon-chime-sdk-js; git checkout refs/tags/#{version_tag} > /dev/null 2>&1"
            puts "Checking out 'refs/tags/#{version_tag}'"
          else
            puts "No 'refs/tags/#{version_tag}' was found. Specify different amazon-chime-sdk-js version."
            return
          end
        end
        puts "Running 'npm install @rollup/plugin-commonjs' in the repository ..."
        system "cd tmp/amazon-chime-sdk-js/demos/singlejs; npm install @rollup/plugin-commonjs > /dev/null 2>&1"
        puts "Running 'npm run bundle' in the repository ..."
        system "cd tmp/amazon-chime-sdk-js/demos/singlejs; npm run bundle > /dev/null 2>&1"
        puts "Built Amazon Chime SDK as amazon-chime-sdk.min.js"
        copy_file "tmp/amazon-chime-sdk-js/demos/singlejs/build/amazon-chime-sdk.min.js", "app/assets/javascripts/amazon-chime-sdk.min.js"
        copy_file "tmp/amazon-chime-sdk-js/demos/singlejs/build/amazon-chime-sdk.min.js.map", "app/assets/javascripts/amazon-chime-sdk.min.js.map"
        system "rm -rf tmp/amazon-chime-sdk-js"
        puts "Cleaned up the repository in tmp directory"
        puts "Completed"
      end
    end
  end
end