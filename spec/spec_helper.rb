ENV["RAILS_ENV"] ||= "test"

require 'simplecov'
require 'simplecov-lcov'
# Write an LCOV report for the Coveralls GitHub Action. It respects :nocov: blocks, unlike .resultset.json
SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.single_report_path = 'coverage/lcov.info'
end
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
]
SimpleCov.start('rails') do
  # Fail CI builds when line coverage of each job drops below 100%
  minimum_coverage 100 if ENV['CI']
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