#!/bin/bash

# Load environment variables from .env
set -a
source .env
set +a

# URL encode function for tokens (handles = and other special chars)
urlencode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1', safe=''))"
}

# URL encode the tokens to handle special characters like =
ENCODED_JIRA_TOKEN=$(urlencode "${HTTP_HEADER_JIRA_API_TOKEN}")
ENCODED_CONFLUENCE_TOKEN=$(urlencode "${HTTP_HEADER_CONFLUENCE_API_TOKEN}")

echo "Starting MCP server with custom headers..."
echo "JIRA URL: ${HTTP_HEADER_JIRA_URL}"
echo "JIRA Username: ${HTTP_HEADER_JIRA_USERNAME}"
echo "JIRA Token (encoded): ${ENCODED_JIRA_TOKEN:0:20}..."
echo "CONFLUENCE URL: ${HTTP_HEADER_CONFLUENCE_URL}"
echo "CONFLUENCE Username: ${HTTP_HEADER_CONFLUENCE_USERNAME}"
echo "CONFLUENCE Token (encoded): ${ENCODED_CONFLUENCE_TOKEN:0:20}..."

uvx mcpo --port 8600 --server-type "sse" \
    --header "{
        \"X-JIRA-URL\": \"${HTTP_HEADER_JIRA_URL}\",
        \"X-JIRA-USERNAME\": \"${HTTP_HEADER_JIRA_USERNAME}\",
        \"X-JIRA-API-TOKEN\": \"${ENCODED_JIRA_TOKEN}\",
        \"X-CONFLUENCE-URL\": \"${HTTP_HEADER_CONFLUENCE_URL}\",
        \"X-CONFLUENCE-USERNAME\": \"${HTTP_HEADER_CONFLUENCE_USERNAME}\",
        \"X-CONFLUENCE-API-TOKEN\": \"${ENCODED_CONFLUENCE_TOKEN}\"
    }" \
    -- http://localhost:${PORT}/sse
