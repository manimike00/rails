FROM ruby:2.7-alpine3.12

RUN apk add --no-cache --virtual .build-deps \
    build-base \
    nodejs \
    nodejs-npm \
    yarn \
    tzdata \
    sqlite-dev \
    mysql-client \
    mongodb-tools \
    libxslt-dev \
    libxml2-dev

WORKDIR /var/www/html

COPY Gemfile Gemfile.lock ./
COPY yarn.lock package.json ./

# Set RAILS_ENV and RACK_ENV
ARG RAILS_ENV
ENV RACK_ENV=$RAILS_ENV

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler

RUN yarn install

# Finish establishing our Ruby enviornment depending on the RAILS_ENV
RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi

# Copy the main application.
COPY . ./

#CMD ["bundle", "exec", "rails", "s"]
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]