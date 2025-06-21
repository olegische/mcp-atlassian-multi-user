# MCP Atlassian Multi User

![PyPI Version](https://img.shields.io/pypi/v/mcp-atlassian)
![PyPI - Downloads](https://img.shields.io/pypi/dm/mcp-atlassian)
![PePy - Total Downloads](https://static.pepy.tech/personalized-badge/mcp-atlassian?period=total&units=international_system&left_color=grey&right_color=blue&left_text=Total%20Downloads)
[![Run Tests](https://github.com/sooperset/mcp-atlassian/actions/workflows/tests.yml/badge.svg)](https://github.com/sooperset/mcp-atlassian/actions/workflows/tests.yml)
![License](https://img.shields.io/github/license/sooperset/mcp-atlassian)

Model Context Protocol (MCP) server for Atlassian products (Confluence and Jira). This integration supports both Confluence & Jira Cloud and Server/Data Center deployments.

## Example Usage

Ask your AI assistant to:

- **📝 Automatic Jira Updates** - "Update Jira from our meeting notes"
- **🔍 AI-Powered Confluence Search** - "Find our OKR guide in Confluence and summarize it"
- **🐛 Smart Jira Issue Filtering** - "Show me urgent bugs in PROJ project from last week"
- **📄 Content Creation & Management** - "Create a tech design doc for XYZ feature"

### Feature Demo

https://github.com/user-attachments/assets/35303504-14c6-4ae4-913b-7c25ea511c3e

<details> <summary>Confluence Demo</summary>

https://github.com/user-attachments/assets/7fe9c488-ad0c-4876-9b54-120b666bb785

</details>

### Compatibility

| Product        | Deployment Type    | Support Status              |
|----------------|--------------------|-----------------------------|
| **Confluence** | Cloud              | ✅ Fully supported           |
| **Confluence** | Server/Data Center | ✅ Supported (version 6.0+)  |
| **Jira**       | Cloud              | ✅ Fully supported           |
| **Jira**       | Server/Data Center | ✅ Supported (version 8.14+) |

## Quick Start Guide

### 🔐 1. Authentication Setup

MCP Atlassian supports three authentication methods:

#### A. API Token Authentication (Cloud) - **Recommended**

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click **Create API token**, name it
3. Copy the token immediately

#### B. Personal Access Token (Server/Data Center)

1. Go to your profile (avatar) → **Profile** → **Personal Access Tokens**
2. Click **Create token**, name it, set expiry
3. Copy the token immediately

#### C. OAuth 2.0 Authentication (Cloud) - **Advanced**

> [!NOTE]
> OAuth 2.0 is more complex to set up but provides enhanced security features. For most users, API Token authentication (Method A) is simpler and sufficient.

1. Go to [Atlassian Developer Console](https://developer.atlassian.com/console/myapps/)
2. Create an "OAuth 2.0 (3LO) integration" app
3. Configure **Permissions** (scopes) for Jira/Confluence
4. Set **Callback URL** (e.g., `http://localhost:8080/callback`)
5. Run setup wizard:
   ```bash
   docker run --rm -i \
     -p 8080:8080 \
     -v "${HOME}/.mcp-atlassian:/home/app/.mcp-atlassian" \
     olegische/mcp-atlassian-multi-user:latest --oauth-setup -v
   ```
6. Follow prompts for `Client ID`, `Secret`, `URI`, and `Scope`
7. Complete browser authorization
8. Add obtained credentials to `.env` or IDE config:
   - `ATLASSIAN_OAUTH_CLOUD_ID` (from wizard)
   - `ATLASSIAN_OAUTH_CLIENT_ID`
   - `ATLASSIAN_OAUTH_CLIENT_SECRET`
   - `ATLASSIAN_OAUTH_REDIRECT_URI`
   - `ATLASSIAN_OAUTH_SCOPE`

> [!IMPORTANT]
> Include `offline_access` in scope for persistent auth (e.g., `read:jira-work write:jira-work offline_access`)

### 🚀 2. Installation & Deployment

MCP Atlassian can be deployed in several ways depending on your infrastructure and requirements:

#### A. Direct Installation with uvx

The simplest way to run MCP Atlassian directly:

```bash
# Install and run with uvx
uvx mcp-atlassian --transport sse --port 8000 -vv
```

Environment variables should be configured in your shell or `.env` file before running.

#### B. Docker Deployment

##### Option 1: Environment Variables Configuration

Run the container with credentials passed as environment variables:

```bash
# Pull the image
docker pull olegische/mcp-atlassian-multi-user:latest

# Run with environment variables
docker run --rm -p 8000:8000 \
  -e JIRA_URL="https://your-company.atlassian.net" \
  -e JIRA_USERNAME="your.email@company.com" \
  -e JIRA_API_TOKEN="your_jira_api_token" \
  -e CONFLUENCE_URL="https://your-company.atlassian.net/wiki" \
  -e CONFLUENCE_USERNAME="your.email@company.com" \
  -e CONFLUENCE_API_TOKEN="your_confluence_api_token" \
  olegische/mcp-atlassian-multi-user:latest \
  --transport sse --port 8000 -vv
```

##### Option 2: Custom Headers Configuration

For cloud deployments where you don't want to embed credentials in the container, enable custom headers mode:

```bash
# Run with custom headers enabled
docker run --rm -p 8000:8000 \
  -e ENABLE_CUSTOM_HEADERS=true \
  olegische/mcp-atlassian-multi-user:latest \
  --transport sse --port 8000 -vv
```

Then pass credentials via HTTP headers when making requests:
- `X-JIRA-URL`: Your Jira instance URL
- `X-JIRA-USERNAME`: Your Jira username
- `X-JIRA-API-TOKEN`: Your Jira API token
- `X-CONFLUENCE-URL`: Your Confluence instance URL
- `X-CONFLUENCE-USERNAME`: Your Confluence username
- `X-CONFLUENCE-API-TOKEN`: Your Confluence API token

#### C. MCPO Proxy Deployment

Use MCPO (MCP Proxy) to run the server with custom headers. This approach is particularly useful for Server/Data Center deployments where you want to avoid embedding credentials in containers.

**Step 1: Start the MCP server container with custom headers enabled**

```bash
# Start the container with custom headers support
docker run --rm -p 8000:8000 \
  -e ENABLE_CUSTOM_HEADERS=true \
  olegische/mcp-atlassian-multi-user:latest \
  --transport sse --port 8000 -vv
```

**Step 2: Set up environment variables for MCPO headers**

```bash
# For Cloud deployments
export HTTP_HEADER_JIRA_URL="https://your-company.atlassian.net"
export HTTP_HEADER_JIRA_USERNAME="your.email@company.com"
export HTTP_HEADER_JIRA_API_TOKEN="your_jira_api_token"
export HTTP_HEADER_CONFLUENCE_URL="https://your-company.atlassian.net/wiki"
export HTTP_HEADER_CONFLUENCE_USERNAME="your.email@company.com"
export HTTP_HEADER_CONFLUENCE_API_TOKEN="your_confluence_api_token"

# For Server/Data Center deployments
export HTTP_HEADER_JIRA_URL="https://jira.your-company.com"
export HTTP_HEADER_JIRA_PERSONAL_TOKEN="your_jira_personal_token"
export HTTP_HEADER_CONFLUENCE_URL="https://confluence.your-company.com"
export HTTP_HEADER_CONFLUENCE_PERSONAL_TOKEN="your_confluence_personal_token"
```

**Step 3: Run MCPO proxy**

```bash
# For Cloud (with username/API token)
uvx mcpo --port 8600 --server-type "sse" \
    --header "{
        \"X-JIRA-URL\": \"${HTTP_HEADER_JIRA_URL}\",
        \"X-JIRA-USERNAME\": \"${HTTP_HEADER_JIRA_USERNAME}\",
        \"X-JIRA-API-TOKEN\": \"${HTTP_HEADER_JIRA_API_TOKEN}\",
        \"X-CONFLUENCE-URL\": \"${HTTP_HEADER_CONFLUENCE_URL}\",
        \"X-CONFLUENCE-USERNAME\": \"${HTTP_HEADER_CONFLUENCE_USERNAME}\",
        \"X-CONFLUENCE-API-TOKEN\": \"${HTTP_HEADER_CONFLUENCE_API_TOKEN}\"
    }" \
    -- http://localhost:8000/sse

# For Server/Data Center (with Personal Access Tokens)
uvx mcpo --port 8600 --server-type "sse" \
    --header "{
        \"X-JIRA-URL\": \"${HTTP_HEADER_JIRA_URL}\",
        \"X-JIRA-PERSONAL-TOKEN\": \"${HTTP_HEADER_JIRA_PERSONAL_TOKEN}\",
        \"X-CONFLUENCE-URL\": \"${HTTP_HEADER_CONFLUENCE_URL}\",
        \"X-CONFLUENCE-PERSONAL-TOKEN\": \"${HTTP_HEADER_CONFLUENCE_PERSONAL_TOKEN}\"
    }" \
    -- http://localhost:8000/sse
```

> [!NOTE]
> MCPO deployment is particularly useful for:
> - **Server/Data Center environments** where you want to avoid embedding user credentials in containers
> - **Multi-user scenarios** where different users have different credentials
> - **Corporate environments** where credentials need to be passed dynamically
> - **Proxy/middleware scenarios** where additional request processing is needed

## 🛠️ IDE Integration

MCP Atlassian is designed to be used with AI assistants through IDE integration.

> [!TIP]
> **For Claude Desktop**: Locate and edit the configuration file directly:
> - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
> - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
> - **Linux**: `~/.config/Claude/claude_desktop_config.json`
>
> **For Cursor**: Open Settings → MCP → + Add new global MCP server

### ⚙️ Configuration Methods

There are two main approaches to configure the Docker container:

1. **Passing Variables Directly** (shown in examples below)
2. **Using an Environment File** with `--env-file` flag (shown in collapsible sections)

> [!NOTE]
> Common environment variables include:
>
> - `CONFLUENCE_SPACES_FILTER`: Filter by space keys (e.g., "DEV,TEAM,DOC")
> - `JIRA_PROJECTS_FILTER`: Filter by project keys (e.g., "PROJ,DEV,SUPPORT")
> - `READ_ONLY_MODE`: Set to "true" to disable write operations
> - `MCP_VERBOSE`: Set to "true" for more detailed logging
> - `MCP_LOGGING_STDOUT`: Set to "true" to log to stdout instead of stderr
> - `ENABLED_TOOLS`: Comma-separated list of tool names to enable (e.g., "confluence_search,jira_get_issue")
>
> See the [.env.example](https://github.com/sooperset/mcp-atlassian/blob/main/.env.example) file for all available options.

### 📝 Configuration Examples

**Method 1 (Passing Variables Directly):**
```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e", "CONFLUENCE_URL",
        "-e", "CONFLUENCE_USERNAME",
        "-e", "CONFLUENCE_API_TOKEN",
        "-e", "JIRA_URL",
        "-e", "JIRA_USERNAME",
        "-e", "JIRA_API_TOKEN",
        "olegische/mcp-atlassian-multi-user:latest"
      ],
      "env": {
        "CONFLUENCE_URL": "https://your-company.atlassian.net/wiki",
        "CONFLUENCE_USERNAME": "your.email@company.com",
        "CONFLUENCE_API_TOKEN": "your_confluence_api_token",
        "JIRA_URL": "https://your-company.atlassian.net",
        "JIRA_USERNAME": "your.email@company.com",
        "JIRA_API_TOKEN": "your_jira_api_token"
      }
    }
  }
}
```

<details>
<summary>Alternative: Using Environment File</summary>

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--env-file",
        "/path/to/your/mcp-atlassian.env",
        "olegische/mcp-atlassian-multi-user:latest"
      ]
    }
  }
}
```
</details>

<details>
<summary>Server/Data Center Configuration</summary>

For Server/Data Center deployments, use direct variable passing:

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "CONFLUENCE_URL",
        "-e", "CONFLUENCE_PERSONAL_TOKEN",
        "-e", "CONFLUENCE_SSL_VERIFY",
        "-e", "JIRA_URL",
        "-e", "JIRA_PERSONAL_TOKEN",
        "-e", "JIRA_SSL_VERIFY",
        "olegische/mcp-atlassian-multi-user:latest"
      ],
      "env": {
        "CONFLUENCE_URL": "https://confluence.your-company.com",
        "CONFLUENCE_PERSONAL_TOKEN": "your_confluence_pat",
        "CONFLUENCE_SSL_VERIFY": "false",
        "JIRA_URL": "https://jira.your-company.com",
        "JIRA_PERSONAL_TOKEN": "your_jira_pat",
        "JIRA_SSL_VERIFY": "false"
      }
    }
  }
}
```

> [!NOTE]
> Set `CONFLUENCE_SSL_VERIFY` and `JIRA_SSL_VERIFY` to "false" only if you have self-signed certificates.

</details>

<details>
<summary>OAuth 2.0 Configuration (Cloud Only)</summary>
<a name="oauth-20-configuration-example-cloud-only"></a>

This example shows how to configure `mcp-atlassian` in your IDE (like Cursor or Claude Desktop) when using OAuth 2.0 for Atlassian Cloud. Ensure you have completed the [OAuth setup wizard](#c-oauth-20-authentication-cloud-only) first.

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v", "<path_to_your_home>/.mcp-atlassian:/home/app/.mcp-atlassian",
        "-e", "JIRA_URL",
        "-e", "CONFLUENCE_URL",
        "-e", "ATLASSIAN_OAUTH_CLIENT_ID",
        "-e", "ATLASSIAN_OAUTH_CLIENT_SECRET",
        "-e", "ATLASSIAN_OAUTH_REDIRECT_URI",
        "-e", "ATLASSIAN_OAUTH_SCOPE",
        "-e", "ATLASSIAN_OAUTH_CLOUD_ID",
        "olegische/mcp-atlassian-multi-user:latest",
      ],
      "env": {
        "JIRA_URL": "https://your-company.atlassian.net",
        "CONFLUENCE_URL": "https://your-company.atlassian.net/wiki",
        "ATLASSIAN_OAUTH_CLIENT_ID": "YOUR_OAUTH_APP_CLIENT_ID",
        "ATLASSIAN_OAUTH_CLIENT_SECRET": "YOUR_OAUTH_APP_CLIENT_SECRET",
        "ATLASSIAN_OAUTH_REDIRECT_URI": "http://localhost:8080/callback",
        "ATLASSIAN_OAUTH_SCOPE": "read:jira-work write:jira-work read:confluence-content.all write:confluence-content offline_access",
        "ATLASSIAN_OAUTH_CLOUD_ID": "YOUR_CLOUD_ID_FROM_SETUP_WIZARD"
      }
    }
  }
}
```

> [!NOTE]
> - `ATLASSIAN_OAUTH_CLOUD_ID` is obtained from the `--oauth-setup` wizard output.
> - Other `ATLASSIAN_OAUTH_*` variables are those you configured for your OAuth app in the Atlassian Developer Console (and used as input to the setup wizard).
> - `JIRA_URL` and `CONFLUENCE_URL` for your Cloud instances are still required.

</details>

<details>
<summary>Proxy Configuration</summary>

MCP Atlassian supports routing API requests through standard HTTP/HTTPS/SOCKS proxies. Configure using environment variables:

- Supports standard `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, `SOCKS_PROXY`.
- Service-specific overrides are available (e.g., `JIRA_HTTPS_PROXY`, `CONFLUENCE_NO_PROXY`).
- Service-specific variables override global ones for that service.

Add the relevant proxy variables to the `args` (using `-e`) and `env` sections of your MCP configuration:

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e", "... existing Confluence/Jira vars",
        "-e", "HTTP_PROXY",
        "-e", "HTTPS_PROXY",
        "-e", "NO_PROXY",
        "olegische/mcp-atlassian-multi-user:latest"
      ],
      "env": {
        "... existing Confluence/Jira vars": "...",
        "HTTP_PROXY": "http://proxy.internal:8080",
        "HTTPS_PROXY": "http://proxy.internal:8080",
        "NO_PROXY": "localhost,.your-company.com"
      }
    }
  }
}
```

Credentials in proxy URLs are masked in logs. If you set `NO_PROXY`, it will be respected for requests to matching hosts.

</details>

<details> <summary>Single Service Configurations</summary>

**For Confluence Cloud only:**

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "CONFLUENCE_URL",
        "-e", "CONFLUENCE_USERNAME",
        "-e", "CONFLUENCE_API_TOKEN",
        "olegische/mcp-atlassian-multi-user:latest"
      ],
      "env": {
        "CONFLUENCE_URL": "https://your-company.atlassian.net/wiki",
        "CONFLUENCE_USERNAME": "your.email@company.com",
        "CONFLUENCE_API_TOKEN": "your_api_token"
      }
    }
  }
}
```

