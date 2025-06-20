# MCP Atlassian Installation Guide for LLMs

This guide will help you install and configure the MCP Atlassian server for managing Jira and Confluence operations through Claude Desktop and other AI assistants.

## Requirements

- Docker installed on your system (for options 2-4)
- Python 3.8+ and uv installed (for option 1)
- Access to Atlassian Cloud or Server/Data Center instance
- Valid Atlassian credentials (API tokens or Personal Access Tokens)
- Web browser for OAuth authentication (if using OAuth)

## Installation Methods - Choose One

### Method 1: Local Installation with uvx (Simplest)

**Best for**: Single user, quick testing, development

**Step 1**: Install and run directly
```bash
# Install and run with uvx
uvx mcp-atlassian --transport stdio
```

**Step 2**: Configure Claude Desktop
```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "uvx",
      "args": ["mcp-atlassian"],
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

---

### Method 2: Docker with Environment Variables (Single User)

**Best for**: Single user, production deployment, isolated environment

**Step 1**: Pull Docker image
```bash
docker pull olegische/mcp-atlassian:latest
```

**Step 2**: Configure Claude Desktop
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
        "olegische/mcp-atlassian:latest"
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

---

### Method 3: Docker with Custom Headers (Multi-User) ⭐ **RECOMMENDED**

**Best for**: Multi-user environments, enterprise deployments, dynamic credentials

**Step 1**: Start Docker container with custom headers support
```bash
docker run --rm -p 8000:8000 \
  -e ENABLE_CUSTOM_HEADERS=true \
  olegische/mcp-atlassian:latest \
  --transport sse --port 8000 -vv
```

**Step 2**: Configure Claude Desktop with HTTP transport
```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "url": "http://localhost:8000/sse",
      "headers": {
        "X-JIRA-URL": "https://your-company.atlassian.net",
        "X-JIRA-USERNAME": "your.email@company.com",
        "X-JIRA-API-TOKEN": "your_jira_api_token",
        "X-CONFLUENCE-URL": "https://your-company.atlassian.net/wiki",
        "X-CONFLUENCE-USERNAME": "your.email@company.com",
        "X-CONFLUENCE-API-TOKEN": "your_confluence_api_token"
      }
    }
  }
}
```

**For Server/Data Center** (Personal Access Tokens):
```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "url": "http://localhost:8000/sse",
      "headers": {
        "X-JIRA-URL": "https://jira.your-company.com",
        "X-JIRA-PERSONAL-TOKEN": "your_jira_personal_token",
        "X-CONFLUENCE-URL": "https://confluence.your-company.com",
        "X-CONFLUENCE-PERSONAL-TOKEN": "your_confluence_personal_token"
      }
    }
  }
}
```

---

### Method 4: MCPO Proxy for OpenWebUI Integration 🌐

**Best for**: OpenWebUI integration, REST API access, web-based AI interfaces

MCPO (MCP-to-OpenAPI proxy) converts MCP servers into standard REST APIs, making them compatible with OpenWebUI and other web-based AI platforms.

**Step 1**: Start MCP server with custom headers
```bash
docker run --rm -p 8000:8000 \
  -e ENABLE_CUSTOM_HEADERS=true \
  olegische/mcp-atlassian:latest \
  --transport sse --port 8000 -vv
```

**Step 2**: Set up environment variables for MCPO
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

**Step 3**: Run MCPO proxy to convert MCP to REST API
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

**Step 4**: Access REST API and OpenAPI documentation
- **REST API**: Available at `http://localhost:8600`
- **Interactive docs**: Visit `http://localhost:8600/docs` for Swagger UI
- **OpenWebUI**: Configure as external API endpoint in OpenWebUI settings

**Benefits of MCPO approach:**
- ✅ Converts MCP tools to standard REST APIs
- ✅ Auto-generates OpenAPI documentation
- ✅ Compatible with OpenWebUI and other web platforms
- ✅ Secure HTTP endpoints with authentication
- ✅ No need for custom MCP protocol handling

---

## Authentication Setup

Before using any method, set up your Atlassian credentials:

### For Atlassian Cloud (API Token) - **Recommended**

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click **Create API token**, name it (e.g., "MCP Atlassian")
3. Copy the token immediately and store it securely

