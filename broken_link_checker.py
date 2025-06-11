# MCP Tool for Broken Link Checking
# This would be implemented as an MCP server

import asyncio
import aiohttp
from urllib.parse import urljoin, urlparse
from bs4 import BeautifulSoup
import mcp.types as types
from mcp.server import Server
from mcp.server.models import InitializationOptions
import mcp.server.stdio

# MCP Server setup
server = Server("broken-link-checker")

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """List available tools for broken link checking."""
    return [
        types.Tool(
            name="scan_website_links",
            description="Scan a website for broken links and return a comprehensive report",
            inputSchema={
                "type": "object",
                "properties": {
                    "url": {
                        "type": "string",
                        "description": "The base URL of the website to scan"
                    },
                    "max_depth": {
                        "type": "integer", 
                        "description": "Maximum crawl depth (default: 2)",
                        "default": 2
                    },
                    "include_external": {
                        "type": "boolean",
                        "description": "Whether to check external links (default: true)",
                        "default": True
                    },
                    "timeout": {
                        "type": "integer",
                        "description": "Request timeout in seconds (default: 10)",
                        "default": 10
                    }
                },
                "required": ["url"]
            }
        ),
        types.Tool(
            name="check_specific_links",
            description="Check status of specific URLs",
            inputSchema={
                "type": "object", 
                "properties": {
                    "urls": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "List of URLs to check"
                    },
                    "timeout": {
                        "type": "integer",
                        "description": "Request timeout in seconds (default: 10)", 
                        "default": 10
                    }
                },
                "required": ["urls"]
            }
        )
    ]

