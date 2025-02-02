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

# Endpoint to delete the pipeline
DELETE_URL="${JENKINS_URL}/job/${JENKINS_APP_NAME}/doDelete"

# Log the request details (but without sensitive information)
log "Preparing to send DELETE request to Jenkins for job '${JENKINS_APP_NAME}'."
log "Request details:"
log "  URL: $DELETE_URL"
log "  Method: POST"

# Send the DELETE request to Jenkins
log "Sending DELETE request..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$DELETE_URL" \
  -u "${JENKINS_USER}:${JENKINS_API_TOKEN}"
)

# Check response code and log the result
if [[ "$RESPONSE" -eq 302 ]]; then
    log "Pipeline '${JENKINS_APP_NAME}' deleted successfully!"
else
    log "Failed to delete pipeline. HTTP Response Code: $RESPONSE"
    log "Ensure the job exists and that Jenkins URL, username, API token, and job name are correct."
fi
