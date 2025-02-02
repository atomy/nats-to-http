#!/usr/bin/env bash

set -e

if [ -z "${ECR_REPO}" ] ; then
  echo "ENV: ECR_REPO is missing!"
  exit 1
fi

if [ -z "${APP_NAME}" ] ; then
  echo "ENV: APP_NAME is missing!"
  exit 1
fi

if [ -z "${SSH_DEPLOY_HOST}" ] ; then
  echo "ENV: SSH_DEPLOY_HOST is missing!"
  exit 1
fi

if [ -z "${DEPLOY_FULLPATH}" ] ; then
  echo "ENV: DEPLOY_FULLPATH is missing!"
  exit 1
fi

if [ -z "${FORWARD_HTTP_URL}" ] ; then
  echo "ENV: FORWARD_HTTP_URL is missing!"
  exit 1
fi

if [ -z "${NATS_SERVER}" ] ; then
  echo "ENV: NATS_SERVER is missing!"
  exit 1
fi

if [ -z "${NATS_TOPIC}" ] ; then
  echo "ENV: NATS_TOPIC is missing!"
  exit 1
fi

if [ -z "${DISCORD_WEBHOOK_URL}" ] ; then
  echo "ENV: DISCORD_WEBHOOK_URL is missing!"
  exit 1
fi

rm -f scripts/build.sh
rm -f scripts/push.sh
rm -f scripts/deploy.sh
rm -f docker-compose.yml

replace_placeholders() {
  local file=$1

  sed -i "s|%ECR_REPO%|${ECR_REPO}|g" "$file"
  sed -i "s|%DEPLOY_FULLPATH%|${DEPLOY_FULLPATH}|g" "$file"
  sed -i "s|%SSH_DEPLOY_HOST%|${SSH_DEPLOY_HOST}|g" "$file"
  sed -i "s|%APP_NAME%|${APP_NAME}|g" "$file"
  sed -i "s|%DISCORD_WEBHOOK_URL%|${DISCORD_WEBHOOK_URL}|g" "$file"
  sed -i "s|%FORWARD_HTTP_URL%|${FORWARD_HTTP_URL}|g" "$file"
  sed -i "s|%NATS_SERVER%|${NATS_SERVER}|g" "$file"
  sed -i "s|%NATS_TOPIC%|${NATS_TOPIC}|g" "$file"
}

cd scripts/

# Loop through all .dist files in the specified directory
for dist_file in *.dist; do
  # Skip if no files match the pattern
  if [ ! -e "$dist_file" ]; then
    echo "No .dist files found in ${pwd}"
    exit 0
  fi

  # Determine the new filename by removing the .dist extension
  new_file="${dist_file%.dist}"

  # Copy the .dist file to the new filename
  cp "$dist_file" "$new_file"

  # Replace placeholders with the respective environment variable values
  replace_placeholders "$new_file"

  echo "Configured file $dist_file -> $new_file"
done

# Process docker-compose.yml.dist if it exists in the same folder as this script
if [ -e "../docker-compose.yml.dist" ]; then
  cp ../docker-compose.yml.dist ../docker-compose.yml

  replace_placeholders "../docker-compose.yml"

  echo "Configured docker-compose.yml.dist -> docker-compose.yml"
fi
