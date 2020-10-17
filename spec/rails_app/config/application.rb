require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    if Rails.version.to_f >= 5.1
      config.load_defaults Rails.version.to_f
    end

    if Rails::VERSION::MAJOR >= 6
      # Allow requests to www.example.com for RSpec
      config.hosts << 'www.example.com'
    end
  end
end
