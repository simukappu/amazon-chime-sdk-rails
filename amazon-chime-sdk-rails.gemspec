$:.push File.expand_path("../lib", __FILE__)

require "chime_sdk/version"

Gem::Specification.new do |s|
  s.name          = "amazon-chime-sdk-rails"
  s.version       = ChimeSdk::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Shota Yamazaki"]
  s.email         = ["shota.yamazaki.8@gmail.com"]
  s.homepage      = "https://github.com/simukappu/amazon-chime-sdk-rails"
  s.summary       = "Server-side implementation of Amazon Chime SDK for Ruby on Rails application"
  s.description   = "amazon-chime-sdk-rails provides server-side API implementation for Amazon Chime SDK as wrapper functions of AWS SDK for Ruby, and basic controller implementation for Ruby on Rails application."
  s.license       = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 3.1.0'

  s.add_dependency 'railties', '>= 7.0.0'
  s.add_dependency 'aws-sdk-chimesdkmeetings', '>= 1.0.0'

  s.add_development_dependency 'rspec-rails', '>= 6.0.0'
  s.add_development_dependency 'factory_bot_rails', '>= 6.2.0'
  s.add_development_dependency 'ammeter', '>= 1.1.5'
  s.add_development_dependency 'yard', '>= 0.9.36'
  s.add_development_dependency 'devise_token_auth', '>= 1.2.2'
end