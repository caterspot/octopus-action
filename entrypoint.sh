#!/bin/sh -l

set -e

echo "Setup variables ..."

APP=$1
AWS_KEY=$2
AWS_SECRET=$3
GITHUB_KEY=$4
ENVIRONMENT=$5
BASTION_USER=$6
BASTION_HOST=$7
OCTOPUS_REPO=$8

echo "Setting up ssh ..."

if [ ! -d /root/.ssh/ ]; then
   mkdir -p /root/.ssh/
fi

echo '' > /root/.ssh/known_hosts

ssh-keygen -R github.com
ssh-keyscan -H github.com >> /root/.ssh/known_hosts

echo "${GITHUB_KEY}" > /root/.ssh/id_rsa
chmod 0500 /root/.ssh/id_rsa

echo "Setting up ssh agent ..."

eval `ssh-agent -s`
ssh-add /root/.ssh/id_rsa

echo "Cloning Octopus ... "
git clone -b master --single-branch ${OCTOPUS_REPO} octopus
cd octopus

echo "Bundle install ..."

# Needed for openssh
bundle add ed25519
bundle add bcrypt_pbkdf
bundle install
echo "Deploying ..."

OPTS=""
if [ ! -z "$APP" ]; then
    OPTS=${OPTS}${OPTS:+ }APP=${APP}
fi
if [ ! -z "$BASTION_USER" ]; then
    OPTS=${OPTS}${OPTS:+ }"VIA_BASTION=1 BASTION_USER=${BASTION_USER} BASTION_HOST=${BASTION_HOST}"
fi
if [ ! -z "$AWS_KEY" ]; then
    OPTS=${OPTS}${OPTS:+ }"AWS_ACCESS_KEY_ID=${AWS_KEY} AWS_SECRET_ACCESS_KEY=${AWS_SECRET}"
fi

echo "bundle exec cap ${ENVIRONMENT} deploy $OPTS ..."
bundle exec cap ${ENVIRONMENT} deploy $OPTS

echo "bundle exec cap ${ENVIRONMENT} asg:scale $OPTS ..."
bundle exec cap ${ENVIRONMENT} asg:scale $OPTS

echo 'ok'
