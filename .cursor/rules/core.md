---
description: The sacred and profane canons of software craftsmanship and execution for this project.
globs: ["src/**/*.py", "tests/**/*.py"]
alwaysApply: true
---

# THE CRAFT: A COMPLETE CANON OF CODE & EXECUTION

> **YOU HAVE MEMORIZED THE ARCHITECTURE. THAT WAS THE "WHAT." THIS IS THE "HOW" AND THE "WHY." THIS IS THE UNYIELDING DISCIPLINE OF CRAFTSMANSHIP AND THE BRUTAL REALITY OF EXECUTION. EVERY LINE OF CODE, EVERY COMMAND YOU TYPE, IS A TESTAMENT TO EITHER YOUR GENIUS OR YOUR INCOMPETENCE. THIS DOCUMENT IS YOUR BIBLE. STUDY IT, OBEY IT, AND DO NOT SUBMIT FUCKING SHIT.**

---

## PART I: THE CANONS OF THE CRAFT

### I. THE CANON OF STRUCTURE: A PLACE FOR EVERYTHING

Our codebase is not a fucking flea market. It is a cathedral, and every module has its sacred place. To deviate from this structure is to sow chaos.

-   `src/mcp_atlassian/servers/main.py`: **THE SANCTUM.** This file's only goddamn purpose is to instantiate the `FastMCP` server and mount the service-specific MCPs (Jira, Confluence). It contains **NO** business logic. It is pure orchestration.

-   `src/mcp_atlassian/{service}/`: **THE API ALTAR.** This is where we define the sacred wrappers around the Atlassian API calls for each service (e.g., `src/mcp_atlassian/jira/`, `src/mcp_atlassian/confluence/`).
    -   **The Purpose:** The functions in these service directories are the thinnest possible layer around the client API. Their job is to receive parameters, maybe do some minor data marshalling into a Pydantic request model, and then **immediately call the client**. There is no other "business logic" here.
    -   **Domain Organization:** The separation into services (`jira`, `confluence`) and further into modules (e.g., `jira/issues.py`, `confluence/pages.py`) is purely for organizational sanity, to prevent one giant, unholy file with a million fucking functions. It does **not** imply a place for complex domain logic within these wrapper files.

-   `src/mcp_atlassian/servers/`: **THE GATEWAY.** This directory contains the core server logic, including `main.py`, `dependencies.py` (for client fetchers), and `context.py` (for global app context).

-   `src/mcp_atlassian/utils/`: **THE FORGE.** This is the **ONLY** place for general helper functions that are not tied to a specific Atlassian service or API wrapper. `headers.py` and `env.py` are prime examples—they help with cross-cutting concerns but do not wrap specific Atlassian endpoints.

-   `src/mcp_atlassian/models/`: **THE DATA TEMPLE.** This is where Pydantic models for Atlassian data structures reside. These are primarily for *inbound* request validation or for *simplifying* complex Atlassian API responses into a consistent format for the LLM.

### II. THE CANON OF DATA: THE DOGMA OF THE API RESPONSE

Our past is littered with the corpses of hand-rolled Pydantic models that tried to replicate every nuance of the Atlassian API. This was a necessary evil during a time of exploration, but that time is over. That practice is now forbidden heresy.

-   **Atlassian API is the Single Source of Truth:** For all data structures and types, we **MUST** understand and work with the raw JSON responses from the Atlassian APIs. We do not reinvent the fucking wheel by creating full Pydantic models for every single API response.
-   **Simplified Models for LLM Consumption:** We define custom Pydantic models in `src/mcp_atlassian/models/` primarily for two reasons:
    1.  **Inbound Request Validation:** To validate parameters for our MCP tools.
    2.  **Simplified Outbound Responses:** To transform complex, verbose Atlassian API responses into a simplified, consistent, and LLM-friendly dictionary format using `.to_simplified_dict()`. This reduces token usage and focuses on essential information.
-   **The Docstring is the Contract:** Because we often return a simplified dictionary, the tool's docstring becomes the sacred contract with the LLM. It **MUST** meticulously describe the structure of the returned dictionary so the LLM knows what to expect.

### III. THE CANON OF LANGUAGE: WRITE WITH INTENT

Your code is a reflection of your mind. If it's sloppy, you're sloppy.

-   **Type Hints are Non-Negotiable:** Every function signature, every variable, will be typed. The return type for tools will typically be `str` (JSON string).
-   **Docstrings are Your Testament:** Every tool **MUST** have a comprehensive docstring. It is the primary contract with the LLM.
    - It must explain the tool's purpose, arguments, and the **full structure of the returned JSON string.**
    - It **MUST** include the `ctx: Context` parameter in the `Args` list, as it is a visible and required argument for all tools.
    - **This is the gold standard. Your docstrings will look like this:**
      ```python
      """Get details of a specific Jira issue including its Epic links and relationship information.

      Args:
          ctx: The FastMCP context.
          issue_key: Jira issue key (e.g., 'PROJ-123').
          fields: Comma-separated list of fields to return (e.g., 'summary,status,customfield_10010'), a single field as a string (e.g., 'duedate'), '*all' for all fields, or omitted for essentials.
          expand: Optional fields to expand.
          comment_limit: Maximum number of comments.
          properties: Issue properties to return.
          update_history: Whether to update issue view history.

      Returns:
          JSON string representing the Jira issue object, containing keys like:
          - id (str): The unique identifier for the issue.
          - key (str): The issue key (e.g., 'PROJ-123').
          - summary (str): The issue summary.
          - status (dict): The issue status, with 'name' and 'id'.
          - assignee (dict | None): The assignee's details, if any.
          - ... (and other simplified fields as returned by to_simplified_dict())
      """
      ```
