import 'package:stayindia_owner/features/profile/domain/entities/food_menu.dart';

class FoodConstants {
  static Map<String, String> t(String en, {String? hi, String? te, String? ta, String? kn}) {
    return {
      'en': en,
      'hi': hi ?? en,
      'te': te ?? en,
      'ta': ta ?? en,
      'kn': kn ?? en,
    };
  }

  static String getLocalizedCategory(String cat) {
    switch (cat) {
      case 'South Indian': return 'south_indian';
      case 'North Indian': return 'north_indian';
      case 'Common / Daily': return 'common_daily';
      case 'Breakfast': return 'meal_breakfast';
      case 'Lunch': return 'meal_lunch';
      case 'Dinner': return 'meal_dinner';
      case 'Snacks': return 'meal_snacks';
      default: return cat;
    }
  }

  static List<FoodItem> convertToFoodItems(List<dynamic> items) {
    return items.map((e) {
      final item = e as Map<String, dynamic>;
      return FoodItem(
        name: Map<String, String>.from(item['name']),
        desc: Map<String, String>.from(item['desc'] ?? {}),
        price: (item['price'] ?? 0.0).toDouble(),
        isVeg: item['isVeg'] ?? true,
        isActive: item['isActive'] ?? true,
      );
    }).toList();
  }

