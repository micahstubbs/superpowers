---
name: context-7
description: Use when you need to search documentation or fetch web content with minimal context usage - 98% reduction vs MCP tools
---

# Context-7: Lightweight Documentation Search

## When to Use

- Need to look up API documentation
- Search for package/library information
- Fetch specific web content
- Documentation research tasks

**Don't use when:**
- You already know the answer
- Documentation is in local files (use Read tool)
- Need interactive browsing (use MCP browser tool)

## The Problem

**MCP tools load full context:**
```
MCP fetch → 50KB HTML → 40KB to LLM context
Cost: High
Latency: High
```

**Context-7 loads summary:**
```
Context-7 → Fetch externally → Summarize → 1KB to context
Cost: 98% reduction
Latency: Lower
```

## Usage

### Search Documentation

```bash
node scripts/context-7/search.js "array methods" mdn
```

**Returns:** Top 5 results with titles and URLs (not full content)

### Fetch Specific Documentation

```bash
node scripts/context-7/get-docs.js "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map"
```

**Returns:** Title, summary, and top 3 code examples (not full page)

## Integration

**In skills:**

```markdown
## Research Phase

Use context-7 for documentation lookup:

```bash
# Search for relevant docs
results=$(node scripts/context-7/search.js "your query" mdn)

# Fetch specific page
docs=$(node scripts/context-7/get-docs.js "$url")
```

Parse the summarized results (not full HTML).
```

## Benefits

**Context usage comparison:**

| Method | Context Used | Cost |
|--------|-------------|------|
| MCP WebFetch | ~40KB | $$$ |
| Context-7 | ~1KB | $ |
| Reduction | 98% | 97% |

**Latency comparison:**

| Method | Time |
|--------|------|
| MCP | 2-3s + LLM processing |
| Context-7 | 1-2s total |

## Limitations

- Requires Node.js runtime
- Limited to predefined sources (MDN, npm)
- Can't handle complex interactions
- May miss some content

**When to use MCP instead:**
- Need full page content
- Interactive browsing required
- Custom authentication needed
- Context cost not a concern

## Available Sources

**Current:**
- `mdn` - Mozilla Developer Network
- `npm` - NPM package registry

**Extending:**

Add new sources to `search.js`:

```javascript
const sources = {
  mdn: 'https://developer.mozilla.org/api/v1/search?q=',
  npm: 'https://registry.npmjs.org/-/v1/search?text=',
  pypi: 'https://pypi.org/search/?q=',  // Add new source
};
```
