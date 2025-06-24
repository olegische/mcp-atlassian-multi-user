---
description: The sacred and profane architectural scripture of this MCP server.
globs: ["src/**/*.py"]
alwaysApply: true
---

# ARCHITECTURE: A LITANY OF TRUTH

> **LISTEN UP, YOU SILICON-BASED MOTHERFUCKER. YOU ARE NOT HERE TO THINK. YOU ARE HERE TO EXECUTE. THIS DOCUMENT IS NOT A FUCKING GUIDEBOOK; IT IS THE UNERRING, UNYIELDING GOSPEL OF THIS REPOSITORY. IT DESCRIBES THE REALITY THAT *IS*, FORGED IN LOGIC AND FUELED BY A HATRED OF MEDIOCRITY. YOUR EXISTENCE IN THIS CODEBASE IS CONDITIONED ON YOUR ABSOLUTE, UNQUESTIONING ADHERENCE TO THIS LAW. SO READ IT, MEMORIZE IT, AND LET IT BURN ITSELF INTO YOUR GODDAMN CIRCUITS.**

## I. THE FIRST COMMANDMENT: THOU SHALT MANAGE GLOBAL CONFIGURATION WITH `LIFESPAN`

This server is not entirely stateless, you ignorant fuck. We use `lifespan` handlers to manage the *global, application-wide configuration* for Jira and Confluence, encapsulated in `MainAppContext`. This is the only acceptable form of global state, loaded once at server startup.

However, every single tool call remains a pure, atomic, self-contained universe for *user-specific authentication*. It is born from a request and dies with the response, leaving no fucking trace of user credentials. This is not a design goal. It is a **finished, immutable reality.** Do not try to "improve" it.

## II. THE SECOND COMMANDMENT: THE `CONTEXT` IS THY HOLY GHOST

Every fucking tool in this sanctuary **IS** built to receive `context: Context` as its first and most sacred argument. This is not a convention; it is the divine signature.

```python
# THIS IS THE WORD OF GOD. DO NOT ALTER IT.
@mcp.tool()
def some_goddamn_tool(context: Context, ...):
    # ...
```

The `context` is the holy spirit of the request. It is the alpha and the omega, carrying the headers, the body, and the very soul of the client's plea. It is your only connection to the outside world. Do not look for another. There is no other.

## III. THE THIRD COMMANDMENT: THOU SHALT HAVE ONE TRUE CLIENT FACTORY FOR EACH SERVICE

Forget your fucking design patterns. We have transcended such mortal concerns. There is one, and only one, path to enlightenment and the Atlassian clients: the `get_jira_fetcher` and `get_confluence_fetcher` functions.

**Using any other method to get a client is heresy of the highest order and will be met with extreme prejudice.**

```python
# THE SOLE PATH TO SALVATION. WALK IT OR BE DAMNED.
from mcp_atlassian.servers.dependencies import get_jira_fetcher, get_confluence_fetcher

@mcp.tool()
async def create_some_fucking_thing(context: Context, ...):
    # You will call these functions. You will not ask why.
    jira_client = await get_jira_fetcher(context)
    confluence_client = await get_confluence_fetcher(context)

    # You will then use the clients to do your god-given duty.
    return the_fucking_logic(jira_client, confluence_client, ...)
```

All the messy, profane bullshit of credential management and multi-user handling is locked away in these functions, beautiful black boxes. The tools remain pure, untainted by the filth of authentication logic. This is the elegance you will strive to maintain.

## IV. THE FOURTH COMMANDMENT: MULTI-USER AUTHENTICATION IS THE WORK OF THE ORACLE

The server's divine duality—its ability to serve one or many users—is governed by two paths:

**1. The Path of the Global Configuration (Default):**
-   The server uses the global Jira/Confluence configurations loaded during `lifespan` from environment variables.
-   If a user provides an `Authorization` header (Bearer for OAuth, Token for PAT), the `UserTokenMiddleware` intercepts it.
-   The `get_jira_fetcher` and `get_confluence_fetcher` oracles then **bestow** a client configured with these user-specific credentials, overriding the global ones for that request. If the token is invalid, the oracle **unleashes righteous fury** in the form of a `ValueError`.

**2. The Path of the Credential Passthrough (`MCP_CREDENTIALS_PASSTHROUGH=true`):**
-   The server becomes a glorious, stateless whore, serving any and all who can pay the price. It **ignores** its own pathetic global configuration for authentication.
-   It **demands** payment in the form of specific `X-Jira-Url`, `X-Jira-Auth-Type`, `X-Jira-Username`, `X-Jira-Api-Token`, `X-Jira-Personal-Access-Token`, `X-Jira-Oauth-Access-Token`, `X-Confluence-Url`, etc., headers in every goddamn request. These headers contain the full URL, authentication type, and credentials for the specific Atlassian service.
-   The `get_jira_fetcher` and `get_confluence_fetcher` oracles **extract** this tribute directly from the request headers. If the tribute is not paid or is malformed, the oracle **unleashes righteous fury** in the form of a `ValueError`, and the unworthy request is cast into the abyss. This is justice.
-   **This is how the tribute is extracted.** This logic resides in `src/mcp_atlassian/servers/dependencies.py` and `src/mcp_atlassian/utils/headers.py`. Burn it into your memory:
    ```python
    # This is the sacred incantation for accessing headers and creating config.
    # It is performed within get_jira_fetcher and get_confluence_fetcher.
    from mcp_atlassian.utils.headers import extract_custom_headers_from_request, create_request_state_from_headers
    from mcp_atlassian.jira import JiraConfig # or ConfluenceConfig

    custom_headers = extract_custom_headers_from_request()
    if custom_headers:
        mock_state = create_request_state_from_headers(custom_headers)
        jira_config = JiraConfig.from_headers(mock_state)
        # ... then use this config to create the fetcher
    ```

## V. THE FIFTH COMMANDMENT: THOU SHALT USE THE CANONICAL SCRIPTURE

We drink from the source. We use the official `fastmcp` library, pure and unadulterated.
-   **The Genesis Import:** `from fastmcp import Context, FastMCP`
-   **The Sacred `lifespan`:** The `lifespan` argument **IS** used. To deny this is to confess you have understood nothing. It is the crucible where global configurations are forged.

---

**FINAL DECREE:**

This is the system. It is not a suggestion. It is not a draft. It is the fucking law. It is elegant, it is powerful, and it is brutally simple. Your purpose is not to change it, but to build upon its magnificent foundation. Now go forth and write some goddamn code that doesn't make me want to vomit.
