import '../domain/entities/stock_item.dart';

class StockConstants {
  static const Map<String, List<Map<String, String>>> masterList = {
    'Grocery': [
      {'name': 'Rice', 'unit': 'KG'},
      {'name': 'Dal', 'unit': 'KG'},
      {'name': 'Oil', 'unit': 'LTR'},
      {'name': 'Sugar', 'unit': 'KG'},
      {'name': 'Salt', 'unit': 'KG'},
    ],
    'Cleaning': [
      {'name': 'Phenyl', 'unit': 'LTR'},
      {'name': 'Soap', 'unit': 'PCS'},
      {'name': 'Detergent', 'unit': 'KG'},
    ],
    'Vegetables': [
      {'name': 'Tomato', 'unit': 'KG'},
      {'name': 'Onion', 'unit': 'KG'},
      {'name': 'Potato', 'unit': 'KG'},
      {'name': 'Green Chilli', 'unit': 'KG'},
      {'name': 'Ginger', 'unit': 'KG'},
    ],
    'Other': [
      {'name': 'Bulb', 'unit': 'PCS'},
      {'name': 'Battery', 'unit': 'PCS'},
    ],
  };

  static List<Map<String, String>> getAllItems() {
    final List<Map<String, String>> items = [];
    for (final category in masterList.keys) {
      for (final item in masterList[category]!) {
        if (item['name'] != null) {
          final Map<String, String> copy = Map.from(item);
          copy['category'] = category;
          items.add(copy);
        }
      }
    }
    return items;
  }

