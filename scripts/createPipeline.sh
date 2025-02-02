#!/bin/bash

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Validate required environment variables
log "Validating environment variables..."
REQUIRED_VARS=("JENKINS_URL" "JENKINS_USER" "JENKINS_API_TOKEN" "JENKINS_APP_NAME")

for VAR in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!VAR}" ]]; then
        log "Error: Environment variable '$VAR' is not set."
        exit 1
    fi
done

# Use jenkins-config.xml as the configuration file
CONFIG_FILE="jenkins-config.xml"

# Validate the existence of the configuration file
if [[ ! -f "$CONFIG_FILE" ]]; then
    log "Error: Configuration file '$CONFIG_FILE' not found!"
    exit 1
fi

# Log that we found the configuration file
log "Configuration file '$CONFIG_FILE' found. Proceeding with the request."

# Read the configuration file content (but don't output it in the logs)
CONFIG_XML=$(<"$CONFIG_FILE")

# Endpoint to create the pipeline
CREATE_URL="${JENKINS_URL}/createItem?name=${JENKINS_APP_NAME}"

# Log the request details (excluding sensitive data)
log "Preparing to send POST request to Jenkins for creating job '${JENKINS_APP_NAME}'."
log "Request details:"
log "  URL: $CREATE_URL"
log "  Method: POST"
log "  Configuration File: jenkins-config.xml (content hidden for security)"

# Send request to Jenkins API to create the pipeline
log "Sending POST request..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$CREATE_URL" \
  -u "${JENKINS_USER}:${JENKINS_API_TOKEN}" \
  -H "Content-Type: application/xml" \
  --data "$CONFIG_XML"
)

# Check response code and log the result
if [[ "$RESPONSE" -eq 200 ]]; then
    log "Pipeline '${JENKINS_APP_NAME}' created successfully!"
else
    log "Failed to create pipeline. HTTP Response Code: $RESPONSE"
    log "Ensure Jenkins URL, username, API token, and job name are correct."
fi
