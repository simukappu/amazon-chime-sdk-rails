source 'https://rubygems.org'

gemspec

# Bundle Rails
gem 'rails', '~> 8.1.0'
# https://github.com/lynndylanhurley/devise_token_auth/pull/1639
gem 'devise_token_auth', git: 'https://github.com/lynndylanhurley/devise_token_auth.git'

gem 'sqlite3'
gem 'puma'
gem 'sass-rails'
gem 'jbuilder'

group :development do
  gem 'web-console'
  gem 'listen'
end

group :test do
  gem 'coveralls_reborn', require: false
end

gem 'rack-cors', groups: [:production, :development]
gem 'dotenv-rails', groups: [:production, :development]
