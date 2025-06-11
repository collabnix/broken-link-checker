# Broken Link Checker MCP Tool

A Model Context Protocol (MCP) tool for checking broken links on websites. This tool can crawl websites and identify broken internal and external links, providing detailed reports.

## Features

- 🔍 **Website Crawling**: Crawl websites up to specified depth
- 🔗 **Link Detection**: Find all links including href, src, and other link types
- ✅ **Status Checking**: Check HTTP status of each link
- 📊 **Detailed Reports**: Get comprehensive reports with broken link details
- ⚡ **Batch Processing**: Process links in batches for better performance
- 🎯 **Specific Link Testing**: Check status of specific URLs
- 🌐 **Internal/External Filtering**: Option to include or exclude external links

## Installation

1. Clone this repository:
```bash
git clone https://github.com/collabnix/broken-link-checker.git
cd broken-link-checker
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure your MCP client (e.g., Claude Desktop) to use this tool:

```json
{
  "mcpServers": {
    "broken-link-checker": {
      "command": "python",
      "args": ["/path/to/broken-link-checker/broken_link_checker.py"]
    }
  }
}
```

## Available Tools

### 1. `scan_website_links`

Comprehensively scan a website for broken links.

**Parameters:**
- `url` (required): The base URL of the website to scan
- `max_depth` (optional): Maximum crawl depth (default: 2)
- `include_external` (optional): Whether to check external links (default: true)
- `timeout` (optional): Request timeout in seconds (default: 10)

**Example:**
```
Scan mywebsite.com for broken links with depth 3
```

### 2. `check_specific_links`

Check the status of specific URLs.

**Parameters:**
- `urls` (required): Array of URLs to check
- `timeout` (optional): Request timeout in seconds (default: 10)

**Example:**
```
Check these URLs: https://example.com/page1, https://example.com/page2
```

## Usage Examples

### WordPress Site Check
```
Scan my WordPress site https://myblog.com for broken links
```

### Internal Links Only
```
Scan https://mysite.com but only check internal links
```

### Specific Links
```
Check these specific URLs for broken links:
- https://example.com/contact
- https://example.com/about
- https://example.com/products
```

### Deep Crawl
```
Scan https://mysite.com with maximum depth of 5 levels
```

## Report Format

The tool generates detailed reports including:

- **Summary**: Total links found, broken count, success rate
- **Scan Parameters**: Depth, external link inclusion, timeout
- **Broken Link Details**: Status codes, error messages, locations where broken links appear

## Configuration

### Claude Desktop Configuration

Add to your Claude Desktop configuration file:

```json
{
  "mcpServers": {
    "broken-link-checker": {
      "command": "python",
      "args": ["/absolute/path/to/broken_link_checker.py"]
    }
  }
}
```

### Environment Setup

Make sure you have Python 3.8+ installed and the required dependencies:

```bash
python --version  # Should be 3.8+
pip install -r requirements.txt
```

## Troubleshooting

### Common Issues

1. **Import Errors**: Make sure all dependencies are installed
2. **Timeout Issues**: Increase timeout parameter for slow websites
3. **Rate Limiting**: The tool includes batch processing to avoid overwhelming servers
4. **Permission Errors**: Ensure the Python file has execute permissions

### Performance Tips

- Use lower `max_depth` for large websites
- Set `include_external=false` to focus on internal links only
- Adjust `timeout` based on your website's response time
- For very large sites, consider running scans during off-peak hours

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions, please open an issue on GitHub.