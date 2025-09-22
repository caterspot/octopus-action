# Container image that runs your code
FROM ruby:3.1.4-alpine

# Version Pin
ENV RUBY_BUNDLER_VERSION=2.4.10

LABEL maintainer "Taufek Johar<taufek@caterspot.com>"

RUN apk add --no-cache git openssh build-base \
  build-base libxml2-dev

RUN gem install bundler -v $RUBY_BUNDLER_VERSION

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
