source 'https://rubygems.org'

gemspec

# Bundle Rails
gem 'rails', '~> 7.1.0'
# https://github.com/lynndylanhurley/devise_token_auth/pull/1606
gem 'devise_token_auth', git: 'https://github.com/lynndylanhurley/devise_token_auth.git'

gem 'sqlite3'
gem 'puma'
gem 'sass-rails'
gem 'turbolinks'
gem 'jbuilder'

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # gem 'coveralls', require: false
  gem 'coveralls_reborn', require: false
end

gem 'rack-cors', groups: [:production, :development]
gem 'dotenv-rails', groups: [:production, :development]