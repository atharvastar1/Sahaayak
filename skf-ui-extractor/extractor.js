const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {

  const browser = await puppeteer.launch({
    headless: true
  });

  const page = await browser.newPage();

  await page.goto('https://www.skf.com/group/fighting-friction/01', {
    waitUntil: 'networkidle2',
    timeout: 60000
  });

  await page.waitForSelector('body');

  const uiElements = await page.evaluate(() => {

    const cleanText = (el) =>
      el.innerText?.trim().replace(/\s+/g, ' ') || null;

    return {
      metadata: {
        title: document.title,
        description: document.querySelector('meta[name="description"]')?.content || null,
        url: location.href
      },

      headings: Array.from(document.querySelectorAll('h1, h2, h3'))
        .map(el => cleanText(el))
        .filter(Boolean),

      links: Array.from(document.querySelectorAll('a[href]'))
        .map(a => ({
          text: cleanText(a),
          href: a.href
        }))
        .filter(link => link.text),

      buttons: Array.from(document.querySelectorAll('button, [role="button"]'))
        .map(btn => cleanText(btn))
        .filter(Boolean),

      images: Array.from(document.querySelectorAll('img'))
        .map(img => ({
          alt: img.alt || null,
          src: img.src
        }))
        .filter(img => img.src),

      sections: Array.from(document.querySelectorAll('section'))
        .map(sec => ({
          id: sec.id || null,
          class: sec.className || null
        }))
    };
  });

  fs.writeFileSync('skf-ui.json', JSON.stringify(uiElements, null, 2));

  console.log('Extraction complete. Data saved to skf-ui.json');

  await browser.close();

})();