  static final Map<String, List<Map<String, dynamic>>> foodLibrary = {
    'Breakfast': [
      {'name': t('Idli Sambar', hi: 'इडली सांभर', te: 'ఇడ్లీ సాంబార్'), 'isVeg': true, 'desc': t('Steamed rice cakes with lentil soup')},
      {'name': t('Medhu Vada', hi: 'मेदू वड़ा', te: 'మేదు వడ'), 'isVeg': true, 'desc': t('Crispy lentil donuts')},
      {'name': t('Masala Dosa', hi: 'मसाला डोसा', te: 'మసాలా దోశ'), 'isVeg': true, 'desc': t('Dosa with potato filling')},
      {'name': t('Plain Dosa', hi: 'प्लेन डोसा', te: 'ప్లెయిన్ దోశ'), 'isVeg': true, 'desc': t('Crispy rice crepe')},
      {'name': t('Onion Dosa', hi: 'प्याज डोसा', te: 'ఉల్లి దోశ'), 'isVeg': true, 'desc': t('Dosa with chopped onions')},
      {'name': t('Rava Dosa', hi: 'रवा डोसा', te: 'రవ్వ దోశ'), 'isVeg': true, 'desc': t('Crispy semolina crepe')},
      {'name': t('Puri Bhaji', hi: 'पूरी भाजी', te: 'పూరి భాజీ'), 'isVeg': true, 'desc': t('Deep-fried bread with potato curry')},
      {'name': t('Upma', hi: 'उपमा', te: 'ఉప్మా'), 'isVeg': true, 'desc': t('Savory semolina porridge')},
      {'name': t('Poha', hi: 'पोहा', te: 'పోహా'), 'isVeg': true, 'desc': t('Flattened rice with spices')},
      {'name': t('Aloo Paratha', hi: 'आलू पराठा', te: 'ఆలు పరోటా'), 'isVeg': true, 'desc': t('Potato stuffed flatbread')},
      {'name': t('Paneer Paratha', hi: 'पनीर पराठा', te: 'పనీర్ పరోటా'), 'isVeg': true, 'desc': t('Paneer stuffed flatbread')},
      {'name': t('Gobi Paratha', hi: 'गोभी पराठा', te: 'గోబీ పరోటా'), 'isVeg': true, 'desc': t('Cauliflower stuffed flatbread')},
      {'name': t('Sabudana Khichdi', hi: 'साबूदाना खिचड़ी', te: 'సాబుదానా ఖిచిడీ'), 'isVeg': true, 'desc': t('Sago pearls with peanuts and spices')},
      {'name': t('Appam with Stew', hi: 'अप्पम और स्टू', te: 'అప్పం మరియు స్టూ'), 'isVeg': true, 'desc': t('Rice pancake with coconut milk stew')},
      {'name': t('Puttu Kadala', hi: 'पुट्टु और कडला', te: 'పుట్టు కడల'), 'isVeg': true, 'desc': t('Steamed rice flour with black chickpeas')},
      {'name': t('Bread Omelette', hi: 'ब्रेड आमलेट', te: 'బ్రెడ్ ఆమ్లెట్'), 'isVeg': false, 'desc': t('Spiced egg omelette with toasted bread')},
      {'name': t('Vegetable Sandwich', hi: 'वेज सैंडविच', te: 'వెజిటబుల్ శాండ్‌విచ్'), 'isVeg': true, 'desc': t('Bread with assorted vegetable filling')},
      {'name': t('Misal Pav', hi: 'मिसल पाव', te: 'మిసల్ పావ్'), 'isVeg': true, 'desc': t('Spicy sprout curry with bread rolls')},
      {'name': t('Pav Bhaji', hi: 'पाव भाजी', te: 'పావ్ భాజీ'), 'isVeg': true, 'desc': t('Mashed vegetable curry with buttered rolls')},
      {'name': t('Vada Pav', hi: 'वड़ा पाव', te: 'వడ పావ్'), 'isVeg': true, 'desc': t('Potato fritter in a bread roll')},
      {'name': t('Uttapam', hi: 'उत्तपम', te: 'ఉతప్పం'), 'isVeg': true, 'desc': t('Thick rice pancake with toppings')},
      {'name': t('Set Dosa', hi: 'सेट डोसा', te: 'సెట్ దోశ'), 'isVeg': true, 'desc': t('Soft and spongy mini dosas')},
      {'name': t('Pesarattu', hi: 'पेसरट्टू', te: 'పెసరట్టు'), 'isVeg': true, 'desc': t('Green gram crepe')},
      {'name': t('Ragi Mudde', hi: 'रागी मुद्दे', te: 'రాగి ముద్దె'), 'isVeg': true, 'desc': t('Finger millet balls')},
      {'name': t('Neer Dosa', hi: 'नीर डोसा', te: 'నీర్ దోశ'), 'isVeg': true, 'desc': t('Thin and lacy rice crepe')},
      {'name': t('Adai', hi: 'अडई', te: 'అడై'), 'isVeg': true, 'desc': t('Lentil and rice crepe')},
      {'name': t('Kachori', hi: 'कचौड़ी', te: 'కచోరీ'), 'isVeg': true, 'desc': t('Deep-fried spiced pastry')},
      {'name': t('Dhokla', hi: 'ढोकला', te: 'ధోక్లా'), 'isVeg': true, 'desc': t('Steamed fermented chickpea flour cake')},
      {'name': t('Khandvi', hi: 'खांडवी', te: 'ఖాండ్వీ'), 'isVeg': true, 'desc': t('Savory gram flour rolls')},
      {'name': t('Methi Thepla', hi: 'मेथी थेपला', te: 'మెంతి థెప్లా'), 'isVeg': true, 'desc': t('Flatbread with fenugreek leaves')},
      {'name': t('Chole Bhature', hi: 'छोले भटूरे', te: 'చోలే భటూరే'), 'isVeg': true, 'desc': t('Spicy chickpeas with deep-fried bread')},
      {'name': t('Kulcha', hi: 'कुलचा', te: 'కుల్చా'), 'isVeg': true, 'desc': t('Soft Indian leavened bread')},
      {'name': t('Stuffed Naan', hi: 'भरवां नान', te: 'స్టఫ్డ్ నాన్'), 'isVeg': true, 'desc': t('Naan with various fillings')},
      {'name': t('Muesli with Milk', hi: 'मूसली और दूध', te: 'మ్యూస్లీ మరియు పాలు'), 'isVeg': true, 'desc': t('Healthy oats and dry fruit mix')},
      {'name': t('Cornflakes', hi: 'कॉर्नफ्लेक्स', te: 'కార్న్‌ఫ్లేక్స్'), 'isVeg': true, 'desc': t('Cereal with milk')},
      {'name': t('Oatmeal', hi: 'ओटमील', te: 'ఓట్మీల్'), 'isVeg': true, 'desc': t('Cooked oats with toppings')},
      {'name': t('Fruit Salad', hi: 'फ्रूट सलाद', te: 'ఫ్రూట్ సలాడ్'), 'isVeg': true, 'desc': t('Fresh seasonal fruits')},
      {'name': t('Sprouted Moong', hi: 'अंकुरित मूंग', te: 'మొలకెత్తిన పెసలు'), 'isVeg': true, 'desc': t('Healthy steamed sprouts')},
      {'name': t('Besan Chilla', hi: 'बेसन चिल्ला', te: 'శెనగపిండి అట్టు'), 'isVeg': true, 'desc': t('Gram flour savory pancake')},
      {'name': t('Moong Dal Chilla', hi: 'मूंग दाल चिल्ला', te: 'పెసరట్టు'), 'isVeg': true, 'desc': t('Green gram savory pancake')},
      {'name': t('Akki Roti', hi: 'अक्की रोटी', te: 'అక్కి రొట్టె'), 'isVeg': true, 'desc': t('Rice flour flatbread')},
      {'name': t('Thalipeeth', hi: 'थालीपीठ', te: 'థాలిపీత్'), 'isVeg': true, 'desc': t('Multi-grain savory flatbread')},
      {'name': t('Dibba Rotti', hi: 'डिब्बा रोट्टी', te: 'దిబ్బ రొట్టి'), 'isVeg': true, 'desc': t('Thick rice and lentil cake')},
      {'name': t('Bobbatlu', hi: 'बोब्बटलु', te: 'బొబ్బట్లు'), 'isVeg': true, 'desc': t('Sweet stuffed flatbread')},
      {'name': t('Pongal', hi: 'पोंगल', te: 'పొంగల్'), 'isVeg': true, 'desc': t('Rice and lentil porridge')},
      {'name': t('Bisi Bele Bath', hi: 'बिसी बेले बाथ', te: 'బిసి బెలే బాత్'), 'isVeg': true, 'desc': t('Spicy rice and lentil dish')},
      {'name': t('Chow Chow Bath', hi: 'चाउ चाउ बाथ', te: 'చౌ చౌ బాత్'), 'isVeg': true, 'desc': t('Combo of Khara Bath and Kesari Bath')},
      {'name': t('Shavige Bath', hi: 'शाविगे बाथ', te: 'షావిగె బాత్'), 'isVeg': true, 'desc': t('Rice vermicelli savory dish')},
      {'name': t('Idiyappam', hi: 'इडियप्पम', te: 'ఇడియప్పం'), 'isVeg': true, 'desc': t('String hoppers rice noodles')},
      {'name': t('Paniyarams', hi: 'पनियारम', te: 'పనియారం'), 'isVeg': true, 'desc': t('Small steamed balls of batter')},
      {'name': t('Kozhukkatta', hi: 'कोझुकट्टा', te: 'కొలుకట్ట'), 'isVeg': true, 'desc': t('Steamed rice dumplings')},
      {'name': t('Sattu Paratha', hi: 'सत्तू पराठा', te: 'సత్తు పరోటా'), 'isVeg': true, 'desc': t('Flatbread stuffed with roasted gram flour')},
      {'name': t('Litti Chokha', hi: 'लिट्टी चोखा', te: 'లిట్టి చోఖా'), 'isVeg': true, 'desc': t('Roasted dough balls with mashed vegetables')},
      {'name': t('Bajra Roti', hi: 'बाजरा रोटी', te: 'సజ్జ రొట్టె'), 'isVeg': true, 'desc': t('Pearl millet flatbread')},
      {'name': t('Jowar Roti', hi: 'ज्वार रोटी', te: 'జొన్న రొట్టె'), 'isVeg': true, 'desc': t('Sorghum flatbread')},
      {'name': t('Ragi Roti', hi: 'रागी रोटी', te: 'రాగి రొట్టె'), 'isVeg': true, 'desc': t('Finger millet flatbread')},
      {'name': t('Makki di Roti', hi: 'मक्की दी रोटी', te: 'మక్కె రొట్టె'), 'isVeg': true, 'desc': t('Corn meal flatbread')},
      {'name': t('Bhakri', hi: 'भाकरी', te: 'భాక్రి'), 'isVeg': true, 'desc': t('Thick unleavened bread')},
      {'name': t('Koki', hi: 'कोकी', te: 'కోకి'), 'isVeg': true, 'desc': t('Sindhi style flatbread')},
      {'name': t('Sindhi Kadhi', hi: 'सिंधी कढ़ी', te: 'సింధీ కడి'), 'isVeg': true, 'desc': t('Tangy vegetable curry')},
      {'name': t('Dal Pakwan', hi: 'दाल पकवान', te: 'దాల్ పక్వాన్'), 'isVeg': true, 'desc': t('Crispy flatbread with spiced lentils')},
      {'name': t('Besan Bread Toast', hi: 'बेसन ब्रेड टोस्ट', te: 'శెనగపిండి బ్రెడ్ టోస్ట్'), 'isVeg': true, 'desc': t('Bread dipped in gram flour batter')},
      {'name': t('Egg Bhurji', hi: 'अंडा भुर्जी', te: 'గుడ్డు బుర్జీ'), 'isVeg': false, 'desc': t('Indian style scrambled eggs')},
      {'name': t('Scrambled Eggs', hi: 'स्क्रैम्बल अंडे', te: 'స్క్రాంబుల్డ్ ఎగ్స్'), 'isVeg': false, 'desc': t('Soft cooked scrambled eggs')},
      {'name': t('Boiled Eggs', hi: 'उबले हुए अंडे', te: 'ఉడికించిన గుడ్లు'), 'isVeg': false, 'desc': t('Hard or soft boiled eggs')},
      {'name': t('French Toast', hi: 'फ्रेंच टोस्ट', te: 'ఫ్రెంచ్ టోస్ట్'), 'isVeg': false, 'desc': t('Egg soaked toasted bread')},
      {'name': t('Pancakes', hi: 'पैनकेक', te: 'పాన్‌కేక్'), 'isVeg': true, 'desc': t('Fluffy pancakes with syrup')},
      {'name': t('Waffles', hi: 'वाफल', te: 'వాఫ్ఫెల్స్'), 'isVeg': true, 'desc': t('Crispy waffles with toppings')},
      {'name': t('Banana Bread', hi: 'बनाना ब्रेड', te: 'అరటి పండు బ్రెడ్'), 'isVeg': true, 'desc': t('Sweet bread with mashed bananas')},
      {'name': t('Muffins', hi: 'मफिन', te: 'మఫిన్'), 'isVeg': true, 'desc': t('Assorted sweet muffins')},
      {'name': t('Croissants', hi: 'क्रोइसैन', te: 'క్రోసెంట్'), 'isVeg': true, 'desc': t('Flaky buttery pastry')},
      {'name': t('Bagels', hi: 'बैगेल', te: 'బేగెల్'), 'isVeg': true, 'desc': t('Dense bread rings')},
      {'name': t('Danish Pastry', hi: 'डेनिश पेस्ट्री', te: 'డానిష్ పేస్ట్రీ'), 'isVeg': true, 'desc': t('Sweet laminated pastry')},
      {'name': t('Quiche', hi: 'कीश', te: 'క్విచ్'), 'isVeg': false, 'desc': t('Savory open pie')},
      {'name': t('Smoothie Bowl', hi: 'स्मूदी बाउल', te: 'స్మూతీ బౌల్'), 'isVeg': true, 'desc': t('Fruit smoothie with granola')},
      {'name': t('Chia Pudding', hi: 'चिया पुडिंग', te: 'చియా పుడ్డింగ్'), 'isVeg': true, 'desc': t('Healthy chia seed pudding')},
      {'name': t('Greek Yogurt', hi: 'ग्रीक योगर्ट', te: 'గ్రీక్ పెరుగు'), 'isVeg': true, 'desc': t('Thick creamy yogurt')},
      {'name': t('Granola', hi: 'ग्रैनोला', te: 'గ్రెనోలా'), 'isVeg': true, 'desc': t('Toasted oats and nuts')},
      {'name': t('Avocado Toast', hi: 'एवोकैडो टोस्ट', te: 'అవకాడో టోస్ట్'), 'isVeg': true, 'desc': t('Mashed avocado on toast')},
      {'name': t('Hummus and Pita', hi: 'हुमस और पीटा', te: 'హమ్మస్ మరియు పీటా'), 'isVeg': true, 'desc': t('Chickpea dip with pita bread')},
      {'name': t('Falafel', hi: 'फलाफेल', te: 'ఫలాఫెల్'), 'isVeg': true, 'desc': t('Deep fried chickpea balls')},
      {'name': t('Shakshuka', hi: 'शक्षुका', te: 'శక్షుక'), 'isVeg': false, 'desc': t('Poached eggs in spicy tomato sauce')},
      {'name': t('Breakfast Burrito', hi: 'ब्रेकफास्ट बुरिटो', te: 'బ్రేక్‌ఫాస్ట్ బురిటో'), 'isVeg': false, 'desc': t('Wrapped breakfast items in tortilla')},
      {'name': t('Quesadilla', hi: 'क्वेसाडिला', te: 'క్వసాడిల్లా'), 'isVeg': true, 'desc': t('Toasted tortilla with cheese')},
      {'name': t('Tacos', hi: 'टैकोस', te: 'టాకోస్'), 'isVeg': true, 'desc': t('Corn or flour tortillas with fillings')},
      {'name': t('Chilaquiles', hi: 'चिलीक्विलेस', te: 'చిలాక్విల్స్'), 'isVeg': true, 'desc': t('Mexican breakfast dish')},
      {'name': t('Enchiladas', hi: 'एन्चिलाडास', te: 'ఎంచిలాడాస్'), 'isVeg': true, 'desc': t('Corn tortillas with sauce')},
      {'name': t('Frittata', hi: 'फ्रिटाटा', te: 'ఫ్రిటాటా'), 'isVeg': false, 'desc': t('Italian egg-based dish')},
      {'name': t('Omelette', hi: 'आमलेट', te: 'ఆమ్లెట్'), 'isVeg': false, 'desc': t('Folded egg dish')},
      {'name': t('Egg Benedict', hi: 'अंडा बेनेडिक्ट', te: 'ఎగ్ బెనెడిక్ట్'), 'isVeg': false, 'desc': t('Poached eggs on English muffins')},
      {'name': t('English Breakfast', hi: 'इंग्लिश ब्रेकफास्ट', te: 'ఇంగ్లీష్ బ్రేక్‌ఫాస్ట్'), 'isVeg': false, 'desc': t('Classic English breakfast plate')},
      {'name': t('Continental Breakfast', hi: 'कॉन्टिनेंटल ब्रेकफास्ट', te: 'కాంటినెంటల్ బ్రేక్‌ఫాస్ట్'), 'isVeg': true, 'desc': t('Lighter morning meal options')},
      {'name': t('American Breakfast', hi: 'अमेरिकन ब्रेकफास्ट', te: 'అమెరికన్ బ్రేక్‌ఫాస్ట్'), 'isVeg': false, 'desc': t('Hearty American style breakfast')},
      {'name': t('Buffet Breakfast', hi: 'बुफे ब्रेकफास्ट', te: 'బఫె బ్రేక్‌ఫాస్ట్'), 'isVeg': true, 'desc': t('Assorted breakfast spread')},
      {'name': t('Healthy Breakfast', hi: 'हेल्दी ब्रेकफास्ट', te: 'ఆరోగ్యకరమైన బ్రేక్‌ఫాస్ట్'), 'isVeg': true, 'desc': t('Nutritious breakfast options')},
    ],
    'Lunch': [
      {'name': t('Steamed Rice', hi: 'चावल', te: 'స్టీమ్డ్ రైస్'), 'isVeg': true, 'desc': t('Freshly cooked white rice')},
      {'name': t('Jeera Rice', hi: 'जीरा राइस', te: 'జీరా రైస్'), 'isVeg': true, 'desc': t('Rice flavored with cumin seeds')},
      {'name': t('Vegetable Pulao', hi: 'वेज पुलाव', te: 'వెజిటబుల్ పులావ్'), 'isVeg': true, 'desc': t('Fragrant rice with mixed vegetables')},
      {'name': t('Paneer Biryani', hi: 'पनीर बिरयानी', te: 'పనీర్ బిర్యానీ'), 'isVeg': true, 'desc': t('Spiced rice with paneer cubes')},
      {'name': t('Hyderabadi Veg Biryani', hi: 'हैदराबादी वेज बिरयानी', te: 'హైదరాబాదీ వెజ్ బిర్యానీ'), 'isVeg': true, 'desc': t('Aromatic Hyderabadi style veg biryani')},
      {'name': t('Lemon Rice', hi: 'लेमन राइस', te: 'నిమ్మకాయ పులిహోర'), 'isVeg': true, 'desc': t('Tangy rice with lemon and spices')},
      {'name': t('Tamarind Rice', hi: 'इमली राइस', te: 'చింతపండు పులిహోర'), 'isVeg': true, 'desc': t('Traditional south Indian tangy rice')},
      {'name': t('Curd Rice', hi: 'दही चावल', te: 'పెరుగన్నం'), 'isVeg': true, 'desc': t('Rice mixed with yogurt and tempered')},
      {'name': t('Tomato Rice', hi: 'टमाटर राइस', te: 'టమోటా రైస్'), 'isVeg': true, 'desc': t('Spiced rice with tomato base')},
      {'name': t('Coconut Rice', hi: 'कोकोनट राइस', te: 'కొబ్బరి అన్నం'), 'isVeg': true, 'desc': t('Rice flavored with fresh coconut')},
      {'name': t('Dal Tadka', hi: 'दाल तड़का', te: 'దాల్ తడ్కా'), 'isVeg': true, 'desc': t('Yellow lentils with tempering')},
      {'name': t('Dal Makhani', hi: 'दाल मखनी', te: 'దాల్ మఖానీ'), 'isVeg': true, 'desc': t('Creamy black lentils')},
      {'name': t('Sambar', hi: 'सांभर', te: 'సాంబార్'), 'isVeg': true, 'desc': t('Lentil-based vegetable stew')},
      {'name': t('Rasam', hi: 'रसम', te: 'రసం'), 'isVeg': true, 'desc': t('Spicy and tangy soup')},
      {'name': t('Pappu Charu', hi: 'पप्पू चारु', te: 'పప్పు చారు'), 'isVeg': true, 'desc': t('Andhra style lentil soup')},
      {'name': t('Gutti Vankaya', hi: 'गुट्टी वंकाया', te: 'గుత్తి వంకాయ'), 'isVeg': true, 'desc': t('Stuffed brinjal curry')},
      {'name': t('Majjiga Pulusu', hi: 'मज्जिగా पुलुसु', te: 'మజ్జిగ పులుసు'), 'isVeg': true, 'desc': t('Buttermilk based vegetable curry')},
      {'name': t('Paneer Butter Masala', hi: 'पनीर बटर मसाला', te: 'పనీర్ బట్టర్ మసాలా'), 'isVeg': true, 'desc': t('Paneer in rich tomato gravy')},
      {'name': t('Palak Paneer', hi: 'पालक पनीर', te: 'పాలక్ పనీర్'), 'isVeg': true, 'desc': t('Paneer in spinach gravy')},
      {'name': t('Kadai Paneer', hi: 'कढ़ाई पनीर', te: 'కడాయి పనీర్'), 'isVeg': true, 'desc': t('Paneer cooked in a kadai with bell peppers')},
      {'name': t('Mutter Paneer', hi: 'मटर पनीर', te: 'మటర్ పనీర్'), 'isVeg': true, 'desc': t('Paneer and peas curry')},
      {'name': t('Mixed Veg Curry', hi: 'मिक्स वेज करी', te: 'మిక్స్‌డ్ వెజ్ కర్రీ'), 'isVeg': true, 'desc': t('Assorted vegetables in spiced gravy')},
      {'name': t('Aloo Gobi', hi: 'आलू गोभी', te: 'ఆలు గోబీ'), 'isVeg': true, 'desc': t('Potato and cauliflower dry curry')},
      {'name': t('Aloo Mutter', hi: 'आलू मटर', te: 'ఆలు మటర్'), 'isVeg': true, 'desc': t('Potato and peas curry')},
      {'name': t('Bhindi Masala', hi: 'भिंडी मसाला', te: 'బెండకాయ మసాలా'), 'isVeg': true, 'desc': t('Spiced okra fry')},
      {'name': t('Baingan Bharta', hi: 'बैंगन भरता', te: 'వంకాయ భర్తా'), 'isVeg': true, 'desc': t('Smoked mashed eggplant')},
      {'name': t('Chole Masala', hi: 'छोले मसाला', te: 'చోలే మసాలా'), 'isVeg': true, 'desc': t('Spicy chickpea curry')},
      {'name': t('Rajma Chawal', hi: 'राजमा चावल', te: 'రాజ్మా చావల్'), 'isVeg': true, 'desc': t('Kidney bean curry with rice')},
      {'name': t('Veg Jalfrezi', hi: 'वेज जलफ्रेजी', te: 'వెజ్ జల్‌ఫ్రేజీ'), 'isVeg': true, 'desc': t('Tangy mixed vegetable stir-fry')},
      {'name': t('Navratan Korma', hi: 'नवरत्न कोरमा', te: 'నవరత్న కోర్మా'), 'isVeg': true, 'desc': t('Nine gems vegetable korma')},
      {'name': t('Malai Kofta', hi: 'मलाई कोफ्ता', te: 'మలై కోఫ్తా'), 'isVeg': true, 'desc': t('Deep fried balls in creamy gravy')},
      {'name': t('Dum Aloo', hi: 'दम आलू', te: 'దమ్ ఆలూ'), 'isVeg': true, 'desc': t('Slow cooked spiced potatoes')},
      {'name': t('Chana Masala', hi: 'चना मसाला', te: 'చనా మసాలా'), 'isVeg': true, 'desc': t('Spiced chickpeas')},
      {'name': t('Mushroom Masala', hi: 'मशरूम मसाला', te: 'మష్రూమ్ మసాలా'), 'isVeg': true, 'desc': t('Spiced mushroom curry')},
      {'name': t('Gobi Manchurian Curry', hi: 'गोभी मंचूरियन करी', te: 'గోబీ మంచూరియన్ కర్రీ'), 'isVeg': true, 'desc': t('Indo-chinese cauliflower curry')},
      {'name': t('Baby Corn Masala', hi: 'बेबी कॉर्न मसाला', te: 'బేబీ కార్న్ మసాలా'), 'isVeg': true, 'desc': t('Spiced baby corn gravy')},
      {'name': t('Capsicum Masala', hi: 'कैप्सिकम मसाला', te: 'క్యాప్సికమ్ మసాలా'), 'isVeg': true, 'desc': t('Spiced bell pepper curry')},
      {'name': t('Methi Mutter Malai', hi: 'मेथी मटर मलाई', te: 'మెంతి మటర్ మలై'), 'isVeg': true, 'desc': t('Fenugreek and peas in cream')},
      {'name': t('Kaju Curry', hi: 'काजू करी', te: 'జీడిపప్పు కర్రీ'), 'isVeg': true, 'desc': t('Rich cashew nut gravy')},
      {'name': t('Stuffed Baingan', hi: 'भरवां बैंगन', te: 'స్టఫ్డ్ వంకాయ'), 'isVeg': true, 'desc': t('Eggplant with spice filling')},
      {'name': t('Aloo Fry', hi: 'आलू फ्राई', te: 'ఆలూ ఫ్రై'), 'isVeg': true, 'desc': t('Deep fried spiced potatoes')},
      {'name': t('Bendakaya Fry', hi: 'भिंडी फ्राई', te: 'బెండకాయ వేపుడు'), 'isVeg': true, 'desc': t('Crispy okra stir-fry')},
      {'name': t('Vankaya Fry', hi: 'बैंगन फ्राई', te: 'వంకాయ వేపుడు'), 'isVeg': true, 'desc': t('Eggplant stir-fry')},
      {'name': t('Dondakaya Fry', hi: 'कुंदरू फ्राई', te: 'దొండకాయ వేపుడు'), 'isVeg': true, 'desc': t('Ivy gourd stir-fry')},
      {'name': t('Aratikaya Fry', hi: 'कच्चे केले का फ्राई', te: 'అరటికాయ వేపుడు'), 'isVeg': true, 'desc': t('Raw banana stir-fry')},
      {'name': t('Chapati', hi: 'चपाती', te: 'చపాతీ'), 'isVeg': true, 'desc': t('Indian whole wheat flatbread')},
      {'name': t('Naan', hi: 'नान', te: 'నాన్'), 'isVeg': true, 'desc': t('Leavened oven-baked flatbread')},
      {'name': t('Veg Thali', hi: 'वेज थाली', te: 'వెజ్ థాలి'), 'isVeg': true, 'desc': t('Complete Indian meal platter')},
      {'name': t('South Indian Thali', hi: 'साउथ इंडियन थाली', te: 'సౌత్ ఇండియన్ థాలి'), 'isVeg': true, 'desc': t('Southern style meal platter')},
      {'name': t('Andhra Thali', hi: 'आंध्र थाली', te: 'ఆంధ్రా థాలి'), 'isVeg': true, 'desc': t('Spicy Andhra style meal')},
    ],
    'Snacks': [
      {'name': t('Samosa', hi: 'समौसा', te: 'సమోసా'), 'isVeg': true, 'desc': t('Crispy pastry with potato filling')},
      {'name': t('Onion Pakora', hi: 'प्याज पकोड़ा', te: 'ఉల్లి పకోడి'), 'isVeg': true, 'desc': t('Onion fritters')},
      {'name': t('Mirchi Bajji', hi: 'मिर्ची भाजी', te: 'మిర్చి బజ్జీ'), 'isVeg': true, 'desc': t('Spicy chili fritters')},
      {'name': t('Aloo Bonda', hi: 'आलू बोंडा', te: 'ఆలు బోండా'), 'isVeg': true, 'desc': t('Potato stuffed fried balls')},
      {'name': t('Mysore Bonda', hi: 'मैसूर बोंडा', te: 'మైసూర్ బోండా'), 'isVeg': true, 'desc': t('Deep fried flour balls')},
      {'name': t('Punugulu', hi: 'पुनुगुलु', te: 'పునుగులు'), 'isVeg': true, 'desc': t('Deep fried batter drops')},
      {'name': t('Gobi Manchurian', hi: 'गोभी मंचूरियन', te: 'గోబీ మంచూరియన్'), 'isVeg': true, 'desc': t('Crispy cauliflower in spicy sauce')},
      {'name': t('French Fries', hi: 'फ्रेंच फ्राइज', te: 'ఫ్రెంచ్ ఫ్రైస్'), 'isVeg': true, 'desc': t('Golden fried potato fingers')},
      {'name': t('Potato Chips', hi: 'आलू चिप्स', te: 'ఆలూ చిప్స్'), 'isVeg': true, 'desc': t('Crispy potato slices')},
      {'name': t('Dhokla', hi: 'ढोकला', te: 'ధోక్లా'), 'isVeg': true, 'desc': t('Gujarati steamed snack')},
      {'name': t('Paneer Tikka', hi: 'पनीर टिक्का', te: 'పనీర్ టిక్కా'), 'isVeg': true, 'desc': t('Grilled spiced paneer')},
      {'name': t('Veg Cutlet', hi: 'वेज कटलेट', te: 'వెజ్ కట్లెట్'), 'isVeg': true, 'desc': t('Fried vegetable patties')},
      {'name': t('Gulab Jamun', hi: 'गुलाब जामुन', te: 'గులాబ్ జామున్'), 'isVeg': true, 'desc': t('Sweet syrup soaked balls')},
      {'name': t('Jalebi', hi: 'जलेबी', te: 'జిలేబి'), 'isVeg': true, 'desc': t('Swirled deep fried dessert')},
      {'name': t('Pani Puri', hi: 'पानी पूरी', te: 'పానీ పూరి'), 'isVeg': true, 'desc': t('Crispy hollow balls with spicy water')},
      {'name': t('Bhel Puri', hi: 'भेल पूरी', te: 'భేల్ పూరి'), 'isVeg': true, 'desc': t('Puffed rice with tanginess')},
      {'name': t('Pav Bhaji', hi: 'पाव भाजी', te: 'పావ్ భాజీ'), 'isVeg': true, 'desc': t('Spiced mashed veg curry with bread')},
      {'name': t('Biscuits', hi: 'बिस्कुट', te: 'బిస్కెట్లు'), 'isVeg': true, 'desc': t('Crunchy baked snacks')},
      {'name': t('Tea', hi: 'चाय', te: 'టీ'), 'isVeg': true, 'desc': t('Classic Indian tea')},
      {'name': t('Coffee', hi: 'कॉफी', te: 'కాఫీ'), 'isVeg': true, 'desc': t('Hot brewed coffee')},
      {'name': t('Fruit Juice', hi: 'फलों का रस', te: 'ఫ్రూట్ జ్యూస్'), 'isVeg': true, 'desc': t('Freshly squeezed fruit juice')},
      {'name': t('Buttermilk', hi: 'छाछ', te: 'మజ్జిగ'), 'isVeg': true, 'desc': t('Refreshing yogurt drink')},
      {'name': t('Lassi', hi: 'लस्सी', te: 'లస్సీ'), 'isVeg': true, 'desc': t('Sweet creamy yogurt drink')},
      {'name': t('Coconut Water', hi: 'नारियल पानी', te: 'కొబ్బరి నీళ్లు'), 'isVeg': true, 'desc': t('Natural tender coconut water')},
      {'name': t('Popcorn', hi: 'पॉपकॉर्न', te: 'పాప్‌కార్న్'), 'isVeg': true, 'desc': t('Fluffy puffed corn')},
    ],
    'Dinner': [
      {'name': t('Dal Khichdi', hi: 'दाल खिचड़ी', te: 'దాల్ ఖిచిడీ'), 'isVeg': true, 'desc': t('Comforting rice and lentil mash')},
      {'name': t('Veg Fried Rice', hi: 'वेज फ्राइड राइस', te: 'వెజ్ ఫ్రైడ్ రైస్'), 'isVeg': true, 'desc': t('Stir-fried rice with veggies')},
      {'name': t('Paneer 65', hi: 'पनीर 65', te: 'పనీర్ 65'), 'isVeg': true, 'desc': t('Spicy deep fried paneer')},
      {'name': t('Veg Manchurian Wet', hi: 'वेज मंचूरियन वेट', te: 'వెజ్ మంచూరియన్ వెట్'), 'isVeg': true, 'desc': t('Veg balls in gravy')},
      {'name': t('Chilli Paneer', hi: 'चिली पनीर', te: 'చిల్లీ పనీర్'), 'isVeg': true, 'desc': t('Spicy Indo-chinese paneer')},
      {'name': t('Veg Hakka Noodles', hi: 'वेज हक्का नूडल्स', te: 'వెజ్ హక్కా నూడుల్స్'), 'isVeg': true, 'desc': t('Stir-fried noodles with veggies')},
      {'name': t('Pasta Red Sauce', hi: 'वेज पास्ता रेड सॉस', te: 'వెజ్ పాస్తా రెడ్ సాస్'), 'isVeg': true, 'desc': t('Pasta in tangy tomato sauce')},
      {'name': t('Lasagna', hi: 'लसग्ना', te: 'లసాగ్నా'), 'isVeg': true, 'desc': t('Layered pasta with cheese')},
      {'name': t('Thai Green Curry', hi: 'थाई ग्रीन करी', te: 'థాయ్ గ్రీన్ కర్రీ'), 'isVeg': true, 'desc': t('Spicy coconut milk curry')},
      {'name': t('Burrito', hi: 'बुरिटो', te: 'బురిటో'), 'isVeg': true, 'desc': t('Mexican wrapped meal')},
    ],
  };

  static final Map<String, List<Map<String, dynamic>>> southIndianTemplate = {
    'mon': [
      {'meal': 'Breakfast', 'items': [
        {'name': t('Idli Sambar', hi: 'इडली सांभर', te: 'ఇడ్లీ సాంబార్'), 'isVeg': true, 'desc': t('Steamed rice cakes')}
      ]},
    ],
    // ... more days
  };

  static final Map<String, List<Map<String, dynamic>>> northIndianTemplate = {
    'mon': [
      {'meal': 'Breakfast', 'items': [
        {'name': t('Aloo Paratha', hi: 'आलू पराठा', te: 'ఆలు పరోటా'), 'isVeg': true, 'desc': t('Spiced potato flatbread')}
      ]},
    ],
    // ... more days
  };
}
