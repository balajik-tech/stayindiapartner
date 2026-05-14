const fs = require('fs');

const data = {
  "en": {
    "tenants_title": "Tenants",
    "tenants_subtitle": "Manage property residents",
    "tab_tenants": "Tenants",
    "tab_services": "Services",
    "tab_notices": "Notices",
    "search_residents": "Search residents...",
    "no_residents_found": "No residents found",
    "no_active_tenants": "No active tenants found",
    "add_tenant": "Add Tenant",
    
    "bookings_title": "Bookings",
    "bookings_subtitle": "Manage stays and residents",
    "tab_requests": "Requests",
    "tab_active": "Active",
    "tab_history": "History",
    "no_pending_requests": "No pending requests",
    "new_booking_requests_here": "New booking requests will appear here",
    
    "new_property": "New Property",
    "new_property_sub": "Onboard your new hostel/PG",
    "add_new_floor_rooms": "Add New Floor and Rooms",
    "add_new_floor_rooms_sub": "Expand your existing building",
    "add_tenant_sub": "Quick tenant check-in flow",
    "room_master": "Room Master",
    "room_master_sub": "Manage room types and pricing",
    
    "total_properties": "Total Properties",
    "total_beds": "Total Beds",
    "payment_dues": "Payment Dues",
    "occupied": "Occupied"
  },
  "hi": {
    "tenants_title": "किरायेदार",
    "tenants_subtitle": "संपत्ति के निवासियों का प्रबंधन करें",
    "tab_tenants": "किरायेदार",
    "tab_services": "सेवाएं",
    "tab_notices": "नोटिस",
    "search_residents": "निवासियों को खोजें...",
    "no_residents_found": "कोई निवासी नहीं मिला",
    "no_active_tenants": "कोई सक्रिय किरायेदार नहीं मिला",
    "add_tenant": "किरायेदार जोड़ें",
    
    "bookings_title": "बुकिंग",
    "bookings_subtitle": "प्रवास और निवासियों का प्रबंधन करें",
    "tab_requests": "अनुरोध",
    "tab_active": "सक्रिय",
    "tab_history": "इतिहास",
    "no_pending_requests": "कोई लंबित अनुरोध नहीं",
    "new_booking_requests_here": "नए बुकिंग अनुरोध यहां दिखाई देंगे",
    
    "new_property": "नई संपत्ति",
    "new_property_sub": "अपना नया हॉस्टल/पीजी ऑनबोर्ड करें",
    "add_new_floor_rooms": "नई मंजिल और कमरे जोड़ें",
    "add_new_floor_rooms_sub": "अपनी मौजूदा इमारत का विस्तार करें",
    "add_tenant_sub": "त्वरित किरायेदार चेक-इन प्रवाह",
    "room_master": "रूम मास्टर",
    "room_master_sub": "कमरे के प्रकार और मूल्य निर्धारण प्रबंधित करें",
    
    "total_properties": "कुल संपत्तियां",
    "total_beds": "कुल बिस्तर",
    "payment_dues": "भुगतान बकाया",
    "occupied": "अधिकृत"
  },
  "te": {
    "tenants_title": "అద్దెదారులు",
    "tenants_subtitle": "ఆస్తి నివాసితులను నిర్వహించండి",
    "tab_tenants": "అద్దెదారులు",
    "tab_services": "సేవలు",
    "tab_notices": "నోటీసులు",
    "search_residents": "నివాసితులను శోధించండి...",
    "no_residents_found": "నివాసితులు ఎవరూ కనుగొనబడలేదు",
    "no_active_tenants": "క్రియాశీల అద్దెదారులు కనుగొనబడలేదు",
    "add_tenant": "అద్దెదారుని జోడించండి",
    
    "bookings_title": "బుకింగ్‌లు",
    "bookings_subtitle": "బసలు మరియు నివాసితులను నిర్వహించండి",
    "tab_requests": "అభ్యర్థనలు",
    "tab_active": "క్రియాశీల",
    "tab_history": "చరిత్ర",
    "no_pending_requests": "పెండింగ్ అభ్యర్థనలు లేవు",
    "new_booking_requests_here": "కొత్త బుకింగ్ అభ్యర్థనలు ఇక్కడ కనిపిస్తాయి",
    
    "new_property": "కొత్త ఆస్తి",
    "new_property_sub": "మీ కొత్త హాస్టల్/PG ని ఆన్‌బోర్డ్ చేయండి",
    "add_new_floor_rooms": "కొత్త అంతస్తు మరియు గదులను జోడించండి",
    "add_new_floor_rooms_sub": "మీ ప్రస్తుత భవనాన్ని విస్తరించండి",
    "add_tenant_sub": "త్వరిత అద్దెదారు చెక్-ఇన్ ప్రవాహం",
    "room_master": "రూమ్ మాస్టర్",
    "room_master_sub": "గది రకాలు మరియు ధరలను నిర్వహించండి",
    
    "total_properties": "మొత్తం ఆస్తులు",
    "total_beds": "మొత్తం పడకలు",
    "payment_dues": "చెల్లింపు బకాయిలు",
    "occupied": "ఆక్రమించబడినది"
  },
  "ta": {
    "tenants_title": "குத்தகைதாரர்கள்",
    "tenants_subtitle": "சொத்து குடியிருப்பாளர்களை நிர்வகிக்கவும்",
    "tab_tenants": "குத்தகைதாரர்கள்",
    "tab_services": "சேவைகள்",
    "tab_notices": "அறிவிப்புகள்",
    "search_residents": "குடியிருப்பாளர்களைத் தேடு...",
    "no_residents_found": "குடியிருப்பாளர்கள் யாரும் கிடைக்கவில்லை",
    "no_active_tenants": "செயலில் உள்ள குத்தகைதாரர்கள் இல்லை",
    "add_tenant": "குத்தகைதாரரைச் சேர்",
    
    "bookings_title": "முன்பதிவுகள்",
    "bookings_subtitle": "தங்கும் இடங்கள் மற்றும் குடியிருப்பாளர்களை நிர்வகிக்கவும்",
    "tab_requests": "கோரிக்கைகள்",
    "tab_active": "செயலில்",
    "tab_history": "வரலாறு",
    "no_pending_requests": "நிலுவையில் உள்ள கோரிக்கைகள் இல்லை",
    "new_booking_requests_here": "புதிய முன்பதிவு கோரிக்கைகள் இங்கே தோன்றும்",
    
    "new_property": "புதிய சொத்து",
    "new_property_sub": "உங்கள் புதிய விடுதி/பிஜியை சேர்க்கவும்",
    "add_new_floor_rooms": "புதிய தளம் மற்றும் அறைகளைச் சேர்",
    "add_new_floor_rooms_sub": "உங்கள் தற்போதைய கட்டிடத்தை விரிவாக்குங்கள்",
    "add_tenant_sub": "விரைவான குத்தகைதாரர் செக்-இன் ஓட்டம்",
    "room_master": "அறை மாஸ்டர்",
    "room_master_sub": "அறை வகைகள் மற்றும் விலைகளை நிர்வகிக்கவும்",
    
    "total_properties": "மொத்த சொத்துக்கள்",
    "total_beds": "மொத்த படுக்கைகள்",
    "payment_dues": "பணம் செலுத்த வேண்டியவை",
    "occupied": "ஆக்கிரமிக்கப்பட்டுள்ளது"
  },
  "kn": {
    "tenants_title": "ಬಾಡಿಗೆದಾರರು",
    "tenants_subtitle": "ಆಸ್ತಿ ನಿವಾಸಿಗಳನ್ನು ನಿರ್ವಹಿಸಿ",
    "tab_tenants": "ಬಾಡಿಗೆದಾರರು",
    "tab_services": "ಸೇವೆಗಳು",
    "tab_notices": "ಸೂಚನೆಗಳು",
    "search_residents": "ನಿವಾಸಿಗಳನ್ನು ಹುಡುಕಿ...",
    "no_residents_found": "ಯಾವುದೇ ನಿವಾಸಿಗಳು ಕಂಡುಬಂದಿಲ್ಲ",
    "no_active_tenants": "ಯಾವುದೇ ಸಕ್ರಿಯ ಬಾಡಿಗೆದಾರರು ಕಂಡುಬಂದಿಲ್ಲ",
    "add_tenant": "ಬಾಡಿಗೆದಾರರನ್ನು ಸೇರಿಸಿ",
    
    "bookings_title": "ಬುಕಿಂಗ್‌ಗಳು",
    "bookings_subtitle": "ತಂಗುವಿಕೆಗಳು ಮತ್ತು ನಿವಾಸಿಗಳನ್ನು ನಿರ್ವಹಿಸಿ",
    "tab_requests": "ವಿನಂತಿಗಳು",
    "tab_active": "ಸಕ್ರಿಯ",
    "tab_history": "ಇತಿಹಾಸ",
    "no_pending_requests": "ಯಾವುದೇ ಬಾಕಿ ವಿನಂತಿಗಳಿಲ್ಲ",
    "new_booking_requests_here": "ಹೊಸ ಬುಕಿಂಗ್ ವಿನಂತಿಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ",
    
    "new_property": "ಹೊಸ ಆಸ್ತಿ",
    "new_property_sub": "ನಿಮ್ಮ ಹೊಸ ಹಾಸ್ಟೆಲ್/ಪಿಜಿಯನ್ನು ಆನ್‌ಬೋರ್ಡ್ ಮಾಡಿ",
    "add_new_floor_rooms": "ಹೊಸ ಮಹಡಿ ಮತ್ತು ಕೊಠಡಿಗಳನ್ನು ಸೇರಿಸಿ",
    "add_new_floor_rooms_sub": "ನಿಮ್ಮ ಅಸ್ತಿತ್ವದಲ್ಲಿರುವ ಕಟ್ಟಡವನ್ನು ವಿಸ್ತರಿಸಿ",
    "add_tenant_sub": "ತ್ವರಿತ ಬಾಡಿಗೆದಾರರ ಚೆಕ್-ಇನ್ ಹರಿವು",
    "room_master": "ರೂಮ್ ಮಾಸ್ಟರ್",
    "room_master_sub": "ಕೊಠಡಿ ಪ್ರಕಾರಗಳು ಮತ್ತು ಬೆಲೆಗಳನ್ನು ನಿರ್ವಹಿಸಿ",
    
    "total_properties": "ಒಟ್ಟು ಆಸ್ತಿಗಳು",
    "total_beds": "ಒಟ್ಟು ಹಾಸಿಗೆಗಳು",
    "payment_dues": "ಪಾವತಿ ಬಾಕಿ",
    "occupied": "ಆಕ್ರಮಿಸಿಕೊಂಡಿದೆ"
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

console.log('Translations added.');
