const fs = require('fs');

const updates = {
  "en": {
    "sharing_double": "2 Sharing",
    "sharing_triple": "3 Sharing",
    "sharing_quad": "4 Sharing"
  },
  "hi": {
    "sharing_double": "2 शेयरिंग",
    "sharing_triple": "3 शेयरिंग",
    "sharing_quad": "4 शेयरिंग"
  },
  "te": {
    "sharing_double": "2 షేరింగ్",
    "sharing_triple": "3 షేరింగ్",
    "sharing_quad": "4 షేరింగ్"
  },
  "ta": {
    "sharing_double": "2 பகிர்வு",
    "sharing_triple": "3 பகிர்வு",
    "sharing_quad": "4 பகிர்வு"
  },
  "kn": {
    "sharing_double": "2 ಹಂಚಿಕೆ",
    "sharing_triple": "3 ಹಂಚಿಕೆ",
    "sharing_quad": "4 ಹಂಚಿಕೆ"
  }
};

for (const [lang, translations] of Object.entries(updates)) {
  const path = "assets/translations/" + lang + ".json";
  let existing = {};
  if (fs.existsSync(path)) {
    existing = JSON.parse(fs.readFileSync(path, 'utf8'));
  }
  const merged = { ...existing, ...translations };
  fs.writeFileSync(path, JSON.stringify(merged, null, 2));
}

console.log('Sharing translations updated to 2 Sharing, 3 Sharing, etc.');