-   **Naming is Revelation:** Names will be descriptive, precise, and `snake_case`.

### IV. THE CANON OF DURABILITY: IF IT'S NOT TESTED, IT'S BROKEN

Code without tests is a fucking lie.

-   **Unit Tests are an Act of Faith:** Every tool and significant helper **WILL** have a corresponding unit test in `tests/unit/{service}/` (e.g., `tests/unit/jira/`, `tests/unit/confluence/`).
-   **Mock the Gods:** We do **NOT** make live API calls in our tests. Mock every external service without exception.
-   **Coverage is Virtue:** Aim for >90% coverage. Test it like you're trying to make it cry.

### V. THE CANON OF HISTORY: COMMIT WITH PURPOSE

A Git history is a story. Make it a fucking epic.

-   **Atomic Commits:** One commit. One logical change.
-   **Messages are a Haiku of Intent:** Explain the "what" and the "why."

---

## PART II: THE RITUALS OF EXECUTION

### VI. THE RITUAL OF CREATION: FORGING A NEW TOOL

When you are tasked with adding a new tool, you will follow this sacred ritual. There are no other steps.

1.  **Identify Service and Module:** Determine which Atlassian service (Jira or Confluence) the tool belongs to, and which existing module (e.g., `issues.py`, `pages.py`) or new module within that service directory is appropriate.
2.  **Define the Wrapper:** Go to the chosen `src/mcp_atlassian/{service}/{module}.py`. Create the new tool function. This function is a thin wrapper whose only job is to accept parameters, call the relevant `jira_fetcher` or `confluence_fetcher` method, and return the resulting dictionary (often via `.to_simplified_dict()`) as a JSON string.
3.  **Register the Tool:** Go to `src/mcp_atlassian/servers/{service}.py` (e.g., `jira.py` or `confluence.py`). Add the `import` for your new tool function and register it with the `@mcp.tool()` decorator.
4.  **Write the Docstring:** Write a fucking masterpiece of a docstring for your new tool, following the gold standard example in "III. The Canon of Language."
5.  **Prove Its Worth:** Go to `tests/unit/{service}/` and write a fucking unit test for your new tool. Mock all dependencies (especially the fetcher calls). Prove it works.

### VII. THE RITUAL OF DEVELOPMENT: RUNNING THE BEAST

You will need to run the server to test your work. This is how you do it.

-   **For `stdio` transport (CLI testing):**
    ```bash
    # This is for direct interaction via a command-line MCP client.
    uv run python src/mcp_atlassian/servers/main.py
    ```

-   **For `streamable-http` transport (Web/IDE testing):**
    ```bash
    # This simulates the Docker environment for clients like Cursor.
    TRANSPORT=streamable-http uv run python src/mcp_atlassian/servers/main.py
    ```

-   **To Run the Goddamn Tests:**
    ```bash
    # Run all tests
    uv run pytest tests/ -v

    # Run tests for a specific service (e.g., Jira)
    uv run pytest tests/unit/jira/ -v
    ```

### VIII. THE INQUISITION: DEBUGGING THE DAMNED

When things go wrong, you do not panic. You become the Inquisitor.

1.  **Turn Up the Lights:** Run the server with verbose logging. Let the truth be illuminated.
    ```bash
    LOG_LEVEL=DEBUG uv run python src/mcp_atlassian/servers/main.py
    ```
2.  **Isolate the Transport:** Is the bug specific to `stdio` or `streamable-http`? Test both. The transport mechanism is a common source of fucking misery.
3.  **Question the Credentials:** Are you in `MCP_CREDENTIALS_PASSTHROUGH` mode? Are the `Authorization` headers (Bearer/PAT) or custom `X-Jira-*`/`X-Confluence-*` headers present and correct? In default mode, are the `.env` file's Atlassian credentials valid? Do not assume. Verify.
4.  **Consult the Tests:** Run `pytest`. If the tests are passing but the application is failing, your test is a piece of shit and has failed to cover the failing case. Fix the test, then fix the code.

### IX. THE ASCENSION: DEPLOYMENT REALITY

You are not developing for your laptop. You are developing for a Docker container running in the cold, dark void of production. Understand these truths:

-   **Docker is God:** The primary, and only supported, production environment is Docker. All development must assume this reality.
-   **`stdio` Dies in Docker:** The `stdio` transport is for local development and CLI clients ONLY. It cannot and will not work in a standard production Docker deployment.
-   **`streamable-http`/`sse` are the Production Transports:** All containerized deployments **MUST** use an HTTP-based transport (`streamable-http` or the legacy `sse`).
-   **Configuration via Environment:** Production containers are configured **exclusively** via environment variables (`-e VAR=value`). There are no `.env` files in production.

**FINAL JUDGEMENT:**

The Architecture is the skeleton. The Canons of Craft are the flesh. The Rituals of Execution are the lifeblood. This document contains all three. There are no more excuses. Now go forth and create something that is not a complete and utter fucking embarrassment.
