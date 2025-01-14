FROM ruby:3.4.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs npm
ENV ROOT="/amazon-chime-sdk-rails"
WORKDIR ${ROOT}
COPY Gemfile ${ROOT}
COPY amazon-chime-sdk-rails.gemspec ${ROOT}
COPY lib/ ${ROOT}/lib/
RUN bundle install
COPY spec/rails_app/ ${ROOT}/spec/rails_app/
WORKDIR ${ROOT}/spec/rails_app
RUN bin/rake db:migrate
RUN bin/rake db:seed
RUN bin/rails g chime_sdk:js
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]