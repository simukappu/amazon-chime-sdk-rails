require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

require File.expand_path('../spec/rails_app/config/application', __FILE__)
Rails.application.load_tasks

require 'yard'
desc 'Generate documentation for amazon-chime-sdk-rails plugin.'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

# Define dummy module for Rake tasks
require 'devise_token_auth'
unless defined?(DeviseTokenAuth::Concerns::User)
  module DeviseTokenAuth::Concerns
    module User
    end
  end
end