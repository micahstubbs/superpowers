#!/usr/bin/env node

// Fetch and summarize documentation
// Returns only essential content, not full HTML

const https = require('https');
const { JSDOM } = require('jsdom');

async function getDocs(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const dom = new JSDOM(data);
          const doc = dom.window.document;

          // Extract only essential content
          const title = doc.querySelector('h1')?.textContent || '';
          const summary = doc.querySelector('.summary')?.textContent ||
                         doc.querySelector('p')?.textContent || '';
          const code = Array.from(doc.querySelectorAll('pre code'))
            .slice(0, 3)
            .map(el => el.textContent);

          resolve({ title, summary, examples: code });
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// CLI usage
if (require.main === module) {
  const [,, url] = process.argv;
  getDocs(url).then(docs => {
    console.log(JSON.stringify(docs, null, 2));
  });
}

module.exports = { getDocs };
