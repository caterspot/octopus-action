#!/bin/sh

set -e

echo "Setup variables ..."

APP=$1
AWS_ACCESS_KEY_ID=$2
AWS_SECRET_ACCESS_KEY=$3
AWS_ACCOUNT=$4
AWS_DEFAULT_REGION=$5
GITHUB_KEY=$6
ENVIRONMENT=$7
VERSION=$8
INFRA_REPO=$9

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

echo "Cloning Infra ... "
git clone -b master --single-branch ${INFRA_REPO} caterspot_infra
cd caterspot_infra/cdk/caterspot

echo "Installing dependencies ..."
yarn install

echo "Deploying ${APP} to ${ENVIRONMENT} ..."
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

if [ "${APP}" = "project_tracker" ]; then
  # scripts/cdk-to-${ENVIRONMENT}.sh deploy --exclusively ProjectTrackerServiceStack --parameters ProjectTrackerServiceStack:ImageVersion=${VERSION}
  # scripts/cdk-to-${ENVIRONMENT}.sh deploy --exclusively SidekiqServiceStack --parameters SidekiqServiceStack:ImageVersion=${VERSION}
  scripts/cdk-to-staging.sh deploy --exclusively ProjectTrackerServiceStack --parameters ProjectTrackerServiceStack:ImageVersion=${VERSION}
  scripts/cdk-to-staging.sh deploy --exclusively SidekiqServiceStack --parameters SidekiqServiceStack:ImageVersion=${VERSION}
fi

echo 'ok'
