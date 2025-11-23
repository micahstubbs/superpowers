#!/usr/bin/env node

// Context-7 search script
// Searches documentation with minimal context usage

const https = require('https');

async function search(query, source = 'mdn') {
  const sources = {
    mdn: 'https://developer.mozilla.org/api/v1/search?q=',
    npm: 'https://registry.npmjs.org/-/v1/search?text=',
  };

  const url = sources[source] + encodeURIComponent(query);

  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const results = JSON.parse(data);
          // Return summarized results, not full content
          resolve(results.documents || results.objects || []);
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// CLI usage
if (require.main === module) {
  const [,, query, source] = process.argv;
  search(query, source).then(results => {
    console.log(JSON.stringify(results.slice(0, 5), null, 2));
  });
}

module.exports = { search };
