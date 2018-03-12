FROM ruby:2.4-alpine

WORKDIR /opt/puppet

ENV PUPPET_VERSION "~> 5"
ENV PARALLEL_TEST_PROCESSORS=4

RUN apk add --no-cache git bash alpine-sdk

# Cache gems
COPY Gemfile .
RUN bundle install --without system_tests development release --path=${BUNDLE_PATH:-vendor/bundle}

COPY . .

RUN bundle exec rake rubocop
RUN bundle exec rake test
RUN bundle exec rake test_with_coveralls
