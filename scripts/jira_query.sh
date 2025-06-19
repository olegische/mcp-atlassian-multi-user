#!/bin/bash

# Check if JIRA_API_TOKEN and JIRA_USERNAME are set
if [ -z "$JIRA_API_TOKEN" ]; then
  echo "Error: JIRA_API_TOKEN environment variable is not set"
  exit 1
fi

if [ -z "$JIRA_USERNAME" ]; then
  echo "Error: JIRA_USERNAME environment variable is not set"
  exit 1
fi

# Execute the Jira API query
curl -s -X GET "https://xrouter.atlassian.net/rest/api/2/search?jql=project%20%3D%20XROUT%20AND%20assignee%20%3D%20currentUser()" \
  --user "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
  -H "Content-Type: application/json" | jq
