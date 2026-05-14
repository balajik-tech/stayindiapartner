const fs = require('fs');

const data = {
  "en": {
    "setup_property": "Setup Property",
    "step_x_of_y": "Step {current} of {total}",
    "btn_back": "Back",
    "btn_finish_setup": "Finish Setup",
    "btn_continue": "Continue",
    "basic_details": "Basic Details",
    "basic_details_sub": "Start by giving your property a name and identifying its type.",
    "type_of_pg": "Type of PG",
    "type_boys": "Boys",
    "type_girls": "Girls",
    "type_coliving": "Co-Living",
    "property_name": "Property Name",
    "property_name_hint": "e.g. Royal Heritage Hostel",
    "gst_number": "GST Number (Optional)",
    "gst_number_hint": "Enter GSTIN",
    "location_details": "Location Details",
    "location_details_sub": "Pin your property on the map for accurate guest navigation.",
    "location_on_map": "Location on Map",
    "location_hint": "Tap to pin location"
  },
  "hi": {
    "setup_property": "प्रॉपर्टी सेट अप करें",
    "step_x_of_y": "{total} में से {current} चरण",
    "btn_back": "वापस",
    "btn_finish_setup": "सेटअप समाप्त करें",
    "btn_continue": "जारी रखें",
    "basic_details": "मूल विवरण",
    "basic_details_sub": "अपनी प्रॉपर्टी का नाम देकर और उसका प्रकार पहचानकर प्रारंभ करें।",
    "type_of_pg": "पीजी का प्रकार",
    "type_boys": "लड़कों का",
    "type_girls": "लड़कियों का",
    "type_coliving": "सह-निवास",
    "property_name": "प्रॉपर्टी का नाम",
    "property_name_hint": "उदा. रॉयल हेरिटेज हॉस्टल",
    "gst_number": "जीएसटी नंबर (वैकल्पिक)",
    "gst_number_hint": "जीएसटीआईएन दर्ज करें",
    "location_details": "स्थान का विवरण",
    "location_details_sub": "सटीक अतिथि नेविगेशन के लिए अपनी प्रॉपर्टी को मानचित्र पर पिन करें।",
    "location_on_map": "मानचित्र पर स्थान",
    "location_hint": "स्थान पिन करने के लिए टैप करें"
  },
  "te": {
    "setup_property": "ఆస్తిని సెటప్ చేయండి",
    "step_x_of_y": "{total} లో {current} వ దశ",
    "btn_back": "వెనుకకు",
    "btn_finish_setup": "సెటప్ ముగించు",
    "btn_continue": "కొనసాగించండి",
    "basic_details": "ప్రాథమిక వివరాలు",
    "basic_details_sub": "మీ ఆస్తికి పేరు పెట్టడం మరియు దాని రకాన్ని గుర్తించడం ద్వారా ప్రారంభించండి.",
    "type_of_pg": "PG రకం",
    "type_boys": "అబ్బాయిలు",
    "type_girls": "అమ్మాయిలు",
    "type_coliving": "కో-లివింగ్",
    "property_name": "ఆస్తి పేరు",
    "property_name_hint": "ఉదా. రాయల్ హెరిటేజ్ హాస్టల్",
    "gst_number": "GST నంబర్ (ఐచ్ఛికం)",
    "gst_number_hint": "GSTIN నమోదు చేయండి",
    "location_details": "స్థాన వివరాలు",
    "location_details_sub": "ఖచ్చితమైన అతిథి నావిగేషన్ కోసం మ్యాప్‌లో మీ ఆస్తిని పిన్ చేయండి.",
    "location_on_map": "మ్యాప్‌లో స్థానం",
    "location_hint": "స్థానాన్ని పిన్ చేయడానికి నొక్కండి"
  },
  "ta": {
    "setup_property": "சொத்தை அமை",
    "step_x_of_y": "{total} இல் {current} படி",
    "btn_back": "பின்னால்",
    "btn_finish_setup": "அமைப்பை முடி",
    "btn_continue": "தொடரவும்",
    "basic_details": "அடிப்படை விவரங்கள்",
    "basic_details_sub": "உங்கள் சொத்திற்கு பெயரிட்டு அதன் வகையை அடையாளம் காண்பதன் மூலம் தொடங்கவும்.",
    "type_of_pg": "பிஜி வகை",
    "type_boys": "சிறுவர்கள்",
    "type_girls": "சிறுமிகள்",
    "type_coliving": "இணைந்து வாழ்தல்",
    "property_name": "சொத்து பெயர்",
    "property_name_hint": "உதாரணமாக. ராயல் ஹெரிடேஜ் ஹாஸ்டல்",
    "gst_number": "GST எண் (விருப்பத்தேர்வு)",
    "gst_number_hint": "GSTIN உள்ளிடவும்",
    "location_details": "இருப்பிட விவரங்கள்",
    "location_details_sub": "துல்லியமான விருந்தினர் வழிசெலுத்தலுக்கு உங்கள் சொத்தை வரைபடத்தில் பொருத்தவும்.",
    "location_on_map": "வரைபடத்தில் இருப்பிடம்",
    "location_hint": "இருப்பிடத்தை பொருத்த தட்டவும்"
  },
  "kn": {
    "setup_property": "ಆಸ್ತಿಯನ್ನು ಹೊಂದಿಸಿ",
    "step_x_of_y": "{total} ದಲ್ಲಿ {current} ನೇ ಹಂತ",
    "btn_back": "ಹಿಂದೆ",
    "btn_finish_setup": "ಸೆಟಪ್ ಮುಗಿಸಿ",
    "btn_continue": "ಮುಂದುವರಿಸಿ",
    "basic_details": "ಮೂಲ ವಿವರಗಳು",
    "basic_details_sub": "ನಿಮ್ಮ ಆಸ್ತಿಗೆ ಹೆಸರಿಸುವ ಮೂಲಕ ಮತ್ತು ಅದರ ಪ್ರಕಾರವನ್ನು ಗುರುತಿಸುವ ಮೂಲಕ ಪ್ರಾರಂಭಿಸಿ.",
    "type_of_pg": "ಪಿಜಿ ಪ್ರಕಾರ",
    "type_boys": "ಹುಡುಗರು",
    "type_girls": "ಹುಡುಗಿಯರು",
    "type_coliving": "ಸಹ-ವಾಸ",
    "property_name": "ಆಸ್ತಿಯ ಹೆಸರು",
    "property_name_hint": "ಉದಾ. ರಾಯಲ್ ಹೆರಿಟೇಜ್ ಹಾಸ್ಟೆಲ್",
    "gst_number": "ಜಿಎಸ್ಟಿ ಸಂಖ್ಯೆ (ಐಚ್ಛಿಕ)",
    "gst_number_hint": "GSTIN ನಮೂದಿಸಿ",
    "location_details": "ಸ್ಥಳ ವಿವರಗಳು",
    "location_details_sub": "ನಿಖರವಾದ ಅತಿಥಿ ನ್ಯಾವಿಗೇಶನ್‌ಗಾಗಿ ಮ್ಯಾಪ್‌ನಲ್ಲಿ ನಿಮ್ಮ ಆಸ್ತಿಯನ್ನು ಪಿನ್ ಮಾಡಿ.",
    "location_on_map": "ಮ್ಯಾಪ್‌ನಲ್ಲಿ ಸ್ಥಳ",
    "location_hint": "ಸ್ಥಳವನ್ನು ಪಿನ್ ಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ"
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

console.log('Setup property translations added.');