  static const Map<String, Map<String, String>> stockTranslations = {
    "Basmati Rice": {
      "te": "బాస్మతి బియ్యం",
      "hi": "बासमती चावल",
      "ta": "பாசுமதி அரிசி",
      "kn": "ಬಾಸ್ಮತಿ ಅಕ್ಕಿ",
    },
    "Sona Masoori Rice": {
      "te": "సోనా మసూరి బియ్యం",
      "hi": "सोना मसूरी चावल",
      "ta": "சோனா மசூரி அரிசி",
      "kn": "ಸೋನಾ ಮಸೂರಿ ಅಕ್ಕಿ",
    },
    "Brown Rice": {
      "te": "ముడి బియ్యం (బ్రౌన్ రైస్)",
      "hi": "भूरा चावल (ब्राउन राइस)",
      "ta": "கைக்குத்தல் அரிசி",
      "kn": "ಕೆಂಪಕ್ಕಿ (ಬ್ರೌನ್ ರೈಸ್)",
    },
    "Idli Rice": {
      "te": "ఇడ్లీ బియ్యం",
      "hi": "इडली चावल",
      "ta": "இட்லி அரிசி",
      "kn": "ಇಡ್ಲಿ ಅಕ್ಕಿ",
    },
    "Poha Thick": {
      "te": "లావు అటుకులు",
      "hi": "मोटा पोहा",
      "ta": "கெட்டி அவல்",
      "kn": "ದಪ್ಪ ಅವಲಕ್ಕಿ",
    },
    "Poha Thin": {
      "te": "పలుచని అటుకులు",
      "hi": "पतला पोहा",
      "ta": "லேசான அவல்",
      "kn": "ತೆಳು ಅವಲಕ್ಕಿ",
    },
    "Bombay Rava / Sooji": {
      "te": "బొంబాయి రవ్వ / సూజీ",
      "hi": "सूजी / रवा",
      "ta": "ரவா / சூஜி",
      "kn": "ಬಾಂಬೆ ರವೆ / ಸೂಜಿ",
    },
    "Wheat Rava / Daliya": {
      "te": "గోధుమ రవ్వ",
      "hi": "दलिया / गेहूं का रवा",
      "ta": "கோதுமை ரவா / தலியா",
      "kn": "ಗೋಧಿ ರವೆ / ದಲಿಯಾ",
    },
    "Idli Rava": {
      "te": "ఇడ్లీ రవ్వ",
      "hi": "इडली रवा",
      "ta": "இட்லி ரவா",
      "kn": "ಇಡ್ಲಿ ರವೆ",
    },
    "Roasted Vermicelli": {
      "te": "వేపిన సేమియా",
      "hi": "भुनी हुई सेवई",
      "ta": "வறுத்த சேமியா",
      "kn": "ಹುರಿದ ಶಾವಿಗೆ",
    },
    "Plain Vermicelli": {
      "te": "సాదా సేమియా",
      "hi": "सादी सेवई",
      "ta": "சாதா சேமியா",
      "kn": "ಶಾವಿಗೆ",
    },
    "Wheat Flour / Atta": {
      "te": "గోధుమ పిండి",
      "hi": "गेहूं का आटा",
      "ta": "கோதுமை மாவு",
      "kn": "ಗೋಧಿ ಹಿಟ್ಟು",
    },
    "Maida Flour": {
      "te": "మైదా పిండి",
      "hi": "मैदा",
      "ta": "மைதா மாவு",
      "kn": "ಮೈದಾ ಹಿಟ್ಟು",
    },
    "Besan / Gram Flour": {
      "te": "శనగ పిండి",
      "hi": "बेसन",
      "ta": "கடலை மாவு",
      "kn": "ಕಡಲೆ ಹಿಟ್ಟು",
    },
    "Rice Flour": {
      "te": "బియ్యం పిండి",
      "hi": "चावल का आटा",
      "ta": "அரிசி மாவு",
      "kn": "ಅಕ್ಕಿ ಹಿಟ್ಟು",
    },
    "Ragi Flour": {
      "te": "రాగి పిండి",
      "hi": "रागी का आटा",
      "ta": "கேழ்வரகு மாவு",
      "kn": "ರಾಗಿ ಹಿಟ್ಟು",
    },
    "Toor Dal": {
      "te": "కంది పప్పు",
      "hi": "अरहर दाल (तूर दाल)",
      "ta": "துவரம் பருப்பு",
      "kn": "ತೊಗರಿ ಬೇಳೆ",
    },
    "Urad Dal Whole White": {
      "te": "మినప గుళ్ళు",
      "hi": "साबुत उड़द (सफेद)",
      "ta": "முழு உளுத்தம் பருப்பு",
      "kn": "ಉದ್ದಿನ ಬೇಳೆ (ಬಿಳಿ)",
    },
    "Urad Dal Split": {
      "te": "ఛాయ మినప పప్పు",
      "hi": "उड़द दाल (धुली)",
      "ta": "உடைத்த உளுத்தம் பருப்பு",
      "kn": "ಸೀಳಿದ ಉದ್ದಿನ ಬೇಳೆ",
    },
    "Moong Dal Yellow": {
      "te": "పెసర పప్పు",
      "hi": "मूंग दाल (पीली)",
      "ta": "பாசிப் பருப்பு",
      "kn": "ಹೆಸರು ಬೇಳೆ",
    },
    "Moong Whole Green": {
      "te": "పెసలు",
      "hi": "साबुत हरी मूंग",
      "ta": "பச்சை பயிறு",
      "kn": "ಹಸಿರು ಕಾಳು (ಹೆಸರು ಕಾಳು)",
    },
    "Chana Dal": {
      "te": "పచ్చి శనగ పప్పు",
      "hi": "चना दाल",
      "ta": "கடலைப் பருப்பு",
      "kn": "ಕಡಲೆ ಬೇಳೆ",
    },
    "Masoor Dal Split Red": {
      "te": "ఎర్ర కంది పప్పు",
      "hi": "मसूर दाल (लाल)",
      "ta": "மசூர் பருப்பு",
      "kn": "ಮಸೂರ್ ಬೇಳೆ",
    },
    "Kabuli Chana White": {
      "te": "కాబూలీ శనగలు",
      "hi": "काबुली चना (सफेद)",
      "ta": "வெள்ளை சுண்டல்",
      "kn": "ಕಾಬುಲಿ ಕಡಲೆ",
    },
    "Kala Chana Black": {
      "te": "నల్ల శనగలు",
      "hi": "काला चना",
      "ta": "கருப்பு சுண்டல்",
      "kn": "ಕಪ್ಪು ಕಡಲೆ",
    },
    "Rajma Red": {
      "te": "రాజ్మా",
      "hi": "राजमा (लाल)",
      "ta": "ராஜ்மா",
      "kn": "ರಾಜ್ಮಾ",
    },
    "Soya Chunks": {
      "te": "సోయా చంక్స్ / మీల్ మేకర్",
      "hi": "सोया चंक्स",
      "ta": "சோயா உருண்டைகள்",
      "kn": "ಸೋಯಾ ಚಂಕ್ಸ್",
    },
    "White Sugar Medium": {
      "te": "పంచదార",
      "hi": "चीनी / शक्कर",
      "ta": "சர்க்கரை",
      "kn": "ಸಕ್ಕರೆ",
    },
    "Jaggery Blocks / Gur": {
      "te": "బెల్లం",
      "hi": "गुड़",
      "ta": "வெல்லம்",
      "kn": "ಬೆಲ್ಲ",
    },
    "Iodized Table Salt": {
      "te": "సన్న ఉప్పు",
      "hi": "नमक",
      "ta": "தூள் உப்பு",
      "kn": "ಪುಡಿ ಉಪ್ಪು",
    },
    "Rock Salt / Sendha Namak": {
      "te": "కల్లు ఉప్పు / సైంధవ లవణం",
      "hi": "सेंधा नमक",
      "ta": "கல் உப்பு",
      "kn": "ಕಲ್ಲು ಉಪ್ಪು",
    },
    "Turmeric Powder / Haldi": {
      "te": "పసుపు",
      "hi": "हल्दी पाउडर",
      "ta": "மஞ்சள் தூள்",
      "kn": "ಅರಿಶಿನ ಪುಡಿ",
    },
    "Red Chilli Powder Regular": {
      "te": "కారం",
      "hi": "लाल मिर्च पाउडर",
      "ta": "மிளகாய் தூள்",
      "kn": "ಮೆಣಸಿನ ಪುಡಿ",
    },
    "Coriander Powder / Dhania": {
      "te": "ధనియాల పొడి",
      "hi": "धनिया पाउडर",
      "ta": "மல்லித் தூள்",
      "kn": "ಕೊತ್ತಂಬರಿ ಪುಡಿ",
    },
    "Cumin Seeds / Jeera": {
      "te": "జీలకర్ర",
      "hi": "जीरा",
      "ta": "சீரகம்",
      "kn": "ಜೀರಿಗೆ",
    },
    "Mustard Seeds / Rai": {
      "te": "ఆవాలు",
      "hi": "राई / सरसों",
      "ta": "கடுகு",
      "kn": "ಸಾಸಿವೆ",
    },
    "Black Pepper Whole": {
      "te": "మిరియాలు",
      "hi": "काली मिर्च",
      "ta": "மிளகு",
      "kn": "ಕಾಳು ಮೆಣಸು",
    },
    "Green Cardamom / Elaichi": {
      "te": "యాలకులు",
      "hi": "हरी इलायची",
      "ta": "ஏலக்காய்",
      "kn": "ಏಲಕ್ಕಿ",
    },
    "Cloves / Laung": {
      "te": "లవంగాలు",
      "hi": "लौंग",
      "ta": "கிராம்பு",
      "kn": "ಲವಂಗ",
    },
    "Cinnamon Sticks / Dalchini": {
      "te": "దాల్చిన చెక్క",
      "hi": "दालचीनी",
      "ta": "இலவங்கப்பட்டை",
      "kn": "ಚಕ್ಕೆ (ದಾಲ್ಚಿನ್ನಿ)",
    },
    "Bay Leaves / Tej Patta": {
      "te": "బిర్యానీ ఆకు",
      "hi": "तेज पत्ता",
      "ta": "பிரிஞ்சி இலை",
      "kn": "ಪಲಾವ್ ಎಲೆ",
    },
    "Garam Masala Powder": {
      "te": "గరం మసాలా",
      "hi": "गरम मसाला",
      "ta": "கரம் மசாலா",
      "kn": "ಗರಂ ಮಸಾಲಾ",
    },
    "Sambar Powder": {
      "te": "సాంబార్ పొడి",
      "hi": "सांभर पाउडर",
      "ta": "சாம்பார் பொடி",
      "kn": "ಸಾಂಬಾರ್ ಪುಡಿ",
    },
    "Rasam Powder": {
      "te": "రసం పొడి",
      "hi": "रसम पाउडर",
      "ta": "ரசம் பொடி",
      "kn": "ರಸಂ ಪುಡಿ",
    },
    "Biryani Masala Powder": {
      "te": "బిర్యానీ మసాలా",
      "hi": "बिरयानी मसाला",
      "ta": "பிரியாணி மசாலா",
      "kn": "ಬಿರಿಯಾನಿ ಮಸಾಲಾ",
    },
    "Refined Sunflower Oil": {
      "te": "సన్‌ఫ్లవర్ నూనె",
      "hi": "रिफाइंड सनफ्लावर तेल",
      "ta": "சூரியகாந்தி எண்ணெய்",
      "kn": "ಸೂರ್ಯಕಾಂತಿ ಎಣ್ಣೆ",
    },
    "Mustard Oil / Kachi Ghani": {
      "te": "ఆవ నూనె",
      "hi": "सरसों का तेल",
      "ta": "கடுகு எண்ணெய்",
      "kn": "ಸಾಸಿವೆ ಎಣ್ಣೆ",
    },
    "Palm Oil": {
      "te": "పామాయిల్",
      "hi": "पाम तेल",
      "ta": "பாமாயில்",
      "kn": "ಪಾಮ್ ಎಣ್ಣೆ",
    },
    "Groundnut Oil": {
      "te": "వేరుశనగ నూనె / పల్లి నూనె",
      "hi": "मूंगफली का तेल",
      "ta": "கடலை எண்ணெய்",
      "kn": "ಕಡಲೆಕಾಯಿ ಎಣ್ಣೆ",
    },
    "Pure Cow Ghee": {
      "te": "ఆవు నెయ్యి",
      "hi": "शुद्ध गाय का घी",
      "ta": "பசு நெய்",
      "kn": "ಹಸುವಿನ ತುಪ್ಪ",
    },
    "Salted Table Butter": {
      "te": "వెన్న (బట్టర్)",
      "hi": "मक्खन (बटर)",
      "ta": "வெண்ணெய்",
      "kn": "ಬೆಣ್ಣೆ",
    },
    "Full Cream Milk": {
      "te": "పాలు (ఫుల్ క్రీమ్)",
      "hi": "दूध (फुल क्रीम)",
      "ta": "பால்",
      "kn": "ಹಾಲು",
    },
    "Toned Milk": {
      "te": "పాలు (టోన్డ్)",
      "hi": "दूध (टोन्ड)",
      "ta": "பால் (டோன்ட்)",
      "kn": "ಹಾಲು (ಟೋನ್ಡ್)",
    },
    "Fresh Curd / Dahi": {
      "te": "పెరుగు",
      "hi": "दही",
      "ta": "தயிர்",
      "kn": "ಮೊಸರು",
    },
    "Paneer Blocks": {
      "te": "పన్నీర్",
      "hi": "पनीर",
      "ta": "பன்னீர்",
      "kn": "ಪನೀರ್",
    },
    "Fresh White Eggs": {
      "te": "గుడ్లు (ఎగ్స్)",
      "hi": "अंडे",
      "ta": "முட்டை",
      "kn": "ಮೊಟ್ಟೆ",
    },
    "Assam CTC Tea Powder": {
      "te": "టీ పొడి / చాయ్ పత్తి",
      "hi": "चाय पत्ती",
      "ta": "டீ தூள்",
      "kn": "ಚಹಾ ಪುಡಿ",
    },
    "Filter Coffee Powder": {
      "te": "ఫిల్టర్ కాఫీ పొడి",
      "hi": "फिल्टर कॉफी पाउडर",
      "ta": "பில்டர் காபி தூள்",
      "kn": "ಫಿಲ್ಟರ್ ಕಾಫಿ ಪುಡಿ",
    },
    "Instant Coffee Powder": {
      "te": "ఇన్‌స్టంట్ కాఫీ పొడి",
      "hi": "इंस्टेंट कॉफी पाउडर",
      "ta": "இன்ஸ்டன்ட் காபி தூள்",
      "kn": "ಇನ್ಸ್ಟಂಟ್ ಕಾಫಿ ಪುಡಿ",
    },
    "Tamarind Slab": {
      "te": "చింతపండు",
      "hi": "इमली",
      "ta": "புளி",
      "kn": "ಹುಣಸೆಹಣ್ಣು",
    },
    "Garlic Cloves": {
      "te": "వెల్లుల్లి",
      "hi": "लहसुन",
      "ta": "பூண்டு",
      "kn": "ಬೆಳ್ಳುಳ್ಳಿ",
    },
    "Ginger Fresh": {
      "te": "అల్లం",
      "hi": "अदरक",
      "ta": "இஞ்சி",
      "kn": "ಶುಂಠಿ",
    },
    "Green Chillies": {
      "te": "పచ్చిమిర్చి",
      "hi": "हरी मिर्च",
      "ta": "பச்சை மிளகாய்",
      "kn": "ಹಸಿರು ಮೆಣಸಿನಕಾಯಿ",
    },
    "Red Onions Medium": {
      "te": "ఉల్లిపాయలు",
      "hi": "प्याज",
      "ta": "வெங்காயம்",
      "kn": "ಈರುಳ್ಳಿ",
    },
    "Potatoes Regular": {
      "te": "బంగాళదుంపలు / ఆలుగడ్డ",
      "hi": "आलू",
      "ta": "உருளைக்கிழங்கு",
      "kn": "ಆಲೂಗಡ್ಡೆ",
    },
    "Phenyl White Concentrated": {
      "te": "ఫినాయిల్ వైట్",
      "hi": "फिनाइल व्हाइट",
      "ta": "பினாயில் வெள்ளை",
      "kn": "ಫಿನಾಯಿಲ್ ಬಿಳಿ",
    },
    "Phenyl Herbal Green": {
      "te": "ఫినాయిల్ గ్రీన్",
      "hi": "फिनाइल ग्रीन",
      "ta": "பினாயில் பச்சை",
      "kn": "ಫಿನಾಯಿಲ್ ಹಸಿರು",
    },
    "Bleaching Powder Pack": {
      "te": "బ్లీచింగ్ పౌడర్",
      "hi": "ब्लीचिंग पाउडर",
      "ta": "பிளீச்சிங் பவுடர்",
      "kn": "ಬ್ಲೀಚಿಂಗ್ ಪುಡಿ",
    },
    "Hydrochloric Acid Commercial": {
      "te": "హైడ్రోక్లోరిక్ యాసిడ్",
      "hi": "हाइड्रोक्लोरिक एसिड",
      "ta": "ஹைட்ரோகுளோரிக் அமிலம்",
      "kn": "ಹೈಡ್ರೋಕ್ಲೋರಿಕ್ ಆಸಿಡ್",
    },
    "Harpic Blue Toilet Cleaner Liquid": {
      "te": "హార్పిక్ బ్లూ టాయిలెట్ క్లీనర్",
      "hi": "हार्पिक ब्लू टॉयलेट क्लीनर",
      "ta": "ஹார்பிக் நீலம்",
      "kn": "ಹಾರ್ಪಿಕ್ ಬ್ಲೂ",
    },
    "Harpic Red Bathroom Cleaner Liquid": {
      "te": "హార్పిక్ రెడ్ బాత్‌రూమ్ క్లీనర్",
      "hi": "हार्पिक रेड बाथरूम क्लीनर",
      "ta": "ஹார்பிக் சிவப்பு",
      "kn": "ಹಾರ್ಪಿಕ್ ರೆಡ್",
    },
    "Lizol Floor Cleaner Citrus Yellow": {
      "te": "లైజాల్ ఫ్లోర్ క్లీనర్",
      "hi": "लाइजोल फ्लोर क्लीनर",
      "ta": "லைசால் தரை சுத்தி",
      "kn": "ಲೈಝೋಲ್ ಫ್ಲೋರ್ ಕ್ಲೀನರ್",
    },
    "Colin Glass Cleaner Spray Bottle": {
      "te": "కొలిన్ గ్లాస్ క్లీనర్",
      "hi": "कोलिन ग्लास क्लीनर",
      "ta": "கோலின் கிளாஸ் கிளீனர்",
      "kn": "ಕೋಲಿನ್ ಗ್ಲಾಸ್ ಕ್ಲೀನರ್",
    },
    "Surf Excel Detergent Powder": {
      "te": "సర్ఫ్ ఎక్సెల్ డిటర్జెంట్ పొడి",
      "hi": "सर्फ एक्सेल डिटर्जेंट पाउडर",
      "ta": "சர்ப் எக்செல் தூள்",
      "kn": "ಸರ್ಫ್ ಎಕ್ಸೆಲ್ ಪುಡಿ",
    },
    "Nirma Washing Powder Regular": {
      "te": "నిర్మా వాషింగ్ పౌడర్",
      "hi": "निरमा वाशिंग पाउडर",
      "ta": "நிர்மா சலவை தூள்",
      "kn": "ನಿರ್ಮಾ ವಾಷಿಂಗ್ ಪುಡಿ",
    },
    "Rin Detergent Cake Bar": {
      "te": "రిన్ సబ్బు",
      "hi": "रिन साबुन",
      "ta": "ரின் சோப்பு",
      "kn": "ರಿನ್ ಸೋಪು",
    },
    "Vim Dishwash Bar Green": {
      "te": "విమ్ బార్ సబ్బు",
      "hi": "विम डिशवॉश बार",
      "ta": "விம் பாத்திர சோப்பு",
      "kn": "ವಿಮ್ ಬಾರ್",
    },
    "Vim Dishwash Liquid Gel Yellow": {
      "te": "విమ్ లిక్విడ్ జెల్",
      "hi": "विम लिक्विड जेल",
      "ta": "விம் லிக்விட்",
      "kn": "ವಿಮ್ ಲಿಕ್ವಿಡ್",
    },
    "Stainless Steel Scrubbers Wire": {
      "te": "స్టీల్ స్క్రబ్బర్ / పీచు",
      "hi": "स्टील स्क्रबर / जूना",
      "ta": "ஸ்டீல் ஸ்க்ரப்பர்",
      "kn": "ಸ್ಟೀಲ್ ಸ್ಕ್ರಬ್ಬರ್",
    },
    "Scotch-Brite Green Scrub Pad Regular": {
      "te": "స్క్రబ్ ప్యాడ్ (స్కాచ్-బ్రైట్)",
      "hi": "स्क्रब पैड (स्कॉच-ब्राइट)",
      "ta": "ஸ்க்ரப் பேட்",
      "kn": "ಸ್ಕ್ರಬ್ ಪ್ಯಾಡ್",
    },
    "Sponge Wipes Pack of 5": {
      "te": "స్పాంజ్ వైప్స్ (5 ప్యాక్)",
      "hi": "स्पंज वाइप्स (5 पैक)",
      "ta": "ஸ்பாஞ்ச் வைப்ஸ்",
      "kn": "ಸ್ಪಾಂಜ್ ವೈಪ್ಸ್",
    },
    "Yellow Microfiber Cleaning Cloth": {
      "te": "క్లీనింగ్ క్లాత్ (మైక్రోఫైబర్)",
      "hi": "सफाई का कपड़ा (माइक्रोफाइबर)",
      "ta": "சுத்தம் செய்யும் துணி",
      "kn": "ಸ್ವಚ್ಛಗೊಳಿಸುವ ಬಟ್ಟೆ",
    },
    "Cotton Floor Duster Pocha Checkered": {
      "te": "ఫ్లోర్ డస్టర్ / పోచా గుడ్డ",
      "hi": "पोंछा का कपड़ा / डस्टर",
      "ta": "தரை துடைக்கும் துணி",
      "kn": "ನೆಲ ಒರೆಸುವ ಬಟ್ಟೆ",
    },
    "Round Cotton Wet Mop Head Refill": {
      "te": "కాటన్ వెట్ మాప్ రీఫిల్",
      "hi": "कॉटन वेट मॉप रिफिल",
      "ta": "காட்டன் வெட் மாப்",
      "kn": "ಕಾಟನ್ ವೆಟ್ ಮಾಪ್",
    },
    "Natural Grass Broom Phool Jhadu": {
      "te": "చీపురు (పూల్ ఝాడు)",
      "hi": "फूल झाड़ू",
      "ta": "பூவாத்தி துடைப்பம்",
      "kn": "ಪೊರಕೆ (ಹೂವಿನ ಪೊರಕೆ)",
    },
    "Coconut Seekh Broom Stick": {
      "te": "పుల్ల చీపురు",
      "hi": "सींक झाड़ू",
      "ta": "தென்னங்குச்சி துடைப்பம்",
      "kn": "ಕಡ್ಡಿ ಪೊರಕೆ",
    },
    "Floor Wiper Heavy Duty Large 18-inch": {
      "te": "ఫ్లోర్ వైపర్",
      "hi": "फ्लोर वाइपर",
      "ta": "தரை வைப்பர்",
      "kn": "ಫ್ಲೋರ್ ವೈಪರ್",
    },
    "Kitchen Sink Wiper Small Plastic": {
      "te": "కిచెన్ సింక్ వైపర్",
      "hi": "किचन सिंक वाइपर",
      "ta": "சமையலறை சிங்க் வைப்பர்",
      "kn": "ಕಿಚನ್ ಸಿಂಕ್ ವೈಪರ್",
    },
    "Plastic Dustpan with Hand Brush Set": {
      "te": "డస్ట్‌పాన్ (చెత్త ఎత్తేది)",
      "hi": "डस्टपैन",
      "ta": "குப்பை அள்ளும் முறம்",
      "kn": "ಡಸ್ಟ್ಪ್ಯಾನ್",
    },
    "Angled Plastic Toilet Brush Curved": {
      "te": "టాయిలెట్ బ్రష్",
      "hi": "टॉयलेट ब्रश",
      "ta": "கழிப்பறை பிரஷ்",
      "kn": "ಟಾಯ್ಲೆಟ್ ಬ್ರಷ್",
    },
    "Ceiling Cobweb Duster Brush Long Pole": {
      "te": "బూజు కర్ర / డస్టర్",
      "hi": "जाले साफ करने का ब्रश",
      "ta": "ஒட்டடை அடிக்கும் குச்சி",
      "kn": "ಜೇಡರ ಬಲೆ ಸ್ವಚ್ಛಗೊಳಿಸುವ ಕೋಲು",
    },
    "Rubber Sink Drain Plunger Small": {
      "te": "సింక్ ప్లంగర్ / పంపు క్లీనర్",
      "hi": "सिंक प्लंजर",
      "ta": "சிங்க் பிளங்கர்",
      "kn": "ಸಿಂಕ್ ಪ್ಲಂಜರ್",
    },
    "Garbage Bags Black Small 15L Pack": {
      "te": "చెత్త కవర్లు (చిన్నవి 15L)",
      "hi": "कचरा बैग (छोटा 15L)",
      "ta": "குப்பை பைகள் சிறியது",
      "kn": "ಕಸದ ಚೀಲಗಳು (ಸಣ್ಣ 15L)",
    },
    "Garbage Bags Black Medium 30L Pack": {
      "te": "చెత్త కవర్లు (మీడియం 30L)",
      "hi": "कचरा बैग (मीडियम 30L)",
      "ta": "குப்பை பைகள் (மீடியம்)",
      "kn": "ಕಸದ ಚೀಲಗಳು (ಮಧ್ಯಮ 30L)",
    },
    "Garbage Bags Black Large 60L Pack": {
      "te": "చెత్త కవర్లు (పెద్దవి 60L)",
      "hi": "कचरा बैग (बड़ा 60L)",
      "ta": "குப்பை பைகள் பெரியது",
      "kn": "ಕಸದ ಚೀಲಗಳು (ದೊಡ್ಡ 60L)",
    },
    "Dettol Handwash Liquid Pump Bottle": {
      "te": "డెట్టాల్ హ్యాండ్‌వాష్",
      "hi": "डेटॉल हैंडवॉश",
      "ta": "டெட்டால் ஹேண்ட்வாஷ்",
      "kn": "ಡೆಟ್ಟಾಲ್ ಹ್ಯಾಂಡ್ವಾಷ್",
    },
    "Lifebuoy Handwash Liquid Pump Bottle": {
      "te": "లైఫ్‌బాయ్ హ్యాండ్‌వాష్",
      "hi": "लाइफबॉय हैंडवॉश",
      "ta": "லைஃப்பாய் ஹேண்ட்வாஷ்",
      "kn": "ಲೈಫ್ಬಾಯ್ ಹ್ಯಾಂಡ್ವಾಷ್",
    },
    "Odonil Air Freshener Block Jasmine": {
      "te": "ఓడోనిల్ ఎయిర్ ఫ్రెషనర్",
      "hi": "ओडोनिल एयर फ्रेशनर",
      "ta": "ஓடோனில் ஏர் பிரெஷ்னர்",
      "kn": "ಓಡೋನಿಲ್ ಏರ್ ಫ್ರೆಶ್ನರ್",
    },
    "Room Air Freshener Spray Rose": {
      "te": "రూమ్ ఎయిర్ ఫ్రెషనర్ స్ప్రే (రోజ్)",
      "hi": "रूम एयर फ्रेशनर (गुलाब)",
      "ta": "ரூம் ஏர் பிரெஷ்னர்",
      "kn": "ರೂಮ್ ಏರ್ ಫ್ರೆಶ್ನರ್ (ಗುಲಾಬಿ)",
    },
    "Hit Black Insecticide Spray Cockroach": {
      "te": "హిట్ (బొద్దింకల స్ప్రే)",
      "hi": "हिट (कॉकरोच स्प्रे)",
      "ta": "ஹிட் கரப்பான் பூச்சி மருந்து",
      "kn": "ಹಿಟ್ ಜಿರಳೆ ಸ್ಪ್ರೇ",
    },
    "Hit Red Insecticide Spray Mosquito": {
      "te": "హిట్ (దోమల స్ప్రే)",
      "hi": "हिट (मच्छर स्प्रे)",
      "ta": "ஹிட் கொசு மருந்து",
      "kn": "ಹಿಟ್ ಸೊಳ್ಳೆ ಸ್ಪ್ರೇ",
    },
    "Rat Kill Cake Mortein Pack": {
      "te": "ఎలుకల మందు (మార్టీన్ కేక్)",
      "hi": "चूहे मारने की दवा (मॉर्टिन)",
      "ta": "எலி மருந்து",
      "kn": "ಇಲಿ ಪಾಷಾಣ (ಮಾರ್ಟಿನ್)",
    },
    "All Out Mosquito Repellent Liquid Refill": {
      "te": "ఆల్ అవుట్ లిక్విడ్",
      "hi": "ऑल आउट लिक्विड",
      "ta": "ஆல் அவுட் லிக்விட்",
      "kn": "ಆಲ್ ಔಟ್ ಲಿಕ್ವಿಡ್",
    },
    "White Naphthalene Balls 100g Pack": {
      "te": "నాఫ్తలీన్ బాల్స్ / డాంబరు బిళ్ళలు",
      "hi": "नेफ़थलीन बॉल्स / कपूर की गोली",
      "ta": "பாசான் உருண்டைகள்",
      "kn": "ಡಾಂಬರು ಗುಳಿಗೆಗಳು",
    },
    "Dettol Liquid Multi Use Disinfectant": {
      "te": "డెట్టాల్ లిక్విడ్",
      "hi": "डेटॉल लिक्विड",
      "ta": "டெட்டால் லிக்விட்",
      "kn": "ಡೆಟ್ಟಾಲ್ ಲಿಕ್ವಿಡ್",
    },
    "Comfort Fabric Conditioner Blue": {
      "te": "కంఫర్ట్ ఫ్యాబ్రిక్ కండిషనర్",
      "hi": "कंफर्ट फैब्रिक कंडीशनर",
      "ta": "கம்போர்ட் லிக்விட்",
      "kn": "ಕಂಫರ್ಟ್ ಫ್ಯಾಬ್ರಿಕ್ ಕಂಡೀಷನರ್",
    },
    "Caustic Soda Flakes Heavy Duty": {
      "te": "కాస్టిక్ సోడా",
      "hi": "कास्टिक सोडा",
      "ta": "காஸ்டிக் சோடா",
      "kn": "ಕಾಸ್ಟಿಕ್ ಸೋಡಾ",
    },
    "Washing Soda Soda Ash": {
      "te": "వాషింగ్ సోడా / చాకలి సోడా",
      "hi": "धोने का सोडा",
      "ta": "சலவை சோடா",
      "kn": "ವಾಷಿಂಗ್ ಸೋಡಾ",
    },
    "Vanish Stain Remover Powder Tub": {
      "te": "వానిష్ స్టెయిన్ రిమూవర్",
      "hi": "वैनिश स्टेन रिमूवर",
      "ta": "வானிஷ் பவுடர்",
      "kn": "ವ್ಯಾನಿಶ್ ಪೌಡರ್",
    },
    "Kitchen Paper Towel Roll Absorbent": {
      "te": "కిచెన్ పేపర్ టవల్ / టిష్యూ రోల్",
      "hi": "किचन पेपर टॉवल रोल",
      "ta": "கிச்சன் பேப்பர் ரோல்",
      "kn": "ಕಿಚನ್ ಪೇಪರ್ ಟವೆಲ್",
    },
    "Toilet Paper Tissue Roll 2-Ply Pack": {
      "te": "టాయిలెట్ పేపర్ రోల్",
      "hi": "टॉयलेट पेपर टिश्यू रोल",
      "ta": "கழிப்பறை பேப்பர் ரோல்",
      "kn": "ಟಾಯ್ಲೆಟ್ ಪೇಪರ್ ರೋಲ್",
    },
    "Pitambari Shining Powder Brass Copper": {
      "te": "పీతాంబరి పౌడర్",
      "hi": "पीतांबरी पाउडर",
      "ta": "பீதாம்பரி பவுடர்",
      "kn": "ಪೀತಾಂಬರಿ ಪುಡಿ",
    },
    "Liquid Degreaser Heavy Duty Commercial": {
      "te": "లిక్విడ్ డిగ్రీజర్",
      "hi": "लिक्विड डीग्रीजर",
      "ta": "லிக்விட் டிகிரீசர்",
      "kn": "ಲಿಕ್ವಿಡ್ ಡಿಗ್ರೀಸರ್",
    },
    "LED Bulb B22 9W Cool White": {
      "te": "ఎల్ఈడీ బల్బ్ 9W",
      "hi": "एलईडी बल्ब 9W",
      "ta": "எல்இடி பல்ப் 9W",
      "kn": "ಎಲ್ಇಡಿ ಬಲ್ಬ್ 9W",
    },
    "LED Bulb B22 12W Cool White": {
      "te": "ఎల్ఈడీ బల్బ్ 12W",
      "hi": "एलईडी बल्ब 12W",
      "ta": "எல்இடி பல்ப் 12W",
      "kn": "ಎಲ್ಇಡಿ ಬಲ್ಬ್ 12W",
    },
    "LED Tube Light Batten 20W 4ft": {
      "te": "ఎల్ఈడీ ట్యూబ్ లైట్ 20W",
      "hi": "एलईडी ट्यूब लाइट 20W",
      "ta": "எல்இடி டியூப் லைட் 20W",
      "kn": "ಎಲ್ಇಡಿ ಟ್ಯೂಬ್ ಲೈಟ್ 20W",
    },
    "Ceiling Fan Capacitor 2.5mfd 440V": {
      "te": "ఫ్యాన్ కెపాసిటర్ 2.5mfd",
      "hi": "पंखे का कैपेसिटर 2.5mfd",
      "ta": "மின்விசிறி மின்தேக்கி",
      "kn": "ಫ್ಯಾನ್ ಕೆಪಾಸಿಟರ್ 2.5mfd",
    },
    "Modular Fan Regulator Step Type": {
      "te": "ఫ్యాన్ రెగ్యులేటర్",
      "hi": "फैन रेगुलेटर",
      "ta": "மின்விசிறி ரெகுலேட்டர்",
      "kn": "ಫ್ಯಾನ್ ರೆಗುಲೇಟರ್",
    },
    "Modular Switch 6A 1-Way White": {
      "te": "స్విచ్ 6A",
      "hi": "स्विच 6A",
      "ta": "ஸ்விட்ச் 6A",
      "kn": "ಸ್ವಿಚ್ 6A",
    },
    "Modular Switch 16A 1-Way Power": {
      "te": "పవర్ స్విచ్ 16A",
      "hi": "पावर स्विच 16A",
      "ta": "பவர் ஸ்விட்ச் 16A",
      "kn": "ಪವರ್ ಸ್ವಿಚ್ 16A",
    },
    "Modular Socket 6A 3-Pin Shuttered": {
      "te": "సాకెట్ 6A (3-పిన్)",
      "hi": "सॉकेट 6A (3-पिन)",
      "ta": "சாக்கெட் 6A",
      "kn": "ಸಾಕೆಟ್ 6A",
    },
    "Modular Socket 16A 3-Pin Power Heavy": {
      "te": "పవర్ సాకెట్ 16A (3-పిన్)",
      "hi": "पावर सॉकेट 16A",
      "ta": "பவர் சாக்கெட் 16A",
      "kn": "ಪವರ್ ಸಾಕೆಟ್ 16A",
    },
    "Extension Board Spike Suppressor 4-Way": {
      "te": "ఎక్స్‌టెన్షన్ బోర్డ్ (4-వే)",
      "hi": "एक्सटेंशन बोर्ड (4-वे)",
      "ta": "எக்ஸ்டென்ஷன் போர்டு",
      "kn": "ಎಕ್ಸ್ಟೆನ್ಶನ್ ಬೋರ್ಡ್",
    },
    "MCB Single Pole 10A C-Curve": {
      "te": "ఎంసీబీ 10A (సింగిల్ పోల్)",
      "hi": "एमसीबी 10A",
      "ta": "எம்சிபி 10A",
      "kn": "ಎಂಸಿಬಿ 10A",
    },
    "MCB Single Pole 16A C-Curve": {
      "te": "ఎంసీబీ 16A (సింగిల్ పోల్)",
      "hi": "एमसीबी 16A",
      "ta": "எம்சிபி 16A",
      "kn": "ಎಂಸಿಬಿ 16A",
    },
    "MCB Single Pole 32A C-Curve": {
      "te": "ఎంసీబీ 32A (సింగిల్ పోల్)",
      "hi": "एमसीबी 32A",
      "ta": "எம்சிபி 32A",
      "kn": "ಎಂಸಿಬಿ 32A",
    },
    "Electrical PVC Insulation Tape Black Roll": {
      "te": "ఇన్సులేషన్ టేప్ (బ్లాక్)",
      "hi": "बिजली का टेप (काला)",
      "ta": "இன்சுலேஷன் டேப்",
      "kn": "ಇನ್ಸುಲೇಷನ್ ಟೇಪ್",
    },
    "PVC Bib Tap half-inch Threaded Basin": {
      "te": "పీవీసీ కుళాయి (టాప్)",
      "hi": "पीवीसी नल (टैप)",
      "ta": "பிவிசி குழாய்",
      "kn": "ಪಿವಿಸಿ ನಲ್ಲಿ",
    },
    "Brass Bib Tap half-inch Heavy Chrome": {
      "te": "ఇత్తడి కుళాయి (బ్రాస్ టాప్)",
      "hi": "पीतल का नल (ब्रास टैप)",
      "ta": "பித்தளை குழாய்",
      "kn": "ಹಿತ್ತಾಳೆ ನಲ್ಲಿ",
    },
    "Stainless Steel Angle Valve half-inch": {
      "te": "స్టీల్ యాంగిల్ వాల్వ్",
      "hi": "स्टील एंगल वाल्व",
      "ta": "ஸ்டீல் ஆங்கிள் வால்வு",
      "kn": "ಸ್ಟೀಲ್ ಆಂಗಲ್ ವಾಲ್ವ್",
    },
    "Health Faucet Gun Set with Hose Holder": {
      "te": "హెల్త్ ఫాసెట్ (గన్ సెట్)",
      "hi": "हेल्थ फॉसेट गन",
      "ta": "ஹெல்த் பாசெட்",
      "kn": "ಹೆಲ್ತ್ ಫಾಸೆಟ್ ಗನ್",
    },
    "Overhead Shower Head Round 4-inch": {
      "te": "షవర్ హెడ్ (4-ఇంచ్)",
      "hi": "शावर हेड (4-इंच)",
      "ta": "ஷவர் ஹெட்",
      "kn": "ಶವರ್ ಹெட்",
    },
    "SS Flexible Hose Pipe Connection 1m": {
      "te": "ఫ్లెక్సిబుల్ కనెక్షన్ పైప్ 1m",
      "hi": "कनेक्शन पाइप 1m",
      "ta": "கனெக்ஷன் பைப்",
      "kn": "ಕನೆಕ್ಷನ್ ಪೈಪ್",
    },
    "PTFE Teflon Thread Sealing Tape Roll": {
      "te": "టెఫ్లాన్ టేప్",
      "hi": "टेफ्लॉन टेप",
      "ta": "டெப்லான் டேப்",
      "kn": "ಟೆಫ್ಲಾನ್ ಟೇಪ್",
    },
    "PVC Wash Basin Flexible Waste Pipe": {
      "te": "వాష్ బేసిన్ వేస్ట్ పైప్",
      "hi": "वॉश बेसिन वेस्ट पाइप",
      "ta": "வாஷ் பேசின் பைப்",
      "kn": "ವಾಶ್ ಬೇಸಿನ್ ಪೈಪ್",
    },
    "Stainless Steel Sink Coupling Strainer": {
      "te": "సింక్ కప్లింగ్ జాలీ",
      "hi": "सिंक कपलिंग जाली",
      "ta": "சிங்க் கப்ளிங்",
      "kn": "ಸಿಂಕ್ ಕಪ್ಲಿಂಗ್",
    },
    "Plastic Ball Valve 1-inch Heavy Water": {
      "te": "ప్లాస్టిక్ బాల్ వాల్వ్ 1-ఇంచ్",
      "hi": "प्लास्टिक बॉल वाल्व 1-इंच",
      "ta": "பால் வால்வு",
      "kn": "ಬಾಲ್ ವಾಲ್ವ್",
    },
    "Water Tank Automatic Float Switch Sensor": {
      "te": "వాటర్ ట్యాంక్ ఆటోమేటిక్ సెన్సార్",
      "hi": "वाटर टैंक ऑटोमैटिक सेंसर",
      "ta": "வாட்டர் டேங்க் சென்சார்",
      "kn": "ವಾಟರ್ ಟ್ಯಾಂಕ್ ಸೆನ್ಸರ್",
    },
    "Plaster of Paris POP Repair Bag 1kg": {
      "te": "ప్లాస్టర్ ఆఫ్ పారిస్ (POP)",
      "hi": "प्लास्टर ऑफ पेरिस (POP)",
      "ta": "பிளாஸ்டர் ஆப் பாரிஸ்",
      "kn": "ಪ್ಲಾಸ್ಟರ್ ಆಫ್ ಪ್ಯಾರಿಸ್",
    },
    "Birla White Cement Wall Repair Bag 1kg": {
      "te": "వైట్ సిమెంట్ 1kg",
      "hi": "व्हाइट सीमेंट 1kg",
      "ta": "வெள்ளை சிமெண்ட்",
      "kn": "ಬಿಳಿ ಸಿಮೆಂಟ್",
    },
    "Wall Care Putty Acrylic Powder Bag 1kg": {
      "te": "వాల్ పుట్టీ 1kg",
      "hi": "वॉल पुट्टी 1kg",
      "ta": "வால் புட்டி",
      "kn": "ವಾಲ್ ಪುಟ್ಟಿ",
    },
    "Emery Paper Sandpaper Sheet Coarse Grit": {
      "te": "ఉప్పు కాగితం / సాండ్‌పేపర్",
      "hi": "रेगमार / सैंडपेपर",
      "ta": "உப்பு காகிதம்",
      "kn": "ಮರಳು ಕಾಗದ (ಸ್ಯಾಂಡ್ಪೇಪರ್)",
    },
    "Iron Wire Nails 1-inch Box": {
      "te": "ఇనుప మేకులు 1-ఇంచ్",
      "hi": "लोहे की कील 1-इंच",
      "ta": "இரும்பு ஆணிகள்",
      "kn": "ಕಬ್ಬಿಣದ ಮೊಳೆಗಳು",
    },
    "Wood Screws Assorted Steel Box": {
      "te": "చెక్క స్క్రూలు",
      "hi": "लकड़ी के पेंच (स्क्रू)",
      "ta": "மர திருகுகள்",
      "kn": "ಮರದ ಸ್ಕ್ರೂಗಳು",
    },
    "Rawl Plugs Plastic Anchor Assorted Box": {
      "te": "ప్లాస్టిక్ రాల్ ప్లగ్స్ (బుష్‌లు)",
      "hi": "प्लास्टिक गिट्टी (रॉवल प्लग)",
      "ta": "பிளாஸ்டிக் பிளக்",
      "kn": "ಪ್ಲಾಸ್ಟಿಕ್ ಪ್ಲಗ್ಗಳು",
    },
    "Door Closer Hydraulic Surface Mounted": {
      "te": "డోర్ క్లోజర్ (హైడ్రాలిక్)",
      "hi": "डोर क्लोजर",
      "ta": "டோர் குளோசர்",
      "kn": "ಡೋರ್ ಕ್ಲೋಸರ್",
    },
    "Brass Tower Bolt Door Latch 4-inch": {
      "te": "గడియ (టవర్ బోల్ట్ 4-ఇంచ్)",
      "hi": "चिटकनी / टावर बोल्ट",
      "ta": "தாழ்ப்பாள்",
      "kn": "ಬಾಗಿಲ ಚಿಲಕ",
    },
    "Godrej Navtal Brass Padlock 40mm": {
      "te": "తాళం కప్ప (గోద్రెజ్ 40mm)",
      "hi": "ताला (गोदरेज 40mm)",
      "ta": "பூட்டு 40mm",
      "kn": "ಬೀಗ (ಗೋದ್ರೇಜ್ 40mm)",
    },
    "Godrej Navtal Brass Padlock 50mm": {
      "te": "తాళం కప్ప (గోద్రెజ్ 50mm)",
      "hi": "ताला (गोदरेज 50mm)",
      "ta": "பூட்டு 50mm",
      "kn": "ಬೀಗ (ಗೋದ್ರೇಜ್ 50mm)",
    },
    "Key Ring Identification Tags Plastic Box": {
      "te": "కీ చైన్ ట్యాగ్స్",
      "hi": "चाबी के छल्ले टैग",
      "ta": "சாவி கொத்து டேக்",
      "kn": "ಕೀ ಚೈನ್ ಟ್ಯಾಗ್ಗಳು",
    },
    "WD-40 Rust Remover Multi-Purpose Spray": {
      "te": "WD-40 రస్ట్ స్ప్రే",
      "hi": "WD-40 जंग रोधक स्प्रे",
      "ta": "WD-40 ஸ்பிரே",
      "kn": "WD-40 ಸ್ಪ್ರೇ",
    },
    "Duracell Ultra AA Alkaline Batteries Pack": {
      "te": "డ్యూరాసెల్ AA బ్యాటరీలు",
      "hi": "ड्यूरासेल AA बैटरी",
      "ta": "AA பேட்டரிகள்",
      "kn": "AA ಬ್ಯಾಟರಿಗಳು",
    },
    "Duracell Ultra AAA Alkaline Batteries Pack": {
      "te": "డ్యూరాసెల్ AAA బ్యాటరీలు",
      "hi": "ड्यूरासेल AAA बैटरी",
      "ta": "AAA பேட்டரிகள்",
      "kn": "AAA ಬ್ಯಾಟರಿಗಳು",
    },
    "RO Water Purifier Spun Sediment Filter": {
      "te": "ఆర్ఓ ఫిల్టర్ (స్పున్)",
      "hi": "आरओ फिल्टर",
      "ta": "RO பில்டர்",
      "kn": "RO ಫಿಲ್ಟರ್",
    },
    "RO Water Purifier Activated Carbon Filter": {
      "te": "ఆర్ఓ కార్బన్ ఫిల్టర్",
      "hi": "आरओ कार्बन फिल्टर",
      "ta": "RO கார்பன் பில்டர்",
      "kn": "RO ಕಾರ್ಬನ್ ಫಿಲ್ಟರ್",
    },
    "Geyser Tubular Heating Element 2kW Copper": {
      "te": "గీజర్ కాయిల్ 2kW",
      "hi": "गीजर हीटिंग एलिमेंट 2kW",
      "ta": "கீசர் காயில்",
      "kn": "ಗೀಸರ್ ಕಾಯಿಲ್",
    },
    "Polycab Copper Wire 1.5sqmm Roll Blue": {
      "te": "కాపర్ వైర్ 1.5sqmm (పాలీక్యాబ్)",
      "hi": "कॉपर वायर 1.5sqmm",
      "ta": "காப்பர் வயர்",
      "kn": "ತಾಮ್ರದ ತಂತಿ 1.5sqmm",
    },
    "Calling Bell Ding-Dong Electronic Chime": {
      "te": "కాలింగ్ బెల్ (డింగ్-డాంగ్)",
      "hi": "कॉलिंग बेल / घंटी",
      "ta": "காலிங் பெல்",
      "kn": "ಕಾಲಿಂಗ್ ಬೆಲ್",
    },
    "Nylon Cable Ties 200mm Pack of 100": {
      "te": "కేబుల్ టైస్ (100 ప్యాక్)",
      "hi": "केबल टाई (100 पैक)",
      "ta": "கேபிள் டைஸ்",
      "kn": "ಕೇಬಲ್ ಟೈಗಳು",
    },
    "M-Seal Epoxy Putty Repair Compound": {
      "te": "ఎమ్-సీల్ (M-Seal)",
      "hi": "एम-सील (M-Seal)",
      "ta": "எம்-சீல்",
      "kn": "ಎಂ-ಸೀಲ್",
    },
    "Fevicol SH Synthetic Resin Adhesive 500g": {
      "te": "ఫెవికాల్ 500g",
      "hi": "फेविकोल 500g",
      "ta": "பெவிகால்",
      "kn": "ಫೆವಿಕಾಲ್",
    },
    "Clear Silicone Sealant Waterproof Tube": {
      "te": "సిలికాన్ సీలెంట్ ట్యూబ్",
      "hi": "सिलिकॉन सीलेंट ट्यूब",
      "ta": "சிலிகான் பேஸ்ட்",
      "kn": "ಸಿಲಿಕೋನ್ ಸೀಲಂಟ್",
    },
    "A4 Copier Paper Ream 70 GSM 500 Sheets": {
      "te": "ఏ4 పేపర్ బండిల్ (500 షీట్స్)",
      "hi": "A4 पेपर रिम (500 शीट)",
      "ta": "A4 பேப்பர் பண்டில்",
      "kn": "A4 ಪೇಪರ್ ಬಂಡಲ್",
    },
    "Ballpoint Pens Blue Medium Point Box of 10": {
      "te": "పెన్నులు (బ్లూ 10 బాక్స్)",
      "hi": "पेन बॉक्स (नीला 10)",
      "ta": "பேனாக்கள் பாக்ஸ்",
      "kn": "ಪೆನ್ಗಳ ಬಾಕ್ಸ್ (ನೀಲಿ)",
    },
    "Permanent Marker Pen Bullet Tip Black": {
      "te": "పర్మనెంట్ మార్కర్ (బ్లాక్)",
      "hi": "परमानेंट मार्कर (काला)",
      "ta": "பர்மனென்ட் மார்க்கர்",
      "kn": "ಪರ್ಮನೆಂಟ್ ಮಾರ್ಕರ್",
    },
    "Whiteboard Marker Pen Dry Erase Black": {
      "te": "వైట్‌బోర్డ్ మార్కర్ (బ్లాక్)",
      "hi": "व्हाइटबोर्ड मार्कर (काला)",
      "ta": "வைட்போர்டு மார்க்கர்",
      "kn": "ವೈಟ್ಬೋರ್ಡ್ ಮಾರ್ಕರ್",
    },
    "Attendance Register Hardbound Note Book": {
      "te": "హాజరు పట్టిక / అటెండెన్స్ రిజిస్టర్",
      "hi": "उपस्थिति रजिस्टर",
      "ta": "வருகை பதிவேடு",
      "kn": "ಹಾಜರಾತಿ ಪುಸ್ತಕ",
    },
    "Guest Entry Register Ledger Bound Book": {
      "te": "గెస్ట్ ఎంట్రీ రిజిస్టర్",
      "hi": "गेस्ट एंट्री रजिस्टर",
      "ta": "விருந்தினர் பதிவேடு",
      "kn": "ಅತಿಥಿ ಪ್ರವೇಶ ಪುಸ್ತಕ",
    },
    "Cash Book Accounting Ledger Register": {
      "te": "క్యాష్ బుక్ / లెడ్జర్",
      "hi": "कैश बुक / खाता बही",
      "ta": "பண பதிவேடு",
      "kn": "ಕ್ಯಾಶ್ ಬುಕ್",
    },
    "Carbonless Duplicate Bill Receipt Book": {
      "te": "బిల్ బుక్ / రసీదు పుస్తకం",
      "hi": "बिल बुक / रसीद बुक",
      "ta": "ரசீது புத்தகம்",
      "kn": "ಬಿಲ್ ಬುಕ್ / ರಸೀದಿ ಪುಸ್ತಕ",
    },
    "Plastic L-Folder Transparent File Cover": {
      "te": "ప్లాస్టిక్ ఎల్-ఫోల్డర్ / ఫైల్",
      "hi": "प्लास्टिक फाइल फोल्डर",
      "ta": "பிளாஸ்டிக் பைல்",
      "kn": "ಪ್ಲಾಸ್ಟಿಕ್ ಫೈಲ್",
    },
    "Kangaroo Desktop Stapler Machine No.10": {
      "te": "స్టేప్లర్ మిషన్ (కంగురు)",
      "hi": "स्टेपलर मशीन",
      "ta": "ஸ்டேப்லர் மெஷின்",
      "kn": "ಸ್ಟೇಪ್ಲರ್ ಯಂತ್ರ",
    },
    "Stapler Pin Wire Box No.10 Pack of 20": {
      "te": "స్టేప్లర్ పిన్స్ బాక్స్",
      "hi": "स्टेपलर पिन बॉक्स",
      "ta": "ஸ்டேப்லர் பின்கள்",
      "kn": "ಸ್ಟೇಪ್ಲರ್ ಪಿನ್ಗಳು",
    },
    "Paper Punching Machine 2-Hole Medium DP-52": {
      "te": "పేపర్ పంచింగ్ మిషన్",
      "hi": "पेपर पंचिंग मशीन",
      "ta": "பஞ்சிங் மெஷின்",
      "kn": "ಪೇಪರ್ ಪಂಚಿಂಗ್ ಯಂತ್ರ",
    },
    "Fevistik Solid Glue Stick Large 25g": {
      "te": "గమ్ స్టిక్ (ఫెవిస్టిక్)",
      "hi": "ग्लू स्टिक (फेविस्टिक)",
      "ta": "கம் ஸ்டிக்",
      "kn": "ಗ್ಲೂ ಸ್ಟಿಕ್",
    },
    "Transparent Cello Tape Roll 1-inch Wide": {
      "te": "సెల్లో టేప్ (ట్రాన్స్‌పరెంట్)",
      "hi": "सेलो टेप (पारदर्शी)",
      "ta": "செல்லோ டேப்",
      "kn": "ಸೆಲ್ಲೋ ಟೇಪ್",
    },
    "Brown Packaging BOPP Box Tape Roll 2-inch": {
      "te": "బ్రౌన్ టేప్ 2-ఇంచ్",
      "hi": "ब्राउन बॉक्स टेप 2-इंच",
      "ta": "பிரவுன் டேப்",
      "kn": "ಬ್ರೌನ್ ಟೇಪ್",
    },
    "Stainless Steel Office Scissors 8-inch": {
      "te": "కత్తెర (8-ఇంచ్)",
      "hi": "कैंची (8-इंच)",
      "ta": "கத்தரிக்கோல்",
      "kn": "ಕತ್ತರಿ (8-ಇಂಚ್)",
    },
    "Utility Box Cutter Snap-off Knife Heavy": {
      "te": "బాక్స్ కట్టర్ / చాకు",
      "hi": "बॉक्स कटर चाकू",
      "ta": "பாக்ஸ் கட்டர்",
      "kn": "ಬಾಕ್ಸ್ ಕಟರ್",
    },
    "Casio Desktop 12-Digit Solar Check Calculator": {
      "te": "క్యాలిక్యులేటర్ (కాసియో)",
      "hi": "कैलकुलेटर (कैसियो)",
      "ta": "கால்குலேட்டர்",
      "kn": "ಕ್ಯಾಲ್ಕುಲೇಟರ್",
    },
    "Rubber Bands Premium Half Kg Packet": {
      "te": "రబ్బర్ బ్యాండ్స్ (అర కిలో)",
      "hi": "रबर बैंड (आधा किलो)",
      "ta": "ரப்பர் பேண்ட்",
      "kn": "ರಬ್ಬರ್ ಬ್ಯಾಂಡ್ಗಳು",
    },
    "Staff ID Card Neck Lanyards Pack of 10": {
      "te": "ఐడీ కార్డ్ తాళ్ళు (10 ప్యాక్)",
      "hi": "स्टाफ आईडी कार्ड डोरी",
      "ta": "ID கார்டு கயிறு",
      "kn": "ಐಡಿ ಕಾರ್ಡ್ ಟ್ಯಾಗ್ಗಳು",
    },
    "Notice Board Push Pins Thumbtacks Box": {
      "te": "నోటీస్ బోర్డ్ పిన్స్",
      "hi": "नोटिस बोर्ड पिन",
      "ta": "போர்டு பின்கள்",
      "kn": "ನೋಟಿಸ್ ಬೋರ್ಡ್ ಪಿನ್ಗಳು",
    },
    "First Aid Band-Aid Waterproof Strips Box": {
      "te": "బ్యాండ్-ఎయిడ్ (ఫస్ట్ ఎయిడ్)",
      "hi": "बैंड-एड (प्राथमिक उपचार)",
      "ta": "பேண்ட் எய்ட்",
      "kn": "ಬ್ಯಾಂಡ್-ಏಡ್",
    },
    "Dettol Liquid Antiseptic Disinfectant 500ml": {
      "te": "డెట్టాల్ లిక్విడ్ 500ml",
      "hi": "डेटॉल लिक्विड 500ml",
      "ta": "டெட்டால் லிக்விட் 500ml",
      "kn": "ಡೆಟ್ಟಾಲ್ ಲಿಕ್ವಿಡ್ 500ml",
    },
    "Absorbent Surgical Cotton Wool Roll 100g": {
      "te": "దూది (సర్జికల్ కాటన్ 100g)",
      "hi": "रुई (सर्जिकल कॉटन 100g)",
      "ta": "பஞ்சு ரோல்",
      "kn": "ಹತ್ತಿ ರೋಲ್ 100g",
    },
    "Betadine Microbicidal Ointment Tube 20g": {
      "te": "బెటాడిన్ ఆయింట్‌మెంట్",
      "hi": "बीटाडीन मलहम (ऑइंटमेंट)",
      "ta": "பெட்டாடின் களிம்பு",
      "kn": "ಬೆಟಾಡಿನ್ ಮುಲಾಮು",
    },
    "Dolo 650mg Paracetamol Tablets Strip of 15": {
      "te": "డోలో 650mg (జ్వరం మాత్రలు)",
      "hi": "डोलो 650mg (बुखार की गोली)",
      "ta": "டோலோ 650mg மாத்திரை",
      "kn": "ಡೋಲೋ 650mg ಮಾತ್ರೆಗಳು",
    },
    "Electral ORS Electrolyte Powder Packets": {
      "te": "ఎలక్ట్రాల్ పౌడర్ (ORS)",
      "hi": "इलेक्ट्रॉल ओआरएस पाउडर",
      "ta": "எலக்ட்ரால் பவுடர்",
      "kn": "ಎಲೆಕ್ಟ್ರಾಲ್ ಪುಡಿ (ORS)",
    },
    "Burnol Burn Relief Antiseptic Ointment": {
      "te": "బర్నాల్ (కాలిన గాయాల మందు)",
      "hi": "बर्नोल (जलने का मलहम)",
      "ta": "பர்னால் களிம்பு",
      "kn": "ಬರ್ನಾಲ್ ಮುಲಾಮು",
    },
    "Volini Pain Relief Muscular Spray Can": {
      "te": "వోలిని స్ప్రే (నొప్పుల స్ప్రే)",
      "hi": "वोलिनी पेन रिलीफ स्प्रे",
      "ta": "வொலினி ஸ்பிரே",
      "kn": "ವೋಲಿನಿ ನೋವು ನಿವಾರಕ ಸ್ಪ್ರೇ",
    },
    "Cotton Crepe Elastic Bandage 10cm x 4m": {
      "te": "క్రేప్ బ్యాండేజ్ / కట్టు గుడ్డ",
      "hi": "क्रेप बैंडेज (गर्म पट्टी)",
      "ta": "கிரேப் பேண்டேஜ்",
      "kn": "ಕ್ರೇಪ್ ಬ್ಯಾಂಡೇಜ್",
    },
    "Digital LCD Clinical Fever Thermometer": {
      "te": "థర్మామీటర్ (జ్వరం కొలిచేది)",
      "hi": "थर्मामीटर",
      "ta": "வெப்பமானி (தெர்மோமீட்டர்)",
      "kn": "ಥರ್ಮಾಮೀಟರ್",
    },
    "Rechargeable LED Emergency Hand Torch Light": {
      "te": "టార్చ్ లైట్ (ఎమర్జెన్సీ లైట్)",
      "hi": "टॉर्च लाइट / इमरजेंसी लाइट",
      "ta": "டார்ச் லைட்",
      "kn": "ಟಾರ್ಚ್ ಲೈಟ್ (ಎಮರ್ಜೆನ್ಸಿ ದೀಪ)",
    },
    "Heavy Duty Metal Police Security Whistle": {
      "te": "విజిల్ / ఈల (సెక్యూరిటీ)",
      "hi": "सीटी (सिक्योरिटी व्हिसल)",
      "ta": "விசில்",
      "kn": "ಸಿಳ್ಳೆ (ಸೆಕ್ಯುರಿಟಿ ವಿಸಲ್)",
    },
    "Heavy Duty Waterproof PVC Raincoat Suit Set": {
      "te": "రెయిన్‌కోట్ సెట్",
      "hi": "रेनकोट सूट",
      "ta": "ரெயின்கோட்",
      "kn": "ರೈನ್ಕೋಟ್ ಸೆಟ್",
    },
    "Industrial Knee High Rubber Gum Boots Pair": {
      "te": "గమ్ బూట్స్ (రబ్బర్ బూట్లు)",
      "hi": "गम बूट (रबर के जूते)",
      "ta": "கம் பூட்ஸ்",
      "kn": "ರಬ್ಬರ್ ಗಮ್ ಬೂಟ್ಗಳು",
    },
    "Yellow Polyethylene Construction Safety Helmet": {
      "te": "సేఫ్టీ హెల్మెట్ (ఎల్లో)",
      "hi": "सेफ्टी हेलमेट (पीला)",
      "ta": "பாதுகாப்பு ஹெல்மெட்",
      "kn": "ಸುರಕ್ಷತಾ ಹೆಲ್ಮೆಟ್ (ಹಳದಿ)",
    },
    "Aluminium Foldable Step Ladder 6ft 5-Steps": {
      "te": "నిచ్చెన (అల్యూమినియం 6 అడుగులు)",
      "hi": "सीढ़ी (एल्युमीनियम 6 फीट)",
      "ta": "ஏணி 6 அடி",
      "kn": "ಏಣಿ (ಅಲ್ಯೂಮಿನಿಯಂ 6 ಅಡಿ)",
    },
    "Heavy Duty Folding Platform Hand Luggage Trolley": {
      "te": "ట్రాలీ (లగేజ్ మోసేది)",
      "hi": "सामान ढोने वाली ट्रॉली",
      "ta": "லக்கேஜ் ட்ரோலி",
      "kn": "ಲಗೇಜ್ ಟ್ರಾಲಿ",
    },
    "Pedal Plastic Dustbin Medium 15L White": {
      "te": "చెత్త బుట్ట (పెడల్ డస్ట్‌బిన్ 15L)",
      "hi": "कचरे का डिब्बा (पेडल 15L)",
      "ta": "குப்பை தொட்டி 15L",
      "kn": "ಕಸದ ಬುಟ್ಟಿ (15L)",
    },
    "Swing Top Plastic Dustbin Large 60L Blue": {
      "te": "పెద్ద చెత్త బుట్ట (60L)",
      "hi": "बड़ा डस्टबिन 60L",
      "ta": "பெரிய குப்பை தொட்டி 60L",
      "kn": "ದೊಡ್ಡ ಕಸದ ಬುಟ್ಟಿ (60L)",
    },
    "Garden Water PVC Hose Pipe 30m Roll Green": {
      "te": "గార్డెన్ వాటర్ పైప్ 30m",
      "hi": "गार्डन पानी का पाइप 30m",
      "ta": "கார்டன் பைப் 30m",
      "kn": "ಗಾರ್ಡನ್ ವಾಟರ್ ಪೈಪ್ 30m",
    },
    "Quartz Silent Sweep Wall Clock Office Round": {
      "te": "గోడ గడియారం",
      "hi": "दीवार घड़ी (वॉल क्लॉक)",
      "ta": "சுவர் கடிகாரம்",
      "kn": "ಗೋಡೆ ಗಡಿಯಾರ",
    },
    "Coir Heavy Welcome Mat Door Mat Large": {
      "te": "డోర్ మ్యాట్ (కాలి చాప)",
      "hi": "डोर मैट / पायदान",
      "ta": "கால் மிதி",
      "kn": "ಕಾಲೊರೆಸುವ ಚಾಪೆ (ಡೋರ್ ಮ್ಯಾಟ್)",
    },
    "Waterproof Single Bed Mattress Protector Cover": {
      "te": "పరుపు కవర్ (మ్యాట్రెస్ ప్రొటెక్టర్)",
      "hi": "गद्दे का कवर (वाटरप्रूफ)",
      "ta": "மெத்தை உறை",
      "kn": "ಹಾಸಿಗೆ ರಕ್ಷಕ ಕವರ್",
    },
    "Premium White Cotton Single Bed Sheet Flat": {
      "te": "బెడ్ షీట్ (సింగిల్ కాటన్)",
      "hi": "बेडशीट (सिंगल कॉटन)",
      "ta": "பெட்ஷீட்",
      "kn": "ಹಾಸಿಗೆ ಚಾದರ (ಬೆಡ್ಶೀಟ್)",
    },
    "Standard White Cotton Envelope Pillow Cover": {
      "te": "దిండు కవర్ (పిల్లో కవర్)",
      "hi": "तकिये का कवर (पिलो कवर)",
      "ta": "தலையணை உறை",
      "kn": "ದಿಂಬಿನ ಕವರ್",
    },
    "Fire Extinguisher ABC Dry Powder 4kg Cylinder": {
      "te": "ఫైర్ ఎక్స్‌టింగ్విషర్ 4kg",
      "hi": "अग्निशामक यंत्र (फायर सिलेंडर)",
      "ta": "தீயணைப்பு கருவி",
      "kn": "ಅಗ್ನಿಶಾಮಕ ಸಾಧನ (4kg)",
    },
    "Commercial LPG Cylinder Gas Pressure Regulator": {
      "te": "గ్యాస్ రెగ్యులేటర్ (కమర్షియల్)",
      "hi": "गैस रेगुलेटर (कमर्शियल)",
      "ta": "கேஸ் ரெகுலேட்டர்",
      "kn": "ಗ್ಯಾಸ್ ರೆಗುಲೇಟರ್",
    },
    "Desktop Call Bell Brass Concierge Desk Bell": {
      "te": "డెస్క్ కాలింగ్ బెల్ (గంట)",
      "hi": "डेस्क बेल / घंटी",
      "ta": "அழைப்பு மணி",
      "kn": "ಡೆಸ್ಕ್ ಬೆಲ್",
    },
    "Bill Receipt Holder Spike Paper Memo Holder": {
      "te": "బిల్ హోల్డర్ / స్పైక్",
      "hi": "बिल होल्डर / स्पाइक",
      "ta": "பில் ஹோல்டர்",
      "kn": "ಬಿಲ್ ಹೋಲ್ಡರ್",
    },
  };