class LinkChecker:
    def __init__(self, timeout=10):
        self.timeout = timeout
        self.session = None
        
    async def __aenter__(self):
        self.session = aiohttp.ClientSession(
            timeout=aiohttp.ClientTimeout(total=self.timeout),
            headers={'User-Agent': 'MCP-BrokenLinkChecker/1.0'}
        )
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
    
    async def check_url(self, url):
        """Check if a single URL is accessible."""
        try:
            async with self.session.head(url, allow_redirects=True) as response:
                return {
                    'url': url,
                    'status': response.status,
                    'accessible': response.status < 400,
                    'error': None,
                    'final_url': str(response.url)
                }
        except Exception as e:
            return {
                'url': url,
                'status': None,
                'accessible': False,
                'error': str(e),
                'final_url': None
            }
    
    async def extract_links(self, url, base_url):
        """Extract all links from a webpage."""
        try:
            async with self.session.get(url) as response:
                if response.status >= 400:
                    return []
                
                content = await response.text()
                soup = BeautifulSoup(content, 'html.parser')
                
                links = []
                # Extract href links
                for link in soup.find_all(['a', 'link'], href=True):
                    href = link['href']
                    full_url = urljoin(base_url, href)
                    links.append({
                        'url': full_url,
                        'text': link.get_text(strip=True)[:100],
                        'tag': link.name,
                        'found_on': url
                    })
                
                # Extract src links (images, scripts, etc.)
                for element in soup.find_all(['img', 'script'], src=True):
                    src = element['src'] 
                    full_url = urljoin(base_url, src)
                    links.append({
                        'url': full_url,
                        'text': element.get('alt', ''),
                        'tag': element.name,
                        'found_on': url
                    })
                
                return links
        except Exception as e:
            return []
    
    async def crawl_website(self, base_url, max_depth=2, include_external=True):
        """Crawl website and find all links."""
        visited = set()
        to_visit = [(base_url, 0)]
        all_links = []
        
        while to_visit:
            current_url, depth = to_visit.pop(0)
            
            if current_url in visited or depth > max_depth:
                continue
                
            visited.add(current_url)
            links = await self.extract_links(current_url, base_url)
            
            for link in links:
                link_url = link['url']
                parsed_base = urlparse(base_url)
                parsed_link = urlparse(link_url)
                
                # Add to all_links for checking
                all_links.append(link)
                
                # Add internal links to crawl queue
                if parsed_link.netloc == parsed_base.netloc and depth < max_depth:
                    if link_url not in visited:
                        to_visit.append((link_url, depth + 1))
        
        # Filter external links if requested
        if not include_external:
            parsed_base = urlparse(base_url)
            all_links = [link for link in all_links 
                        if urlparse(link['url']).netloc == parsed_base.netloc]
        
        return all_links

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    """Handle tool calls for broken link checking."""
    
    if name == "scan_website_links":
        url = arguments["url"]
        max_depth = arguments.get("max_depth", 2)
        include_external = arguments.get("include_external", True)
        timeout = arguments.get("timeout", 10)
        
        async with LinkChecker(timeout) as checker:
            # Crawl website to find all links
            all_links = await checker.crawl_website(url, max_depth, include_external)
            
            # Check each unique link
            unique_urls = list(set(link['url'] for link in all_links))
            
            # Check links in batches to avoid overwhelming the server
            batch_size = 10
            results = []
            
            for i in range(0, len(unique_urls), batch_size):
                batch = unique_urls[i:i+batch_size]
                batch_results = await asyncio.gather(
                    *[checker.check_url(url) for url in batch],
                    return_exceptions=True
                )
                results.extend(batch_results)
            
            # Create status mapping
            url_status = {r['url']: r for r in results if isinstance(r, dict)}
            
            # Generate report
            broken_links = [r for r in results if isinstance(r, dict) and not r['accessible']]
            total_links = len(unique_urls)
            broken_count = len(broken_links)
            
            report = f"""# Broken Link Report for {url}

## Summary
- **Total unique links found**: {total_links}
- **Broken links**: {broken_count}
- **Success rate**: {((total_links - broken_count) / total_links * 100):.1f}%

## Scan Parameters
- Max depth: {max_depth}
- Include external links: {include_external}
- Timeout: {timeout}s

## Broken Links Details
"""
            
            if broken_links:
                for broken in broken_links:
                    report += f"\n### ❌ {broken['url']}\n"
                    report += f"- **Status**: {broken['status'] or 'No response'}\n"
                    report += f"- **Error**: {broken['error'] or 'HTTP error'}\n"
                    
                    # Find where this link appears
                    appearances = [link for link in all_links if link['url'] == broken['url']]
                    if appearances:
                        report += f"- **Found on pages**:\n"
                        for appearance in appearances[:5]:  # Limit to first 5
                            report += f"  - {appearance['found_on']}\n"
                        if len(appearances) > 5:
                            report += f"  - ... and {len(appearances) - 5} more pages\n"
                    report += "\n"
            else:
                report += "\n🎉 No broken links found!\n"
            
            return [types.TextContent(type="text", text=report)]
    
    elif name == "check_specific_links":
        urls = arguments["urls"]
        timeout = arguments.get("timeout", 10)
        
        async with LinkChecker(timeout) as checker:
            results = await asyncio.gather(
                *[checker.check_url(url) for url in urls],
                return_exceptions=True
            )
            
            report = "# Link Status Check Results\n\n"
            
            for result in results:
                if isinstance(result, dict):
                    status_emoji = "✅" if result['accessible'] else "❌"
                    report += f"{status_emoji} **{result['url']}**\n"
                    report += f"   - Status: {result['status'] or 'No response'}\n"
                    if result['error']:
                        report += f"   - Error: {result['error']}\n"
                    if result['final_url'] != result['url']:
                        report += f"   - Redirected to: {result['final_url']}\n"
                    report += "\n"
            
            return [types.TextContent(type="text", text=report)]
    
    else:
        raise ValueError(f"Unknown tool: {name}")

async def main():
    # Run the server using stdin/stdout streams
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="broken-link-checker",
                server_version="1.0.0",
                capabilities=server.get_capabilities(
                    notification_options=None,
                    experimental_capabilities=None
                )
            )
        )

if __name__ == "__main__":
    asyncio.run(main())