### For Server/Data Center (Personal Access Token)

1. Go to your profile (avatar) → **Profile** → **Personal Access Tokens**
2. Click **Create token**, name it, set expiry
3. Copy the token immediately and store it securely

### For OAuth 2.0 (Cloud Only) - **Advanced**

1. Go to [Atlassian Developer Console](https://developer.atlassian.com/console/myapps/)
2. Create an "OAuth 2.0 (3LO) integration" app
3. Configure **Permissions** (scopes) for Jira/Confluence
4. Set **Callback URL** (e.g., `http://localhost:8080/callback`)
5. Run setup wizard:
   ```bash
   docker run --rm -i \
     -p 8080:8080 \
     -v "${HOME}/.mcp-atlassian:/home/app/.mcp-atlassian" \
     olegische/mcp-atlassian:latest --oauth-setup -v
   ```
6. Follow prompts and complete browser authorization

## Claude Desktop Configuration Files

**For Claude Desktop**, edit the configuration file:
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

## Configuration Options

### Environment Variables

- `CONFLUENCE_SPACES_FILTER`: Filter by space keys (e.g., "DEV,TEAM,DOC")
- `JIRA_PROJECTS_FILTER`: Filter by project keys (e.g., "PROJ,DEV,SUPPORT")
- `READ_ONLY_MODE`: Set to "true" to disable write operations
- `MCP_VERBOSE`: Set to "true" for more detailed logging
- `ENABLED_TOOLS`: Comma-separated list of tool names to enable
- `CONFLUENCE_SSL_VERIFY`: Set to "false" for self-signed certificates
- `JIRA_SSL_VERIFY`: Set to "false" for self-signed certificates
- `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`: Proxy configuration

## Troubleshooting

If you encounter issues during installation:

### Authentication Errors

- **Cloud**: Verify API tokens are correct (not your account password)
- **Server/Data Center**: Check Personal Access Token validity and expiration
- **OAuth**: Ensure all OAuth credentials are properly configured

### Connection Issues

- Verify URLs are accessible from your machine
- Check firewall and network restrictions
- For Server/Data Center: Confirm SSL certificate configuration

### Permission Errors

- Ensure your account has sufficient permissions for target spaces/projects
- Verify API token/PAT has appropriate scopes
- Check project and space access permissions

### Configuration Issues

- Verify JSON syntax in configuration file
- Check environment variable names and values
- Ensure Docker is running and accessible
- Validate file paths for OAuth volume mounts

### Debugging Commands

```bash
# Test Docker image
docker run --rm olegische/mcp-atlassian:latest --help

# Check logs (macOS)
tail -n 20 -f ~/Library/Logs/Claude/mcp*.log

# Check logs (Windows)
type %APPDATA%\Claude\logs\mcp*.log | more

# Test with MCP Inspector
npx @modelcontextprotocol/inspector docker run --rm -i olegische/mcp-atlassian:latest
```

## Security Notes

- Store API tokens and Personal Access Tokens securely
- Never commit credentials to version control
- Use environment files with proper permissions
- Regularly review and rotate access tokens
- Monitor access logs in Atlassian admin console
- Use OAuth for enhanced security in production environments

## Usage Examples

After installation, you can perform various operations:

### Jira Operations

```
"Create a bug ticket for login issue with high priority"
"Search for all open issues in PROJECT assigned to me"
"Update issue PROJ-123 status to In Progress"
"Add comment to issue PROJ-456 about testing results"
```

### Confluence Operations

```
"Search for API documentation in DEV space"
"Create a new page about deployment process"
"Update the troubleshooting guide with new steps"
"Find all pages labeled with 'architecture'"
```

### Cross-Service Operations

```
"Create Jira ticket from this Confluence page content"
"Update Confluence page with Jira project status"
"Find related documentation for this Jira issue"
```

## Support

For more detailed information and troubleshooting:

- Check the [GitHub repository](https://github.com/olegische/mcp-atlassian-mcpo-ready)
- Review the [full README](https://github.com/olegische/mcp-atlassian-mcpo-ready/blob/dev/README.md)
- File issues for bugs or feature requests
- Check [SECURITY.md](https://github.com/olegische/mcp-atlassian-mcpo-ready/blob/dev/SECURITY.md) for security best practices
