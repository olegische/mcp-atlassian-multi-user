#!/bin/bash

# Load environment variables from .env
set -a
source .env
set +a

echo "Starting MCP server with custom headers (NO URL ENCODING)..."
echo "JIRA URL: ${HTTP_HEADER_JIRA_URL}"
echo "JIRA Username: ${HTTP_HEADER_JIRA_USERNAME}"
echo "JIRA Token: ${HTTP_HEADER_JIRA_API_TOKEN:0:20}..."
echo "CONFLUENCE URL: ${HTTP_HEADER_CONFLUENCE_URL}"
echo "CONFLUENCE Username: ${HTTP_HEADER_CONFLUENCE_USERNAME}"
echo "CONFLUENCE Token: ${HTTP_HEADER_CONFLUENCE_API_TOKEN:0:20}..."

uvx mcpo --port 8600 --server-type "sse" \
    --header "{
        \"X-JIRA-URL\": \"${HTTP_HEADER_JIRA_URL}\",
        \"X-JIRA-USERNAME\": \"${HTTP_HEADER_JIRA_USERNAME}\",
        \"X-JIRA-API-TOKEN\": \"${HTTP_HEADER_JIRA_API_TOKEN}\",
        \"X-CONFLUENCE-URL\": \"${HTTP_HEADER_CONFLUENCE_URL}\",
        \"X-CONFLUENCE-USERNAME\": \"${HTTP_HEADER_CONFLUENCE_USERNAME}\",
        \"X-CONFLUENCE-API-TOKEN\": \"${HTTP_HEADER_CONFLUENCE_API_TOKEN}\"
    }" \
    -- http://localhost:${PORT}/sse
