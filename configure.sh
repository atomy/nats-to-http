#!/usr/bin/env bash

# Enable strict error handling
set -euo pipefail

# Define an associative array with environment variable names and their placeholders
declare -A env_var_placeholders=(
  ["ECR_REPO"]="%ECR_REPO%"
  ["DEPLOY_FULLPATH"]="%DEPLOY_FULLPATH%"
  ["SSH_DEPLOY_HOST"]="%SSH_DEPLOY_HOST%"
  ["APP_NAME"]="%APP_NAME%"
  ["DISCORD_WEBHOOK_URL"]="%DISCORD_WEBHOOK_URL%"
  ["FORWARD_HTTP_URL"]="%FORWARD_HTTP_URL%"
  ["NATS_SERVER"]="%NATS_SERVER%"
  ["NATS_TOPIC"]="%NATS_TOPIC%"
  ["GITHUB_PROJECT_URL"]="%GITHUB_PROJECT_URL%"
  ["GITHUB_PROJECT_URL_SSH"]="%GITHUB_PROJECT_URL_SSH%"
  ["JENKINS_APP_NAME"]="%JENKINS_APP_NAME%"
  ["JENKINS_SECRET_DEPLOYHOST_NAME"]="%JENKINS_SECRET_DEPLOYHOST_NAME%"
)

# Validate environment variables
for var in "${!env_var_placeholders[@]}"; do
  if [ -z "${!var}" ]; then
    echo "ENV: $var is missing!"
    exit 1
  fi
done

rm -f scripts/build.sh
rm -f scripts/push.sh
rm -f scripts/deploy.sh
rm -f docker-compose.yml
rm -f Jenkinsfile
rm -f jenkins-config.xml

# Function to replace placeholders with actual values
replace_placeholders() {
  local file=$1

  for var in "${!env_var_placeholders[@]}"; do
    local placeholder="${env_var_placeholders[$var]}"
    sed -i "s|$placeholder|${!var}|g" "$file"
  done
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

# Process jenkins-config.xml.dist if it exists in the same folder as this script
if [ -e "../jenkins-config.xml.dist" ]; then
  cp ../jenkins-config.xml.dist ../jenkins-config.xml

  replace_placeholders "../jenkins-config.xml"

  echo "Configured jenkins-config.xml.dist -> jenkins-config.xml"
fi

# Process Jenkinsfile.dist if it exists in the same folder as this script
if [ -e "../Jenkinsfile.dist" ]; then
  cp ../Jenkinsfile.dist ../Jenkinsfile

  replace_placeholders "../Jenkinsfile.dist"

  echo "Configured Jenkinsfile.dist -> Jenkinsfile"
fi
