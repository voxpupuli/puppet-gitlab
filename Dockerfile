FROM ruby:2.1-alpine
MAINTAINER Tobias Brunner <tobias.brunner@vshn.ch>

ENV PUPPET_VERSION "~> 3.8.0"
RUN apk add --no-cache git bash alpine-sdk && \
    adduser -S puppet && \
    mkdir /home/puppet/gitlab && \
    chown -R puppet /home/puppet

WORKDIR /home/puppet/gitlab
COPY Gemfile /home/puppet/gitlab

#USER puppet
RUN bundle install --without development system_tests
