# Usage Examples

Here are some practical examples of how to use the Broken Link Checker MCP tool:

## Basic Website Scan

```
Scan https://mywebsite.com for broken links
```

This will perform a basic scan with default settings:
- Max depth: 2
- Include external links: true
- Timeout: 10 seconds

## WordPress Site Examples

### Full WordPress Site Scan
```
Scan my WordPress blog https://myblog.com for all broken links with depth 3
```

### Internal Links Only (WordPress)
```
Scan https://mywordpresssite.com but only check internal links
```

### WordPress with Custom Timeout
```
Scan https://myblog.com for broken links with 15 second timeout
```

## Specific Link Checking

### Check Important Pages
```
Check these specific URLs:
- https://mysite.com/contact
- https://mysite.com/about-us
- https://mysite.com/services
- https://mysite.com/portfolio
```

### Check WordPress Core URLs
```
Check these WordPress URLs for broken links:
- https://myblog.com/wp-admin
- https://myblog.com/wp-content/themes/mytheme/style.css
- https://myblog.com/wp-content/plugins/myplugin/
```

## Advanced Scanning

### Deep Crawl for Large Sites
```
Scan https://mylargesite.com with maximum depth of 5 levels and 20 second timeout
```

### Quick External Link Check
```
Scan https://mysite.com with depth 1 and only check external links
```

## E-commerce Site Examples

### Product Page Scan
```
Scan https://mystore.com/products for broken links with depth 2
```

### Check Critical E-commerce URLs
```
Check these e-commerce URLs:
- https://mystore.com/cart
- https://mystore.com/checkout
- https://mystore.com/my-account
- https://mystore.com/payment-methods
```

## Blog and Content Sites

### Blog Post Link Check
```
Scan https://myblog.com/blog for broken links including external references
```

### Documentation Site
```
Scan https://docs.myproject.com with depth 4 and exclude external links
```

## Scheduled Maintenance Examples

### Weekly Site Health Check
```
Scan https://mysite.com for broken links with depth 2, include external links
```

### Post-Update Verification
```
Check these recently updated pages:
- https://mysite.com/newly-updated-page
- https://mysite.com/recent-blog-post
- https://mysite.com/updated-product-page
```

## Troubleshooting Examples

### Slow Site Scanning
```
Scan https://slowwebsite.com with 30 second timeout and depth 1
```

### Focus on Specific Section
```
Scan https://mysite.com/specific-section with depth 3 and exclude external links
```

## Report Interpretation

After running any scan, you'll get a report with:

- **Summary**: Total links found, broken count, success rate
- **Broken Links**: Detailed list with status codes and error messages
- **Link Locations**: Shows which pages contain the broken links

### Sample Report Output
```
# Broken Link Report for https://example.com

## Summary
- Total unique links found: 156
- Broken links: 3
- Success rate: 98.1%

## Broken Links Details

### ❌ https://example.com/old-page
- Status: 404
- Error: HTTP error
- Found on pages:
  - https://example.com/blog/post-1
  - https://example.com/about
```

## Best Practices

1. **Start Small**: Begin with depth 1-2 for initial scans
2. **Regular Checks**: Run weekly scans for active sites
3. **Focus Areas**: Use specific link checking for critical pages
4. **External vs Internal**: Separate internal and external link checks
5. **Timeout Adjustment**: Increase timeout for slower sites
6. **Batch Processing**: The tool automatically handles large link sets

## Integration Ideas

- Run before major site deployments
- Include in CI/CD pipelines
- Schedule regular health checks
- Monitor after content updates
- Verify after theme/plugin changes (WordPress)