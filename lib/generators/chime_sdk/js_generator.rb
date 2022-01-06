require 'rails/generators/base'

module ChimeSdk
  module Generators
    # Amazon Chime SDK single .js file generator.
    # Bundle Amazon Chime SDK into single amazon-chime-sdk.min.js file and copy it to app/assets/javascripts directory.
    # @example Run Amazon Chime SDK single .js file generator with the latest version from master branch
    #   rails generate chime_sdk:js
    # @example Run Amazon Chime SDK single .js file generator with specified version
    #   rails generate chime_sdk:js 2.24.0
    # @see https://github.com/aws-samples/amazon-chime-sdk/tree/main/utils/singlejs
    # @see https://www.npmjs.com/package/amazon-chime-sdk-js
    class JsGenerator < Rails::Generators::Base
      desc <<-DESC.strip_heredoc
        Bundle Amazon Chime SDK into single amazon-chime-sdk.min.js file and copy it to app/assets/javascripts directory.

        Example:

          rails generate chime_sdk:js

        You can also specify version of amazon-chime-sdk-js like this:

          rails generate chime_sdk:js 2.24.0

        This generator requires npm installation.

      DESC

      source_root File.expand_path('./')
      argument :version, required: false,
        desc: "Specific version of amazon-chime-sdk-js, e.g. 2.24.0"

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
            # https://www.npmjs.com/package/amazon-chime-sdk-js
            if sdk_version < Gem::Version.new("1.0.0")
              puts "[Abort] Specify 1.0.0 or later as amazon-chime-sdk-js version"
              exit
            else
              version_tag = "amazon-chime-sdk-js@#{sdk_version}"
            end
          rescue StandardError => e
            puts "[Abort] Wrong amazon-chime-sdk-js version was specified"
            exit
          end
        end

        system "mkdir -p tmp"
        puts "Cloning into 'amazon-chime-sdk-js' git repository in tmp directory ..."
        system "cd tmp; git clone https://github.com/aws-samples/amazon-chime-sdk.git > /dev/null 2>&1"
        repository_path = "tmp/amazon-chime-sdk"
        singlejs_path = "#{repository_path}/utils/singlejs"
        package_json_path = "#{singlejs_path}/package.json"

        puts "Finding amazon-chime-sdk-js version ..."
        chime_sdk_pattern = /\"amazon-chime-sdk-js\":[\s]*\"([\S]*)\"$/
        buffer = File.open(package_json_path, "r") { |f| f.read() }
        if version_tag.present?
          puts " Specified \"#{sdk_version}\" as an argument"
          if `npm info #{version_tag} version`.present?
            puts " #{version_tag} was found as npm package"
            if buffer =~ chime_sdk_pattern
              buffer.gsub!(chime_sdk_pattern, "\"amazon-chime-sdk-js\": \"#{sdk_version}\"")
              File.open(package_json_path, "w") { |f| f.write(buffer) }
              puts " Replaced amazon-chime-sdk-js version into \"#{sdk_version}\" in package.json"
              puts " amazon-chime-sdk-js \"#{sdk_version}\" will be used"
            else
              # :nocov:
              puts "[Abort] amazon-chime-sdk-js was not found in package.json"
              exit
              # :nocov:
            end
          else
            puts "[Abort] No npm package of #{version_tag} was found. Specify different amazon-chime-sdk-js version."
            exit
          end
        else
          if buffer =~ /\"amazon-chime-sdk-js\":[\s]*\"([\S]*)\"$/
            sdk_version = $1
            puts " amazon-chime-sdk-js \"#{sdk_version}\" was found in package.json"
            puts " amazon-chime-sdk-js \"#{sdk_version}\" will be used"
          else
            # :nocov:
            puts " No amazon-chime-sdk-js was found in package.json"
            # :nocov:
          end
        end

        puts "Running 'npm install @rollup/plugin-commonjs' in the repository ..."
        system "cd #{singlejs_path}; npm install @rollup/plugin-commonjs > /dev/null 2>&1"
        puts "Running 'npm run bundle' in the repository ..."
        system "cd #{singlejs_path}; npm run bundle > /dev/null 2>&1"
        puts "Built Amazon Chime SDK as amazon-chime-sdk.min.js"
        copy_file "#{singlejs_path}/build/amazon-chime-sdk.min.js", "app/assets/javascripts/amazon-chime-sdk.min.js"
        copy_file "#{singlejs_path}/build/amazon-chime-sdk.min.js.map", "app/assets/javascripts/amazon-chime-sdk.min.js.map"
        system "rm -rf #{repository_path}"
        puts "Cleaned up the repository in tmp directory"
        puts "Completed"
      end
    end
  end
end