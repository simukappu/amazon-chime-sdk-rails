ENV["RAILS_ENV"] ||= "test"

require 'simplecov'
require 'coveralls'
Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start('rails') do
  add_filter '/spec/'
  add_filter '/lib/generators/templates/'
  add_filter '/lib/chime_sdk/version'
end

# Test Rails application
require 'rails_app/config/environment'

def clean_database
  [Entry, Room, User].each do |model|
    model.delete_all
  end
end

require 'rspec/rails'
require 'factory_bot_rails'
require 'ammeter/init'
RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include FactoryBot::Syntax::Methods
  config.before(:all) do
    FactoryBot.reload
    clean_database
  end
end