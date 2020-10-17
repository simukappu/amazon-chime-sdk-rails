# Load the Rails application.
require_relative 'application'

# Test application uses Devise and Devise Token Auth
require 'devise'
require 'devise_token_auth'

# Initialize the Rails application.
Rails.application.initialize!

# Load database schema
if Rails.env.test?
  load "#{Rails.root}/db/schema.rb"
end