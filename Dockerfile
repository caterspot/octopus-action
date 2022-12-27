# Container image that runs your code
FROM ruby:2.7.5
LABEL maintainer "Faizal Zakaria<faizal@caterspot.com>"

RUN apk add --no-cache git openssh build-base

RUN gem install bundler

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
