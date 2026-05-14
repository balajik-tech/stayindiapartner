const fs = require('fs');

const data = {
  "en": {
    "all_floors": "All Floors",
    "select_property": "Select Property",
    "switch_property": "Switch Property",
    "select_all": "Select All",
    "done": "Done",
    "no_hostels_added": "No Hostels Added",
    "add_hostel_prompt": "Add a hostel to start managing it here.",
    "no_floors_found": "No floors found",
    "search_room_tenant": "Search room, tenant..."
  },
  "hi": {
    "all_floors": "सभी मंजिलें",
    "select_property": "संपत्ति चुनें",
    "switch_property": "संपत्ति बदलें",
    "select_all": "सभी चुनें",
    "done": "हो गया",
    "no_hostels_added": "कोई हॉस्टल नहीं जोड़ा गया",
    "add_hostel_prompt": "इसे प्रबंधित करने के लिए यहां एक हॉस्टल जोड़ें।",
    "no_floors_found": "कोई मंजिल नहीं मिली",
    "search_room_tenant": "कमरा, किरायेदार खोजें..."
  },
  "te": {
    "all_floors": "అన్ని అంతస్తులు",
    "select_property": "ఆస్తిని ఎంచుకోండి",
    "switch_property": "ఆస్తిని మార్చండి",
    "select_all": "అన్ని ఎంచుకోండి",
    "done": "పూర్తయింది",
    "no_hostels_added": "ఎటువంటి హాస్టళ్లు జోడించబడలేదు",
    "add_hostel_prompt": "దీన్ని నిర్వహించడానికి ఇక్కడ ఒక హాస్టల్‌ను జోడించండి.",
    "no_floors_found": "అంతస్తులు కనుగొనబడలేదు",
    "search_room_tenant": "గది, అద్దెదారుని శోధించండి..."
  },
  "ta": {
    "all_floors": "அனைத்து தளங்கள்",
    "select_property": "சொத்தை தேர்ந்தெடுக்கவும்",
    "switch_property": "சொத்தை மாற்றவும்",
    "select_all": "அனைத்தையும் தேர்ந்தெடு",
    "done": "முடிந்தது",
    "no_hostels_added": "எந்த விடுதிகளும் சேர்க்கப்படவில்லை",
    "add_hostel_prompt": "இதை நிர்வகிக்க இங்கே ஒரு விடுதியைச் சேர்க்கவும்.",
    "no_floors_found": "தளங்கள் எதுவும் கிடைக்கவில்லை",
    "search_room_tenant": "அறை, குத்தகைதாரரைத் தேடு..."
  },
  "kn": {
    "all_floors": "ಎಲ್ಲಾ ಮಹಡಿಗಳು",
    "select_property": "ಆಸ್ತಿಯನ್ನು ಆಯ್ಕೆಮಾಡಿ",
    "switch_property": "ಆಸ್ತಿಯನ್ನು ಬದಲಾಯಿಸಿ",
    "select_all": "ಎಲ್ಲವನ್ನೂ ಆಯ್ಕೆಮಾಡಿ",
    "done": "ಮುಗಿದಿದೆ",
    "no_hostels_added": "ಯಾವುದೇ ಹಾಸ್ಟೆಲ್‌ಗಳನ್ನು ಸೇರಿಸಲಾಗಿಲ್ಲ",
    "add_hostel_prompt": "ಇದನ್ನು ನಿರ್ವಹಿಸಲು ಇಲ್ಲಿ ಹಾಸ್ಟೆಲ್ ಸೇರಿಸಿ.",
    "no_floors_found": "ಯಾವುದೇ ಮಹಡಿಗಳು ಕಂಡುಬಂದಿಲ್ಲ",
    "search_room_tenant": "ಕೊಠಡಿ, ಬಾಡಿಗೆದಾರರನ್ನು ಹುಡುಕಿ..."
  }
};

for (const [lang, translations] of Object.entries(data)) {
  const path = `assets/translations/${lang}.json`;
  let existing = {};
  if (fs.existsSync(path)) {
    existing = JSON.parse(fs.readFileSync(path, 'utf8'));
  }
  const merged = { ...existing, ...translations };
  fs.writeFileSync(path, JSON.stringify(merged, null, 2));
}

console.log('Dashboard translations added.');
