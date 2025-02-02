#!/usr/bin/env bash

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Validate required environment variables
REQUIRED_VARS=("JENKINS_URL" "JENKINS_USER" "JENKINS_API_TOKEN" "JENKINS_SECRET_DEPLOYHOST_NAME" "DEPLOY_FULLPATH")

for VAR in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!VAR}" ]]; then
        log "Error: Environment variable '$VAR' is not set."
        exit 1
    fi
done

# Set the API endpoint for creating the credential
CREATE_CREDENTIALS_URL="${JENKINS_URL}/credentials/store/system/domain/_/createCredentials"

# JSON payload for StringCredentialsImpl
JSON_PAYLOAD=$(cat <<EOF
{
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "${JENKINS_SECRET_DEPLOYHOST_NAME}",
    "secret": "${DEPLOY_FULLPATH}",
    "description": "String credential created via JSON",
    "\$class": "org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl"
  }
}
EOF
)

# Log request details
log "Preparing to create a Jenkins String credential."
log "Request details:"
log "  URL: ${CREATE_CREDENTIALS_URL}"
log "  Method: POST"
log "  Payload: JSON (content hidden for security)"

# Send the POST request using data-urlencode
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "$CREATE_CREDENTIALS_URL" \
  -u "${JENKINS_USER}:${JENKINS_API_TOKEN}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "json=${JSON_PAYLOAD}"
)

# Split response into body and status code
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)

# Check response code and log the result
if [[ "$HTTP_CODE" -eq 302 ]]; then
    log "Jenkins String credential '${JENKINS_SECRET_DEPLOYHOST_NAME}' created successfully!"
else
    log "Failed to create Jenkins secret. HTTP Response Code: $HTTP_CODE"
    log "Response Body: $RESPONSE_BODY"
    log "Ensure Jenkins URL, username, API token, and credentials are correct."
fi