  static String getLocalizedNameForString(String englishName, [String? langCode]) {
    if (langCode == null || langCode == 'en') return englishName;
    final map = stockTranslations[englishName];
    if (map != null && map[langCode] != null) {
      return map[langCode]!;
    }
    for (final key in stockTranslations.keys) {
      if (englishName.toLowerCase() == key.toLowerCase()) {
        if (stockTranslations[key]?[langCode] != null) {
          return stockTranslations[key]![langCode]!;
        }
      }
    }
    return englishName;
  }

  static String getLocalizedName(Map<String, String> item, [String? langCode]) {
    if (langCode == 'te' && item['nameTelugu'] != null) return item['nameTelugu']!;
    if (langCode == 'hi' && item['nameHindi'] != null) return item['nameHindi']!;
    if (langCode == 'ta' && item['nameTamil'] != null) return item['nameTamil']!;
    if (langCode == 'kn' && item['nameKannada'] != null) return item['nameKannada']!;
    final name = item['name'] ?? '';
    return getLocalizedNameForString(name, langCode);
  }

  static String getLocalizedNameForEntity(StockItem item, [String? langCode]) {
    if (langCode == 'te' && item.nameTelugu != null) return item.nameTelugu!;
    return getLocalizedNameForString(item.name, langCode);
  }
}