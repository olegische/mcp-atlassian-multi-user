"""Utility functions for handling custom headers in HTTP requests."""

import logging
import urllib.parse
from typing import Any, Dict, Optional

from fastmcp.server.dependencies import get_http_request
from starlette.requests import Request

from .env import is_mcp_credentials_passthrough
from .logging import mask_sensitive

logger = logging.getLogger("mcp-atlassian.utils.headers")


def extract_custom_headers_from_request() -> Optional[Dict[str, Any]]:
    """Extract custom headers from the current HTTP request.
    
    Returns:
        Dictionary containing extracted header values, or None if not in HTTP context
        or custom headers are disabled.
    """
    if not is_mcp_credentials_passthrough():
        return None
        
    try:
        request: Request = get_http_request()
        logger.debug(f"Extracting custom headers from request: {request.url.path}")
        
        # Extract all custom headers
        headers = {}
        
        # Jira headers
        jira_header_mapping = {
            "X-JIRA-URL": "jira_url",
            "X-JIRA-USERNAME": "jira_username",
            "X-JIRA-API-TOKEN": "jira_api_token",
            "X-JIRA-PERSONAL-TOKEN": "jira_personal_token",
            "X-JIRA-SSL-VERIFY": "jira_ssl_verify",
            "X-JIRA-PROJECTS-FILTER": "jira_projects_filter",
            "X-JIRA-HTTP-PROXY": "jira_http_proxy",
            "X-JIRA-HTTPS-PROXY": "jira_https_proxy",
            "X-JIRA-NO-PROXY": "jira_no_proxy",
            "X-JIRA-SOCKS-PROXY": "jira_socks_proxy",
        }
        
        # Confluence headers
        confluence_header_mapping = {
            "X-CONFLUENCE-URL": "confluence_url",
            "X-CONFLUENCE-USERNAME": "confluence_username",
            "X-CONFLUENCE-API-TOKEN": "confluence_api_token",
            "X-CONFLUENCE-PERSONAL-TOKEN": "confluence_personal_token",
            "X-CONFLUENCE-SSL-VERIFY": "confluence_ssl_verify",
            "X-CONFLUENCE-SPACES-FILTER": "confluence_spaces_filter",
            "X-CONFLUENCE-HTTP-PROXY": "confluence_http_proxy",
            "X-CONFLUENCE-HTTPS-PROXY": "confluence_https_proxy",
            "X-CONFLUENCE-NO-PROXY": "confluence_no_proxy",
            "X-CONFLUENCE-SOCKS-PROXY": "confluence_socks_proxy",
        }
        
        # Process all headers
        all_mappings = {**jira_header_mapping, **confluence_header_mapping}
        headers_found = 0
        
        for header_name, attr_name in all_mappings.items():
            header_value = request.headers.get(header_name)
            if header_value is not None:
                headers_found += 1
                
                # No URL decoding - use tokens as-is
                
                headers[attr_name] = header_value
                
                # Log with masking for sensitive values
                if any(sensitive in attr_name for sensitive in ["token", "password", "key"]):
                    logger.debug(f"Found {header_name}: {mask_sensitive(header_value)}")
                else:
                    logger.debug(f"Found {header_name}: {header_value}")
        
        logger.info(f"Extracted {headers_found} custom headers from request")
        
        # Log all extracted headers for debugging (with masking for sensitive values)
        if headers:
            logger.info("=== EXTRACTED CUSTOM HEADERS ===")
            for key, value in headers.items():
                if any(sensitive in key for sensitive in ["token", "password", "key"]):
                    logger.info(f"  {key}: {mask_sensitive(value)}")
                else:
                    logger.info(f"  {key}: {value}")
            logger.info("=== END CUSTOM HEADERS ===")
        
        return headers if headers else None
        
    except RuntimeError:
        # Not in HTTP request context
        logger.debug("Not in HTTP request context - cannot extract custom headers")
        return None
    except Exception as e:
        logger.error(f"Error extracting custom headers: {e}")
        return None


def create_request_state_from_headers(headers: Dict[str, Any]) -> Any:
    """Create a mock request state object from headers dictionary.
    
    Args:
        headers: Dictionary of header values
        
    Returns:
        Object with header values as attributes
    """
    class MockRequestState:
        pass
    
    state = MockRequestState()
    for key, value in headers.items():
        setattr(state, key, value)
    
    return state