For Confluence Server/DC, use:
```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "CONFLUENCE_URL",
        "-e", "CONFLUENCE_PERSONAL_TOKEN",
        "olegische/mcp-atlassian-multi-user:latest"
      ],
      "env": {
        "CONFLUENCE_URL": "https://confluence.your-company.com",
        "CONFLUENCE_PERSONAL_TOKEN": "your_personal_token"
      }
    }
  }
}
```

**For Jira Cloud only:**

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "JIRA_URL",
        "-e", "JIRA_USERNAME",
        "-e", "JIRA_API_TOKEN",
        "olegische/mcp-atlassian-multi-user:latest"
      ],
      "env": {
        "JIRA_URL": "https://your-company.atlassian.net",
        "JIRA_USERNAME": "your.email@company.com",
        "JIRA_API_TOKEN": "your_api_token"
      }
    }
  }
}
```

For Jira Server/DC, use:
```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "JIRA_URL",
        "-e", "JIRA_PERSONAL_TOKEN",
        "olegische/mcp-atlassian-multi-user:latest"
      ],
      "env": {
        "JIRA_URL": "https://jira.your-company.com",
        "JIRA_PERSONAL_TOKEN": "your_personal_token"
      }
    }
  }
}
```

</details>

### 👥 HTTP Transport Configuration

Instead of using `stdio`, you can run the server as a persistent HTTP service using either:
- `sse` (Server-Sent Events) transport at `/sse` endpoint
- `streamable-http` transport at `/mcp` endpoint

Both transport types support single-user and multi-user authentication:

**Authentication Options:**
- **Single-User**: Use server-level authentication configured via environment variables
- **Multi-User**: Each user provides their own authentication:
  - Cloud: OAuth 2.0 Bearer tokens
  - Server/Data Center: Personal Access Tokens (PATs)

**Custom Headers Support:**
- You can pass configuration parameters via custom headers when using HTTP transport
- Enable with `ENABLE_CUSTOM_HEADERS=true` environment variable
- Headers follow the pattern `X-JIRA-*` and `X-CONFLUENCE-*`, for example:
  - `X-JIRA-URL`: Override Jira URL
  - `X-JIRA-PERSONAL-TOKEN`: Pass Jira Personal Access Token
  - `X-CONFLUENCE-URL`: Override Confluence URL
  - `X-CONFLUENCE-PERSONAL-TOKEN`: Pass Confluence Personal Access Token

<details> <summary>Basic HTTP Transport Setup</summary>

1. Start the server with your chosen transport:

    ```bash
    # For SSE transport
    docker run --rm -p 9000:9000 \
      --env-file /path/to/your/.env \
      olegische/mcp-atlassian-multi-user:latest \
      --transport sse --port 9000 -vv

    # OR for streamable-http transport
    docker run --rm -p 9000:9000 \
      --env-file /path/to/your/.env \
      olegische/mcp-atlassian-multi-user:latest \
      --transport streamable-http --port 9000 -vv
    ```

2. Configure your IDE (single-user example):

    **SSE Transport Example:**
    ```json
    {
      "mcpServers": {
        "mcp-atlassian-http": {
          "url": "http://localhost:9000/sse"
        }
      }
    }
    ```

    **Streamable-HTTP Transport Example:**
    ```json
    {
      "mcpServers": {
        "mcp-atlassian-service": {
          "url": "http://localhost:9000/mcp"
        }
      }
    }
    ```
</details>

<details> <summary>Multi-User Authentication Setup</summary>

Here's a complete example of setting up multi-user authentication with streamable-HTTP transport:

1. First, run the OAuth setup wizard to configure the server's OAuth credentials:
   ```bash
   docker run --rm -i \
     -p 8080:8080 \
     -v "${HOME}/.mcp-atlassian:/home/app/.mcp-atlassian" \
     olegische/mcp-atlassian-multi-user:latest --oauth-setup -v
   ```

2. Start the server with streamable-HTTP transport:
   ```bash
   docker run --rm -p 9000:9000 \
     --env-file /path/to/your/.env \
     olegische/mcp-atlassian-multi-user:latest \
     --transport streamable-http --port 9000 -vv
   ```

3. Configure your IDE's MCP settings:

**Choose the appropriate Authorization method for your Atlassian deployment:**

- **Cloud (OAuth 2.0):** Use this if your organization is on Atlassian Cloud and you have an OAuth access token for each user.
- **Server/Data Center (PAT):** Use this if you are on Atlassian Server or Data Center and each user has a Personal Access Token (PAT).

**Cloud (OAuth 2.0) Example:**
```json
{
  "mcpServers": {
    "mcp-atlassian-service": {
      "url": "http://localhost:9000/mcp",
      "headers": {
        "Authorization": "Bearer <USER_OAUTH_ACCESS_TOKEN>"
      }
    }
  }
}
```

**Server/Data Center (PAT) Example:**
```json
{
  "mcpServers": {
    "mcp-atlassian-service": {
      "url": "http://localhost:9000/mcp",
      "headers": {
        "Authorization": "Token <USER_PERSONAL_ACCESS_TOKEN>"
      }
    }
  }
}
```

4. Required environment variables in `.env`:
   ```bash
   JIRA_URL=https://your-company.atlassian.net
   CONFLUENCE_URL=https://your-company.atlassian.net/wiki
   ATLASSIAN_OAUTH_CLIENT_ID=your_oauth_app_client_id
   ATLASSIAN_OAUTH_CLIENT_SECRET=your_oauth_app_client_secret
   ATLASSIAN_OAUTH_REDIRECT_URI=http://localhost:8080/callback
   ATLASSIAN_OAUTH_SCOPE=read:jira-work write:jira-work read:confluence-content.all write:confluence-content offline_access
   ATLASSIAN_OAUTH_CLOUD_ID=your_cloud_id_from_setup_wizard
   ```

> [!NOTE]
> - The server should have its own fallback authentication configured (e.g., via environment variables for API token, PAT, or its own OAuth setup using --oauth-setup). This is used if a request doesn't include user-specific authentication.
> - **OAuth**: Each user needs their own OAuth access token from your Atlassian OAuth app.
> - **PAT**: Each user provides their own Personal Access Token.
> - The server will use the user's token for API calls when provided, falling back to server auth if not
> - User tokens should have appropriate scopes for their needed operations

</details>

## Tools

### Key Tools

#### Jira Tools

- `jira_get_issue`: Get details of a specific issue
- `jira_search`: Search issues using JQL
- `jira_create_issue`: Create a new issue
- `jira_update_issue`: Update an existing issue
- `jira_transition_issue`: Transition an issue to a new status
- `jira_add_comment`: Add a comment to an issue

#### Confluence Tools

- `confluence_search`: Search Confluence content using CQL
- `confluence_get_page`: Get content of a specific page
- `confluence_create_page`: Create a new page
- `confluence_update_page`: Update an existing page

<details> <summary>View All Tools</summary>

| Operation | Jira Tools                          | Confluence Tools               |
|-----------|-------------------------------------|--------------------------------|
| **Read**  | `jira_search`                       | `confluence_search`            |
|           | `jira_get_issue`                    | `confluence_get_page`          |
|           | `jira_get_all_projects`             | `confluence_get_page_children` |
|           | `jira_get_project_issues`           | `confluence_get_comments`      |
|           | `jira_get_worklog`                  | `confluence_get_labels`        |
|           | `jira_get_transitions`              | `confluence_search_user`       |
|           | `jira_search_fields`                |                                |
|           | `jira_get_agile_boards`             |                                |
|           | `jira_get_board_issues`             |                                |
|           | `jira_get_sprints_from_board`       |                                |
|           | `jira_get_sprint_issues`            |                                |
|           | `jira_get_issue_link_types`         |                                |
|           | `jira_batch_get_changelogs`*        |                                |
|           | `jira_get_user_profile`             |                                |
|           | `jira_download_attachments`         |                                |
|           | `jira_get_project_versions`         |                                |
| **Write** | `jira_create_issue`                 | `confluence_create_page`       |
|           | `jira_update_issue`                 | `confluence_update_page`       |
|           | `jira_delete_issue`                 | `confluence_delete_page`       |
|           | `jira_batch_create_issues`          | `confluence_add_label`         |
|           | `jira_add_comment`                  | `confluence_add_comment`       |
|           | `jira_transition_issue`             |                                |
|           | `jira_add_worklog`                  |                                |
|           | `jira_link_to_epic`                 |                                |
|           | `jira_create_sprint`                |                                |
|           | `jira_update_sprint`                |                                |
|           | `jira_create_issue_link`            |                                |
|           | `jira_remove_issue_link`            |                                |
|           | `jira_create_version`               |                                |
|           | `jira_batch_create_versions`        |                                |

</details>

*Tool only available on Jira Cloud

### Tool Filtering and Access Control

The server provides two ways to control tool access:

1. **Tool Filtering**: Use `--enabled-tools` flag or `ENABLED_TOOLS` environment variable to specify which tools should be available:

   ```bash
   # Via environment variable
   ENABLED_TOOLS="confluence_search,jira_get_issue,jira_search"

   # Or via command line flag
   docker run ... --enabled-tools "confluence_search,jira_get_issue,jira_search" ...
   ```

2. **Read/Write Control**: Tools are categorized as read or write operations. When `READ_ONLY_MODE` is enabled, only read operations are available regardless of `ENABLED_TOOLS` setting.

## Troubleshooting & Debugging

### Common Issues

- **Authentication Failures**:
    - For Cloud: Check your API tokens (not your account password)
    - For Server/Data Center: Verify your personal access token is valid and not expired
    - For older Confluence servers: Some older versions require basic authentication with `CONFLUENCE_USERNAME` and `CONFLUENCE_API_TOKEN` (where token is your password)
- **SSL Certificate Issues**: If using Server/Data Center and encounter SSL errors, set `CONFLUENCE_SSL_VERIFY=false` or `JIRA_SSL_VERIFY=false`
- **Permission Errors**: Ensure your Atlassian account has sufficient permissions to access the spaces/projects

### Debugging Tools

```bash
# Using MCP Inspector for testing
npx @modelcontextprotocol/inspector uvx mcp-atlassian ...

# For local development version
npx @modelcontextprotocol/inspector uv --directory /path/to/your/mcp-atlassian run mcp-atlassian ...

# View logs
# macOS
tail -n 20 -f ~/Library/Logs/Claude/mcp*.log
# Windows
type %APPDATA%\Claude\logs\mcp*.log | more
```

## Security

- Never share API tokens
- Keep .env files secure and private
- See [SECURITY.md](SECURITY.md) for best practices

## Contributing

We welcome contributions to MCP Atlassian! If you'd like to contribute:

1. Check out our [CONTRIBUTING.md](CONTRIBUTING.md) guide for detailed development setup instructions.
2. Make changes and submit a pull request.

We use pre-commit hooks for code quality and follow semantic versioning for releases.

## License

Licensed under MIT - see [LICENSE](LICENSE) file. This is not an official Atlassian product.
