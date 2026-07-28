# Container image that runs your code
#
# Switched from ruby:3.1.4-alpine (musl libc) to -slim (Debian/glibc) so the
# official AWS CLI + session-manager-plugin packages install and run without
# needing glibc compatibility shims - needed for the SSM bastion tunnel path.
FROM ruby:3.1.4-slim

# Version Pin
ENV RUBY_BUNDLER_VERSION=2.4.10

LABEL maintainer "Taufek Johar<taufek@caterspot.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git openssh-client build-essential libxml2-dev curl unzip ca-certificates \
  && curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip \
  && unzip -q awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws \
  && curl -sS "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o session-manager-plugin.deb \
  && dpkg -i session-manager-plugin.deb && rm session-manager-plugin.deb \
  && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v $RUBY_BUNDLER_VERSION

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
