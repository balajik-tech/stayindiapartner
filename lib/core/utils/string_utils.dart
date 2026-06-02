import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class StringUtils {
  static String formatRoomNumber(String rNum, [dynamic floor]) {
    String formatted = rNum
        .replaceAll(RegExp(r'^Room\s*', caseSensitive: false), '')
        .trim();

    bool isGroundFloor = false;
    if (floor != null) {
      if (floor is num && floor == 0) {
        isGroundFloor = true;
      } else if (floor is String) {
        final f = floor.toUpperCase();
        if (f == 'GROUND FLOOR' ||
            f == 'GROUND_FLOOR' ||
            f == 'ground_floor' ||
            f == '0' ||
            f == 'G') {
          isGroundFloor = true;
        }
      }
    }

    if (isGroundFloor) {
      if (formatted.startsWith('0')) {
        formatted = 'G${formatted.substring(1)}';
      } else if (!formatted.startsWith('G')) {
        formatted = 'G$formatted';
      }
    }

    return formatted;
  }

  static String translate(
    String key, {
    Map<String, String>? namedArgs,
    BuildContext? context,
  }) {
    if (key == 'floor_n') {
      final nStr = namedArgs?['n'] ?? '';
      final n = int.tryParse(nStr);
      if (n != null) {
        final String locale = context != null
            ? Localizations.localeOf(context).languageCode
            : 'en';
        if (locale == 'te') return '$nవ అంతస్తు';
        if (locale == 'hi') return '$nवीं मंजिल';
        if (locale == 'ml') return '$n-ാം നില';
        if (locale == 'kn') return '$nನೇ ಮಹಡಿ';
        if (locale == 'ta') return '$nவது மாடி';

        final suffix = (n % 10 == 1 && n % 100 != 11)
            ? 'st'
            : (n % 10 == 2 && n % 100 != 12)
            ? 'nd'
            : (n % 10 == 3 && n % 100 != 13)
            ? 'rd'
            : 'th';
        return '$n$suffix Floor';
      }
    }

    String translated = context != null
        ? key.tr(context: context, namedArgs: namedArgs)
        : key.tr(namedArgs: namedArgs);

    if (translated == key) {
      final String locale = context != null
          ? Localizations.localeOf(context).languageCode
          : 'en';

      if (key == 'ground_floor') {
        if (locale == 'te') return 'గ్రౌండ్ ఫ్లోర్';
        if (locale == 'hi') return 'ग्राउंड फ्लोर';
        if (locale == 'ml') return 'നിലം നില';
        return 'Ground Floor';
      }
      if (key == 'basement') {
        if (locale == 'te') return 'బేస్మెంట్';
        if (locale == 'hi') return 'तहखाना';
        if (locale == 'ml') return 'അടിത്തറ';
        if (locale == 'ta') return 'அடித்தளம்';
        if (locale == 'kn') return 'ನೆಲಮಾಳಿಗೆ';
        return 'Basement';
      }
      if (key == 'beds_free_count') {
        final free = namedArgs?['free'] ?? '0';
        final total = namedArgs?['total'] ?? '0';
        if (locale == 'te') return '$free / $total బెడ్లు ఖాళీగా ఉన్నాయి';
        if (locale == 'hi') return '$free / $total बिस्तर खाली हैं';
        if (locale == 'ml') return '$free / $total കിടക്കകൾ ലഭ്യമാണ്';
        return '$free / $total beds free';
      }
      if (key == 'available') {
        if (locale == 'te') return 'ఖాళీగా ఉంది';
        if (locale == 'hi') return 'उपलब्ध';
        if (locale == 'ta') return 'கிடைக்கிறது';
        if (locale == 'kn') return 'ಲಭ್ಯವಿದೆ';
        if (locale == 'ml') return 'ലഭ്യമാണ്';
        return 'Available';
      }
      if (key == 'price_per_month' || key == 'per_month') {
        if (locale == 'te') return ' / నెల';
        if (locale == 'hi') return ' / माह';
        if (locale == 'ml') return ' / മാസം';
        return ' / month';
      }
      if (key == 'daily_rate' || key == 'per_day') {
        if (locale == 'te') return ' / రోజు';
        if (locale == 'hi') return ' / दिन';
        if (locale == 'ml') return ' / ദിവസം';
        return ' / day';
      }
      if (key == 'sharing_type') return '${namedArgs?['count'] ?? ''} Sharing';
      if (key == 'ac' || key == 'amenity_ac') return 'AC';
      if (key == 'non-ac' || key == 'non_ac' || key == 'amenity_non_ac') {
        if (locale == 'te') return 'నాన్-ఏసి';
        if (locale == 'hi') return 'नॉन-एसी';
        if (locale == 'ta') return 'நான்-ஏசி';
        if (locale == 'kn') return 'ನಾನ್-ಎಸಿ';
        if (locale == 'ml') return 'നോൺ-എസി';
        return 'Non-AC';
      }
      if (key == 'sharing_double') {
        if (locale == 'te') return 'డబుల్';
        if (locale == 'hi') return 'डबल';
        if (locale == 'ta') return 'இரட்டை';
        if (locale == 'kn') return 'ಡಬಲ್';
        return 'Double';
      }
      if (key == 'sharing_triple') {
        if (locale == 'te') return 'ట్రిపుల్';
        if (locale == 'hi') return 'ट्रिपल';
        if (locale == 'ta') return 'மூன்று';
        if (locale == 'kn') return 'ತ್ರಿಪಲ್';
        return 'Triple';
      }
      if (key == 'sharing_quad') {
        if (locale == 'te') return '4 షేరింగ్';
        if (locale == 'hi') return '4 शेयरिंग';
        if (locale == 'ta') return '4 பகிர்வு';
        if (locale == 'kn') return '4 ಶೇರಿಂಗ್';
        return '4 Sharing';
      }
      if (key == 'maintenance_short') {
        if (locale == 'te') return 'మెయింటెనెన్స్';
        if (locale == 'hi') return 'रखरखाव';
        if (locale == 'ta') return 'பராமриப்பு';
        if (locale == 'kn') return 'ನಿರ್ವಹಣೆ';
        return 'Maint.';
      }
      if (key == 'btn_edit') {
        if (locale == 'te') return 'సవరించు';
        if (locale == 'hi') return 'संपादित करें';
        if (locale == 'ta') return 'திருத்து';
        if (locale == 'kn') return 'ತಿದ್ದು';
        return 'Edit';
      }
      if (key == 'btn_delete') {
        if (locale == 'te') return 'తొలగించు';
        if (locale == 'hi') return 'हटाएं';
        if (locale == 'ta') return 'அழி';
        if (locale == 'kn') return 'ಅಳಿಸು';
        return 'Delete';
      }
      if (key == 'no_staff_found') {
        if (locale == 'te') return 'ఎలాంటి సిబ్బంది కనుగొనబడలేదు';
        if (locale == 'hi') return 'कोई कर्मचारी नहीं मिला';
        if (locale == 'ta') return 'ஊழியர்கள் யாரும் காணப்படவில்லை';
        if (locale == 'kn') return 'ಯಾವುದೇ ಸಿಬ್ಬಂದಿ ಕಂಡುಬಂದಿಲ್ಲ';
        return 'No Staff Found';
      }
      if (key == 'add_staff_desc') {
        if (locale == 'te') {
          return 'వారి పాత్రలను నిర్వహించడానికి దయచేసి సిబ్బందిని జోడించండి.';
        }
        if (locale == 'hi') {
          return 'उनकी भूमिकाओं को प्रबंधित करने के लिए कृपया कर्मचारी जोड़ें।';
        }
        if (locale == 'ta') {
          return 'அவர்களின் பாத்திரங்களை நிர்வகிக்க ஊழியர்களைச் சேர்க்கவும்.';
        }
        if (locale == 'kn') {
          return 'ಅವರ ಪಾತ್ರಗಳನ್ನು ನಿರ್ವಹಿಸಲು ದಯವಿಟ್ಟು ಸಿಬ್ಬಂದಿ ಸದಸ್ಯರನ್ನು ಸೇರಿಸಿ.';
        }
        return 'Please add staff members to manage their roles.';
      }

      if (key == 'weekly_food_menu') {
        if (locale == 'te') return 'వారపు భోజన మెనూ';
        if (locale == 'ta') return 'வாராந்திர உணவு மெனு';
        if (locale == 'hi') return 'साप्ताहिक भोजन मेनू';
        if (locale == 'kn') return 'ಸಾಪ್ತಾಹಿಕ ಆಹಾರ ಮೆನು';
        if (locale == 'ml') return 'വാരപ്പടി ഭക്ഷണ മെനു';
        return 'Weekly Food Menu';
      }
      if (key == 'quick_setup') {
        if (locale == 'te') return 'త్వరిత సెటప్';
        if (locale == 'ta') return 'விரைவு அமைவு';
        if (locale == 'hi') return 'त्वरित सेटअप';
        if (locale == 'kn') return 'ತ್ವರಿತ ಸೆಟಪ್';
        if (locale == 'ml') return 'ദ്രുത സജ്ജീകരണം';
        return 'Quick Setup';
      }
      if (key == 'south_indian') {
        if (locale == 'te') return 'దక్షిణ భారతీయ';
        if (locale == 'ta') return 'தென்னிந்தியா';
        if (locale == 'hi') return 'दक्षिण भारतीय';
        if (locale == 'kn') return 'ದಕ್ಷಿಣ ಭಾರತದ';
        if (locale == 'ml') return 'തെന്നിന്ത്യൻ';
        return 'South Indian';
      }
      if (key == 'north_indian') {
        if (locale == 'te') return 'ఉత్తర భారతీయ';
        if (locale == 'ta') return 'வட இந்தியன்';
        if (locale == 'hi') return 'उत्तर भारतीय';
        if (locale == 'kn') return 'ಉತ್ತರ ಭಾರತದ';
        if (locale == 'ml') return 'വടക്കേ ഇന്ത്യൻ';
        return 'North Indian';
      }
      if (key == 'common_daily') {
        if (locale == 'te') return 'సాధారణ / రోజువారీ';
        if (locale == 'ta') return 'பொதுவான / தினசரி';
        if (locale == 'hi') return 'सामान्य / दैनिक';
        if (locale == 'kn') return 'ಸಾಮಾನ್ಯ / ದೈನಂದิน';
        if (locale == 'ml') return 'பொതുവായ / ദിവസേനയുള്ള';
        return 'Common / Daily';
      }
      if (key == 'add_dish') {
        if (locale == 'te') return 'డిష్ జోడించండి';
        if (locale == 'ta') return 'டிஷ் சேர்க்கவும்';
        if (locale == 'hi') return 'डिश जोड़ें';
        if (locale == 'kn') return 'ಡಿಶ್ ಸೇರಿಸಿ';
        if (locale == 'ml') return 'വിഭവം ചേർക്കുക';
        return 'Add Dish';
      }
      if (key == 'add_dish_to_menu') {
        if (locale == 'te') return 'మెనూకు డిష్ జోడించండి';
        if (locale == 'ta') return 'மெனுவில் டிஷ் சேர்க்கவும்';
        if (locale == 'hi') return 'मेनू में डिश जोड़ें';
        if (locale == 'kn') return 'ಮೆನುಗೆ ಡಿಶ್ ಸೇರಿಸಿ';
        if (locale == 'ml') return 'മെനുവിൽ വിഭവം ചേർക്കുക';
        return 'Add Dish to Menu';
      }
      if (key == 'dish_name_label') {
        if (locale == 'te') return 'డిష్ పేరు *';
        if (locale == 'ta') return 'உணவின் பெயர் *';
        if (locale == 'hi') return 'डिश का नाम *';
        if (locale == 'kn') return 'ಡಿಶ್ ಹೆಸರು *';
        if (locale == 'ml') return 'വിഭവത്തിന്റെ പേര് *';
        return 'Dish Name *';
      }
      if (key == 'add_to_menu') {
        if (locale == 'te') return 'మెనూకు జోడించండి';
        if (locale == 'ta') return 'மெனுவில் சேர்';
        if (locale == 'hi') return 'मेनू में जोड़ें';
        if (locale == 'kn') return 'ಮೆನುಗೆ ಸೇರಿಸಿ';
        if (locale == 'ml') return 'മെനുവിലേക്ക് ചേർക്കുക';
        return 'Add to Menu';
      }
      if (key == 'dish_category_label') {
        if (locale == 'te') return 'వర్గం';
        if (locale == 'ta') return 'வகை';
        if (locale == 'hi') return 'श्रेणी';
        if (locale == 'kn') return 'ವರ್ಗ';
        if (locale == 'ml') return 'വിഭാഗം';
        return 'Category';
      }
      if (key == 'veg') {
        if (locale == 'te') return 'వెజ్';
        if (locale == 'ta') return 'சைவம்';
        if (locale == 'hi') return 'शाकाहारी';
        if (locale == 'kn') return 'ಸಸ್ಯಾಹಾರಿ';
        if (locale == 'ml') return 'വെജ്';
        return 'Veg';
      }
      if (key == 'non_veg') {
        if (locale == 'te') return 'నాన్-వెజ్';
        if (locale == 'ta') return 'அசைவம்';
        if (locale == 'hi') return 'मांसाहारी';
        if (locale == 'kn') return 'ಮಾಂಸಾಹಾರಿ';
        if (locale == 'ml') return 'നോൺ-വെജ്';
        return 'Non-Veg';
      }
      if (key == 'dish_name_hint') {
        if (locale == 'te') return 'ఉదా. ఇడ్లీ సాంబార్';
        if (locale == 'ta') return 'எ.கா. இட்லி சாம்பார்';
        if (locale == 'hi') return 'जैसे इडली सांभर';
        if (locale == 'kn') return 'ಉದಾ. ಇಡ್ಲಿ సాంబార్';
        if (locale == 'ml') return 'ഉദാഹരണത്തിന് ഇഡ്‌ലി സാമ്പാർ';
        return 'e.g. Idli Sambar';
      }
      if (key == 'dish_description_label') {
        if (locale == 'te') return 'వివరణ';
        if (locale == 'ta') return 'விளக்கம்';
        if (locale == 'hi') return 'विवरण';
        if (locale == 'kn') return 'ವಿವರಣೆ';
        if (locale == 'ml') return 'വിവരണം';
        return 'Description';
      }
      if (key == 'dish_description_hint') {
        if (locale == 'te') return 'ఉదా. సాంబార్ & చట్నీతో సాఫ్ట్ ఇడ్లీలు';
        if (locale == 'ta') {
          return 'எ.கா. சாம்பார் மற்றும் சட்னியுடன் மென்மையான இட்லி';
        }
        if (locale == 'hi') return 'जैसे सांभर और चटनी के साथ नरम इडली';
        if (locale == 'kn') {
          return 'ಉದಾ. ಸಾಂಬಾರ್ ಮತ್ತು ಚಟ್ನಿಯೊಂದಿಗೆ ಸಾಫ್ಟ್ ಇಡ್ಲಿಗಳು';
        }
        if (locale == 'ml') {
          return 'ഉദാഹരണത്തിന് സാമ്പാറും ചട്നിയും കൂട്ടിയുള്ള മൃദുവായ ഇഡ്‌ലി';
        }
        return 'e.g. Soft idlis with sambar & chutney';
      }
      if (key == 'please_enter_dish_name') {
        if (locale == 'te') return 'దయచేసి డిష్ పేరును నమోదు చేయండి';
        if (locale == 'ta') return 'உணவின் பெயரை உள்ளிடவும்';
        if (locale == 'hi') return 'कृपया डिश का नाम दर्ज करें';
        if (locale == 'kn') return 'ದಯವಿಟ್ಟು ಡಿಶ್ ಹೆಸರನ್ನು ನಮೂದಿಸಿ';
        if (locale == 'ml') return 'വിഭവത്തിന്റെ പേര് നൽകുക';
        return 'Please enter a dish name';
      }
      if (key == 'template_applied_success') {
        if (locale == 'te') {
          return '{template} టెంప్లేట్ విజయవంతంగా వర్తింపజేయబడింది!';
        }
        if (locale == 'ta') {
          return '{template} டெம்ப்ளேட் வெற்றிகரமாகப் பயன்படுத்தப்பட்டது!';
        }
        if (locale == 'hi') {
          return '{template} टेम्पलेट सफलतापूर्वक लागू किया गया!';
        }
        if (locale == 'kn') {
          return '{template} ಟೆಂಪ್ಲೇಟ್ ಯಶಸ್ವಿಯಾಗಿ ಅನ್ವಯಿಸಲಾಗಿದೆ!';
        }
        if (locale == 'ml') {
          return '{template} ടെംപ്ലേറ്റ് വിജയകരമായി പ്രയോഗിച്ചു!';
        }
        return '{template} Template Applied Successfully!';
      }
      if (key == 'template_applied_failed') {
        if (locale == 'te') return 'టెంప్లేట్‌ను వర్తింపజేయడంలో విఫలమైంది';
        if (locale == 'ta') return 'டெம்ப்ளேட்டைப் பயன்படுத்துவதில் தோல்வி';
        if (locale == 'hi') return 'टेम्पलेट लागू करने में विफल';
        if (locale == 'kn') return 'ಟೆಂಪ್ಲೇಟ್ ಅನ್ವಯಿಸಲು ವಿಫಲವಾಗಿದೆ';
        if (locale == 'ml') {
          return 'ടെംപ്ലേറ്റ് പ്രയോഗിക്കുന്നതിൽ പരാജയപ്പെട്ടു';
        }
        return 'Failed to apply template';
      }
      if (key == 'no_dishes_for_meal') {
        if (locale == 'te') return '{meal} కోసం వంటకాలు ఏవీ జోడించబడలేదు';
        if (locale == 'ta') {
          return '{meal}க்கு உணவுகள் எதுவும் சேர்க்கப்படவில்லை';
        }
        if (locale == 'hi') return '{meal} के लिए कोई डिश नहीं जोड़ी गई';
        if (locale == 'kn') return '{meal} ಗೆ ಯಾವುದೇ ಡಿಶ್ ಸೇರಿಸಲಾಗಿಲ್ಲ';
        if (locale == 'ml') return '{meal} വിഭവങ്ങളൊന്നും ചേർത്തിട്ടില്ല';
        return 'No dishes added for {meal}';
      }
      if (key == 'add_dish_instruction') {
        if (locale == 'te') {
          return 'డిష్‌లను జోడించడానికి + క్లిక్ చేయండి లేదా టెంప్లేట్‌లను ఉపయోగించండి.';
        }
        if (locale == 'ta') {
          return 'உணவுகளைச் சேர்க்க அல்லது டெம்ப்ளேட்களைப் பயன்படுத்த + என்பதைக் கிளிக் செய்யவும்.';
        }
        if (locale == 'hi') {
          return 'डिश जोड़ने या टेम्पलेट का उपयोग करने के लिए + पर क्लिक करें।';
        }
        if (locale == 'kn') {
          return 'ಡಿಶ್ ಸೇರಿಸಲು ಅಥವಾ ಟೆಂಪ್ಲೇಟ್ ಬಳಸಲು + ಕ್ಲಿಕ್ ಮಾಡಿ.';
        }
        if (locale == 'ml') {
          return 'വിഭവങ്ങൾ ചേർക്കാൻ + ക്ലിക്ക് ചെയ്യുക അല്ലെങ്കിൽ ടെംപ്ലേറ്റുകൾ ഉപയോഗിക്കുക.';
        }
        return 'Click + to add dishes or use templates.';
      }
      if (key == 'meal_breakfast') {
        if (locale == 'te') return 'అల్పాహారం';
        if (locale == 'ta') return 'காலை உணவு';
        if (locale == 'hi') return 'नाश्ता';
        if (locale == 'kn') return 'ಉಪಹಾರ';
        if (locale == 'ml') return 'രാവിലെ ഭക്ഷണം';
        return 'Breakfast';
      }
      if (key == 'meal_lunch') {
        if (locale == 'te') return 'మధ్యాహ్న భోజనం';
        if (locale == 'ta') return 'மதிய உணவு';
        if (locale == 'hi') return 'दोपहर का भोजन';
        if (locale == 'kn') return 'ಊಟ';
        if (locale == 'ml') return 'ഉച്ചഭക്ഷണം';
        return 'Lunch';
      }
      if (key == 'meal_dinner') {
        if (locale == 'te') return 'రాత్రి భోజనం';
        if (locale == 'ta') return 'இரவு உணவு';
        if (locale == 'hi') return 'रात का खाना';
        if (locale == 'kn') return 'ರಾತ್ರಿ ಊಟ';
        if (locale == 'ml') return 'അത്താഴം';
        return 'Dinner';
      }
      if (key == 'meal_snacks') {
        if (locale == 'te') return 'స్నాక్స్';
        if (locale == 'ta') return 'சிற்றுண்டி';
        if (locale == 'hi') return 'नाश्ता / स्नैक्स';
        if (locale == 'kn') return 'ತಿಂಡಿಗಳು';
        if (locale == 'ml') return 'ചായ പലഹാരം';
        return 'Snacks';
      }
      if (key == 'performance_overview') {
        if (locale == 'te') return 'పనితీరు అవలోకనం';
        if (locale == 'ta') return 'செயல்திறன் கண்ணோட்டம்';
        if (locale == 'hi') return 'प्रदर्शन सिंहावलोकन';
        if (locale == 'kn') return 'ಕಾರ್ಯಕ್ಷಮತೆಯ ಅವಲೋಕನ';
        if (locale == 'ml') return 'പ്രവർത്തന അവലോകനം';
        return 'Performance Overview';
      }
      if (key == 'view_history') {
        if (locale == 'te') return 'చరిత్రను చూడండి';
        if (locale == 'ta') return 'வரலாற்றைக் காண்க';
        if (locale == 'hi') return 'इतिहास देखें';
        if (locale == 'kn') return 'ಇತಿಹಾಸವನ್ನು ವೀಕ್ಷಿಸಿ';
        if (locale == 'ml') return 'ചരിത്രം കാണുക';
        return 'View History';
      }
      if (key == 'real_time_data_hint') {
        if (locale == 'te') return 'మీ ప్రాపర్టీల నుండి రియల్ టైమ్ డేటా';
        if (locale == 'ta') return 'உங்கள் சொத்துக்களிலிருந்து நிகழ்நேர தரவு';
        if (locale == 'hi') return 'आपकी संपत्तियों से वास्तविक समय का डेटा';
        if (locale == 'kn') return 'ನಿಮ್ಮ ಗುಣಲಕ್ಷಣಗಳಿಂದ ನೈಜ-ಸಮಯದ ಡೇಟಾ';
        if (locale == 'ml') {
          return 'നിങ്ങളുടെ പ്രോപ്പർട്ടികളിൽ നിന്നുള്ള തത്സമയ ഡാറ്റ';
        }
        return 'Real-time data from your properties';
      }
      if (key == 'total_revenue') {
        if (locale == 'te') return 'మొత్తం ఆదాయం';
        if (locale == 'ta') return 'மொத்த வருவாய்';
        if (locale == 'hi') return 'कुल राजस्व';
        if (locale == 'kn') return 'ಒಟ್ಟು ಆದಾಯ';
        if (locale == 'ml') return 'ആകെ വരുമാനം';
        return 'Total Revenue';
      }
      if (key == 'this_month') {
        if (locale == 'te') return 'ఈ నెల';
        if (locale == 'ta') return 'இந்த மாதம்';
        if (locale == 'hi') return 'इस महीने';
        if (locale == 'kn') return 'ಈ ತಿಂಗಳು';
        if (locale == 'ml') return 'ഈ മാസം';
        return 'This Month';
      }
      if (key == 'occupancy') {
        if (locale == 'te') return 'ఆక్యుపెన్సీ';
        if (locale == 'ta') return 'ஆக்கிரமிப்பு';
        if (locale == 'hi') return 'अधिभोग';
        if (locale == 'kn') return 'ಆಕ್ಯುಪೆನ್ಸಿ';
        if (locale == 'ml') return 'ഒക്യുപ്പൻസി';
        return 'Occupancy';
      }
      if (key == 'pending') {
        if (locale == 'te') return 'పెండింగ్';
        if (locale == 'ta') return 'நிலுவையில் உள்ளது';
        if (locale == 'hi') return 'लंबित';
        if (locale == 'kn') return 'ಬಾಕಿ ಇದೆ';
        if (locale == 'ml') return 'തീർപ്പാക്കാത്തത്';
        return 'Pending';
      }
      if (key == 'security_deposit') {
        if (locale == 'te') return 'సెక్యూరిటీ డిపాజిట్';
        if (locale == 'ta') return 'பாதுகாப்பு வைப்பு';
        if (locale == 'hi') return 'सुरक्षा जमा';
        if (locale == 'kn') return 'ಭದ್ರತಾ ಠೇವಣಿ';
        if (locale == 'ml') return 'സെക്യൂരിറ്റി ഡെപ്പോസിറ്റ്';
        return 'Security Deposit';
      }
      if (key == 'maintenance') {
        if (locale == 'te') return 'నిర్వహణ';
        if (locale == 'ta') return 'பராமரிப்பு';
        if (locale == 'hi') return 'रखरखाव';
        if (locale == 'kn') return 'ನಿರ್ವಹಣೆ';
        if (locale == 'ml') return 'മെയിന്റനൻസ്';
        return 'Maintenance';
      }
      if (key == 'monthly_rent') {
        if (locale == 'te') return 'నెలవారీ అద్దె';
        if (locale == 'ta') return 'மாதாந்திர வாடகை';
        if (locale == 'hi') return 'मासिक किराया';
        if (locale == 'kn') return 'ಮಾಸಿಕ ಬಾಡಿಗೆ';
        if (locale == 'ml') return 'പ്രതിമാസ വാടക';
        return 'Monthly Rent';
      }
      if (key == 'revenue_breakdown') {
        if (locale == 'te') return 'ఆదాయ విభజన';
        if (locale == 'ta') return 'வருவாய் முறிவு';
        if (locale == 'hi') return 'राजस्व विवरण';
        if (locale == 'kn') return 'ಆದಾಯ ವಿಭಜನೆ';
        if (locale == 'ml') return 'വരുമാന വിഭജനം';
        return 'Revenue Breakdown';
      }
      if (key == 'revenue_distribution') {
        if (locale == 'te') return 'ఆదాయ పంపిణీ';
        if (locale == 'ta') return 'வருவாய் விநியோகம்';
        if (locale == 'hi') return 'राजस्व वितरण';
        if (locale == 'kn') return 'ಆದಾಯ ವಿತರಣೆ';
        if (locale == 'ml') return 'വരുമാന വിതരണം';
        return 'Revenue Distribution';
      }
      if (key == 'daily_rent') {
        if (locale == 'te') return 'రోజువారీ అద్దె';
        if (locale == 'ta') return 'தினசரி வாடகை';
        if (locale == 'hi') return 'दैनिक किराया';
        if (locale == 'kn') return 'ದೈನಂದಿನ ಬಾಡಿಗೆ';
        if (locale == 'ml') return 'പ്രതിദിന വാടക';
        return 'Daily Rent';
      }
      if (key == 'revenue_trends') {
        if (locale == 'te') return 'ఆదాయ పోకడలు';
        if (locale == 'ta') return 'வருவாய் போக்குகள்';
        if (locale == 'hi') return 'राजस्व रुझान';
        if (locale == 'kn') return 'ಆದಾಯದ ಪ್ರವೃತ್ತಿ';
        if (locale == 'ml') return 'വരുമാന പ്രവണതകൾ';
        return 'Revenue Trends';
      }
      if (key == 'daily_earnings_overview') {
        if (locale == 'te') return 'రోజువారీ ఆదాయ అవలోకనం';
        if (locale == 'ta') return 'தினசரி வருவாய் கண்ணோட்டம்';
        if (locale == 'hi') return 'दैनिक कमाई का अवलोकन';
        if (locale == 'kn') return 'ದೈನಂದಿನ ಗಳಿಕೆಯ ಅವಲೋಕನ';
        if (locale == 'ml') return 'ദിനപ്പടി വരുമാന അവലോകനം';
        return 'Daily earnings overview';
      }
      if (key == 'occupancy_vs_capacity') {
        if (locale == 'te') return 'ఆక్యుపెన్సీ వర్సెస్ కెపాసిటీ';
        if (locale == 'ta') return 'ஆக்கிரமிப்பு மற்றும் கொள்ளளவு';
        if (locale == 'hi') return 'अधिभोग बनाम क्षमता';
        if (locale == 'kn') return 'ಆಕ್ಯುಪೆನ್ಸಿ ವಿರುದ್ಧ ಸಾಮರ್ಥ್ಯ';
        if (locale == 'ml') return 'ഒക്യുപ്പൻസിയും കപ്പാസിറ്റിയും';
        return 'Occupancy vs Capacity';
      }
      if (key == 'edit_staff_details') {
        if (locale == 'te') return 'సిబ్బంది వివరాలను సవరించండి';
        if (locale == 'ta') return 'ஊழியர் விவரங்களை திருத்தவும்';
        if (locale == 'hi') return 'कर्मचारी विवरण संपादित करें';
        if (locale == 'kn') return 'ಸಿಬ್ಬಂದಿ ವಿವರಗಳನ್ನು ಸಂಪಾದಿಸಿ';
        if (locale == 'ml') return 'ജീവനക്കാരുടെ വിവരങ്ങൾ തിരുത്തുക';
        return 'Edit Staff Details';
      }
      if (key == 'add_new_staff') {
        if (locale == 'te') return 'కొత్త సిబ్బందిని చేర్చండి';
        if (locale == 'ta') return 'புதிய ஊழியரைச் சேர்க்கவும்';
        if (locale == 'hi') return 'नया स्टाफ जोड़ें';
        if (locale == 'kn') return 'ಹೊಸ ಸಿಬ್ಬಂದಿ ಸೇರಿಸಿ';
        if (locale == 'ml') return 'പുതിയ ജീവനക്കാരനെ ചേർക്കുക';
        return 'Add New Staff';
      }
      if (key == 'update_staff_info_desc') {
        if (locale == 'te') {
          return 'సిబ్బంది సమాచారం, ప్రొఫైల్ ఫోటో మరియు కేటాయించిన పాత్రను నవీకరించండి.';
        }
        if (locale == 'ta') {
          return 'ஊழியர் தகவல், சுயவிவரப் படம் மற்றும் நியமிக்கப்பட்ட பங்கை மாற்றியமைக்கவும்.';
        }
        if (locale == 'hi') {
          return 'कर्मचारी की जानकारी, प्रोफ़ाइल फ़ोटो और नामित भूमिका को अपडेट करें।';
        }
        if (locale == 'kn') {
          return 'ಸಿಬ್ಬಂದಿ ಮಾಹಿತಿ, ಪ್ರೊಫೈಲ್ ಫೋಟೋ ಮತ್ತು ಗೊತ್ತುಪಡಿಸಿದ ಪಾತ್ರವನ್ನು ನವೀಕರಿಸಿ.';
        }
        if (locale == 'ml') {
          return 'ജീവനക്കാരുടെ വിവരങ്ങൾ, പ്രൊഫൈൽ ഫോട്ടോ, ചുമതല എന്നിവ പുതുക്കുക.';
        }
        return 'Update staff information, profile photo, and designated role.';
      }
      if (key == 'enter_staff_details_desc') {
        if (locale == 'te') {
          return 'ఖాతాను సృష్టించడానికి సిబ్బంది వివరాలు మరియు చెల్లింపు సమాచారాన్ని నమోదు చేయండి.';
        }
        if (locale == 'ta') {
          return 'கணக்கை உருவாக்க ஊழியர் விவரங்கள் மற்றும் கட்டணத் தகவலை உள்ளிடவும்.';
        }
        if (locale == 'hi') {
          return 'खाता बनाने के लिए कर्मचारी विवरण और भुगतान जानकारी दर्ज करें।';
        }
        if (locale == 'kn') {
          return 'ಖಾತೆಯನ್ನು ರಚಿಸಲು ಸಿಬ್ಬಂದಿ ವಿವರಗಳು ಮತ್ತು ಪಾವತಿ ಮಾಹಿತಿಯನ್ನು ನಮೂದಿಸಿ.';
        }
        if (locale == 'ml') {
          return 'അക്കൗണ്ട് സൃഷ്ടിക്കാൻ ജീവനക്കാരുടെ വിവരങ്ങളും പേയ്‌മെന്റ് വിവരങ്ങളും നൽകുക.';
        }
        return 'Enter staff details and payment information to create an account.';
      }
      if (key == 'personal_info_section') {
        if (locale == 'te') return 'వ్యక్తిగత సమాచారం';
        if (locale == 'ta') return 'தனிப்பட்ட தகவல்';
        if (locale == 'hi') return 'व्यक्तिगत जानकारी';
        if (locale == 'kn') return 'ವೈಯಕ್ತಿಕ ಮಾಹಿತಿ';
        if (locale == 'ml') return 'വ്യക്തിഗത വിവരങ്ങൾ';
        return 'Personal Information';
      }
      if (key == 'full_name_label') {
        if (locale == 'te') return 'పూర్తి పేరు';
        if (locale == 'ta') return 'முழு பெயர்';
        if (locale == 'hi') return 'पूरा नाम';
        if (locale == 'kn') return 'ಪೂರ್ಣ ಹೆಸರು';
        if (locale == 'ml') return 'പൂർണ്ണനാമം';
        return 'Full Name';
      }
      if (key == 'enter_staff_name_hint') {
        if (locale == 'te') return 'సిబ్బంది పేరు నమోదు చేయండి';
        if (locale == 'ta') return 'ஊழியர் பெயரை உள்ளிடவும்';
        if (locale == 'hi') return 'कर्मचारी का नाम दर्ज करें';
        if (locale == 'kn') return 'ಸಿಬ್ಬಂದಿ ಹೆಸರನ್ನು ನಮೂದಿಸಿ';
        if (locale == 'ml') return 'ജീവനക്കാരന്റെ പേര് നൽകുക';
        return 'Enter staff name';
      }
      if (key == 'name_required_error') {
        if (locale == 'te') return 'పేరు తప్పనిసరి';
        if (locale == 'ta') return 'பெயர் தேவை';
        if (locale == 'hi') return 'नाम आवश्यक है';
        if (locale == 'kn') return 'ಹೆಸರು ಅಗತ್ಯವಿದೆ';
        if (locale == 'ml') return 'പേര് ആവശ്യമാണ്';
        return 'Name is required';
      }
      if (key == 'phone_number_label') {
        if (locale == 'te') return 'ఫోన్ నంబర్';
        if (locale == 'ta') return 'தொலைபேசி எண்';
        if (locale == 'hi') return 'फ़ोन नंबर';
        if (locale == 'kn') return 'ಫೋನ್ ಸಂಖ್ಯೆ';
        if (locale == 'ml') return 'ഫോൺ നമ്പർ';
        return 'Phone Number';
      }
      if (key == 'mobile_hint') {
        if (locale == 'te') return '10 అంకెల మొబైల్ సంఖ్య';
        if (locale == 'ta') return '10-இலக்க மொபைல் எண்';
        if (locale == 'hi') return '10-अंकीय मोबाइल नंबर';
        if (locale == 'kn') return '10-ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ';
        if (locale == 'ml') return '10 അക്ക മൊബൈൽ നമ്പർ';
        return '10-digit mobile number';
      }
      if (key == 'phone_required_error') {
        if (locale == 'te') return 'ఫోన్ నంబర్ తప్పనిసరి';
        if (locale == 'ta') return 'தொலைபேசி எண் தேவை';
        if (locale == 'hi') return 'फ़ोन आवश्यक है';
        if (locale == 'kn') return 'ಫೋನ್ ಅಗತ್ಯವಿದೆ';
        if (locale == 'ml') return 'ഫോൺ ആവശ്യമാണ്';
        return 'Phone is required';
      }
      if (key == 'phone_invalid_error') {
        if (locale == 'te') return '10 అంకెల సంఖ్యను నమోదు చేయండి';
        if (locale == 'ta') return '10 இலக்க எண்ணை உள்ளிடவும்';
        if (locale == 'hi') return '10-अंकीय नंबर दर्ज करें';
        if (locale == 'kn') return '10-ಅಂಕಿಯ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';
        if (locale == 'ml') return '10 അക്ക നമ്പർ നൽകുക';
        return 'Enter 10-digit number';
      }
      if (key == 'email_optional_label') {
        if (locale == 'te') return 'ఇమెయイル చిరునామా (ఐచ్ఛికం)';
        if (locale == 'ta') return 'மின்னஞ்சல் முகவரி (விருப்பத்திற்குரியது)';
        if (locale == 'hi') return 'ईमेल पता (वैकल्पिक)';
        if (locale == 'kn') return 'ಇಮೇಲ್ ವಿಳಾಸ (ಐಚ್ಛಿಕ)';
        if (locale == 'ml') return 'ഇമെയിൽ വിലാസം (ഓപ്ഷണൽ)';
        return 'Email Address (Optional)';
      }
      if (key == 'email_invalid_error') {
        if (locale == 'te') return 'చెల్లని ఇమెయిల్ ఫార్మాట్';
        if (locale == 'ta') return 'தவறான மின்னஞ்சல் வடிவம்';
        if (locale == 'hi') return 'अवैध ईमेल प्रारूप';
        if (locale == 'kn') return 'ಅಮಾನ್ಯ ಇಮೇಲ್ ಸ್ವರೂಪ';
        if (locale == 'ml') return 'അസാധുവായ ഇമെയിൽ ഫോർമാറ്റ്';
        return 'Invalid email format';
      }
      if (key == 'monthly_salary_label') {
        if (locale == 'te') return 'నెలవారీ జీతం';
        if (locale == 'ta') return 'மாதச் சம்பளம்';
        if (locale == 'hi') return 'मासिक वेतन';
        if (locale == 'kn') return 'ಮಾಸಿಕ ಸಂಬಳ';
        if (locale == 'ml') return 'പ്രതിമാസ ശമ്പളം';
        return 'Monthly Salary';
      }
      if (key == 'salary_hint') {
        if (locale == 'te') return 'ఉదా. 15000';
        if (locale == 'ta') return 'எ.கா. 15000';
        if (locale == 'hi') return 'जैसे 15000';
        if (locale == 'kn') return 'ಉದಾ. 15000';
        if (locale == 'ml') return 'ഉദാഹരണത്തിന് 15000';
        return 'e.g. 15000';
      }
      if (key == 'access_credentials_section') {
        if (locale == 'te') return 'యాక్సెస్ ఆధారాలు';
        if (locale == 'ta') return 'அணுகல் சான்றுகள்';
        if (locale == 'hi') return 'पहुंच क्रेडेंशियल';
        if (locale == 'kn') return 'ಪ್ರವೇಶ ರುಜುವಾತುಗಳು';
        if (locale == 'ml') return 'ആക്സസ് ക്രെഡൻഷ്യലുകൾ';
        return 'Access Credentials';
      }
      if (key == 'new_password_optional_label') {
        if (locale == 'te') return 'కొత్త పాస్‌వర్డ్ (ఐచ్ఛికం)';
        if (locale == 'ta') return 'புதிய கடவுச்சொல் (விருப்பத்திற்குரியது)';
        if (locale == 'hi') return 'नया पासवर्ड (वैकल्पिक)';
        if (locale == 'kn') return 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ (ಐಚ್ಛಿಕ)';
        if (locale == 'ml') return 'പുതിയ പാസ്‌വേഡ് (ഓപ്ഷണൽ)';
        return 'New Password (Optional)';
      }
      if (key == 'password_label') {
        if (locale == 'te') return 'పాస్‌వర్డ్';
        if (locale == 'ta') return 'கடவுச்சொல்';
        if (locale == 'hi') return 'पासवर्ड';
        if (locale == 'kn') return 'ಪಾಸ್‌ವರ್ಡ್';
        if (locale == 'ml') return 'പാസ്‌വേഡ്';
        return 'Password';
      }
      if (key == 'leave_blank_hint') {
        if (locale == 'te') return 'మార్పు లేకుండా ఉంచడానికి ఖాళీగా వదలండి';
        if (locale == 'ta') return 'மாற்றாமல் வைத்திருக்க காலியாக விடவும்';
        if (locale == 'hi') return 'अपरिवर्तित रखने के लिए खाली छोड़ें';
        if (locale == 'kn') return 'ಬದಲಾಗದೆ ಇರಿಸಲು ಖಾಲಿ ಬಿಡಿ';
        if (locale == 'ml') return 'മാറ്റമില്ലാതെ നിലനിർത്താൻ വെറുതെ വിടുക';
        return 'Leave blank to keep unchanged';
      }
      if (key == 'password_hint') {
        if (locale == 'te') return 'కనీసం 6 అక్షరాలు';
        if (locale == 'ta') return 'குறைந்தபட்சம் 6 எழுத்துக்கள்';
        if (locale == 'hi') return 'न्यूनतम 6 अक्षर';
        if (locale == 'kn') return 'ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳು';
        if (locale == 'ml') return 'കുറഞ്ഞത് 6 അക്ഷരങ്ങൾ';
        return 'Minimum 6 characters';
      }
      if (key == 'password_short_error') {
        if (locale == 'te') return 'కనీసం 6 అక్షరాలు ఉండాలి';
        if (locale == 'ta') {
          return 'குறைந்தபட்சம் 6 எழுத்துக்கள் இருக்க வேண்டும்';
        }
        if (locale == 'hi') return 'न्यूनतम 6 अक्षर होने चाहिए';
        if (locale == 'kn') return 'ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳಿರಬೇಕು';
        if (locale == 'ml') return 'കുറഞ്ഞത് 6 അക്ഷരങ്ങൾ വേണം';
        return 'Min 6 characters';
      }
      if (key == 'payment_details_section') {
        if (locale == 'te') return 'సిబ్బంది చెల్లింపు వివరాలు';
        if (locale == 'ta') return 'ஊழியர் கட்டண விவரங்கள்';
        if (locale == 'hi') return 'कर्मचारी भुगतान विवरण';
        if (locale == 'kn') return 'ಸಿಬ್ಬಂದಿ ಪಾವತಿ ವಿವರಗಳು';
        if (locale == 'ml') return 'ജീവനക്കാരുടെ പേയ്‌മെന്റ് വിവരങ്ങൾ';
        return 'Staff Payment Details';
      }
      if (key == 'upi_label') {
        if (locale == 'te') return 'UPI ID / PhonePe నంబర్';
        if (locale == 'ta') return 'UPI ஐடி / போன்பே எண்';
        if (locale == 'hi') return 'UPI आईडी / फोनपे नंबर';
        if (locale == 'kn') return 'ಯುಪಿಐ ಐಡಿ / ಫೋನ್‌ಪೇ ಸಂಖ್ಯೆ';
        if (locale == 'ml') return 'UPI ഐഡി / ഫോൺപേ നമ്പർ';
        return 'UPI ID / PhonePe Number';
      }
      if (key == 'upi_hint') {
        if (locale == 'te') return 'ఉదా. user@okaxis లేదా 9876543210';
        if (locale == 'ta') return 'எ.கா. user@okaxis அல்லது 9876543210';
        if (locale == 'hi') return 'जैसे user@okaxis या 9876543210';
        if (locale == 'kn') return 'ಉದಾ. user@okaxis ಅಥವಾ 9876543210';
        if (locale == 'ml') {
          return 'ഉദാഹരണത്തിന് user@okaxis അല്ലെങ്കിൽ 9876543210';
        }
        return 'e.g. user@okaxis or 9876543210';
      }
      if (key == 'bank_name_label') {
        if (locale == 'te') return 'బ్యాంక్ పేరు';
        if (locale == 'ta') return 'வங்கி பெயர்';
        if (locale == 'hi') return 'बैंक का नाम';
        if (locale == 'kn') return 'ಬ್ಯಾಂಕ್ ಹೆಸರು';
        if (locale == 'ml') return 'ബാങ്കിന്റെ പേര്';
        return 'Bank Name';
      }
      if (key == 'bank_name_hint') {
        if (locale == 'te') return 'ఉదా. SBI, HDFC';
        if (locale == 'ta') return 'எ.கா. SBI, HDFC';
        if (locale == 'hi') return 'जैसे SBI, HDFC';
        if (locale == 'kn') return 'ಉದಾ. SBI, HDFC';
        if (locale == 'ml') return 'ഉദാഹരണത്തിന് SBI, HDFC';
        return 'e.g. SBI, HDFC';
      }
      if (key == 'account_number_label') {
        if (locale == 'te') return 'ఖాతా సంఖ్య';
        if (locale == 'ta') return 'கணக்கு எண்';
        if (locale == 'hi') return 'खाता संख्या';
        if (locale == 'kn') return 'ಖಾತೆ ಸಂಖ್ಯೆ';
        if (locale == 'ml') return 'അക്കൗണ്ട് നമ്പർ';
        return 'Account Number';
      }
      if (key == 'account_number_hint') {
        if (locale == 'te') return 'బ్యాంక్ ఖాతా సంఖ్యను నమోదు చేయండి';
        if (locale == 'ta') return 'வங்கி கணக்கு எண்ணை உள்ளிடவும்';
        if (locale == 'hi') return 'बैंक खाता संख्या दर्ज करें';
        if (locale == 'kn') return 'ಬ್ಯಾಂಕ್ ಖಾತೆ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';
        if (locale == 'ml') return 'ബാങ്ക് അക്കൗണ്ട് നമ്പർ നൽകുക';
        return 'Enter bank account number';
      }
      if (key == 'ifsc_code_label') {
        if (locale == 'te') return 'IFSC కోడ్';
        if (locale == 'ta') return 'IFSC குறியீடு';
        if (locale == 'hi') return 'IFSC कोड';
        if (locale == 'kn') return 'ಐಎಫ್‌ಎಸ್‌ಸಿ ಕೋಡ್';
        if (locale == 'ml') return 'IFSC കോഡ്';
        return 'IFSC Code';
      }
      if (key == 'ifsc_hint') {
        if (locale == 'te') return 'ఉదా. SBIN0001234';
        if (locale == 'ta') return 'எ.கா. SBIN0001234';
        if (locale == 'hi') return 'जैसे SBIN0001234';
        if (locale == 'kn') return 'ಉದಾ. SBIN0001234';
        if (locale == 'ml') return 'ഉദാഹരണത്തിന് SBIN0001234';
        return 'e.g. SBIN0001234';
      }
      if (key == 'beneficiary_name_label') {
        if (locale == 'te') return 'లబ్ధిదారుని పేరు';
        if (locale == 'ta') return 'பயனாளியின் பெயர்';
        if (locale == 'hi') return 'लाभार्थी का नाम';
        if (locale == 'kn') return 'ಫಲಾನುಭವಿ ಹೆಸರು';
        if (locale == 'ml') return 'ഗുണഭോക്താവിന്റെ പേര്';
        return 'Beneficiary Name';
      }
      if (key == 'beneficiary_hint') {
        if (locale == 'te') return 'బ్యాంక్ రికార్డుల ప్రకారం పేరు';
        if (locale == 'ta') return 'வங்கி பதிவுகளின்படி பெயர்';
        if (locale == 'hi') return 'बैंक रिकॉर्ड के अनुसार नाम';
        if (locale == 'kn') return 'ಬ್ಯಾಂಕ್ ದಾಖಲೆಗಳ ಪ್ರಕಾರ ಹೆಸರು';
        if (locale == 'ml') return 'ബാങ്ക് രേഖകൾ പ്രകാരമുള്ള പേര്';
        return 'Name as per bank records';
      }
      if (key == 'designated_role_section') {
        if (locale == 'te') return 'కేటాయించిన పాత్ర';
        if (locale == 'ta') return 'நியமிக்கப்பட்ட பங்கு';
        if (locale == 'hi') return 'नामित भूमिका';
        if (locale == 'kn') return 'ಗೊತ್ತುಪಡಿಸಿದ ಪಾತ್ರ';
        if (locale == 'ml') return 'ചുമതല';
        return 'Designated Role';
      }
      if (key == 'update_staff_button') {
        if (locale == 'te') return 'సిబ్బందిని నవీకరించండి';
        if (locale == 'ta') return 'ஊழியர் விவரங்களை மாற்றவும்';
        if (locale == 'hi') return 'कर्मचारी को अपडेट करें';
        if (locale == 'kn') return 'ಸಿಬ್ಬಂದಿ ನವೀಕರಿಸಿ';
        if (locale == 'ml') return 'ജീവനക്കാരനെ പുതുക്കുക';
        return 'Update Staff Member';
      }
      if (key == 'create_staff_button') {
        if (locale == 'te') return 'సిబ్బంది ఖాతాను సృష్టించండి';
        if (locale == 'ta') return 'ஊழியர் கணக்கை உருவாக்கவும்';
        if (locale == 'hi') return 'कर्मचारी खाता बनाएँ';
        if (locale == 'kn') return 'ಸಿಬ್ಬಂದಿ ಖಾತೆಯನ್ನು ರಚಿಸಿ';
        if (locale == 'ml') return 'ജീവനക്കാരുടെ അക്കൗണ്ട് സൃഷ്ടിക്കുക';
        return 'Create Staff Account';
      }
      if (key == 'manager') {
        if (locale == 'te') return 'మేనేజర్';
        if (locale == 'ta') return 'மேலாளர்';
        if (locale == 'hi') return 'प्रबंधक';
        if (locale == 'kn') return 'ವ್ಯವಸ್ಥಾಪಕರು';
        if (locale == 'ml') return 'മാനേജർ';
        return 'Manager';
      }
      if (key == 'warden') {
        if (locale == 'te') return 'వార్డన్';
        if (locale == 'ta') return 'காப்பாளர்';
        if (locale == 'hi') return 'वार्डन';
        if (locale == 'kn') return 'ವಾರ್ಡನ್';
        if (locale == 'ml') return 'വാർഡൻ';
        return 'Warden';
      }
      if (key == 'security') {
        if (locale == 'te') return 'సెక్యూరిటీ';
        if (locale == 'ta') return 'பாதுகாப்பு';
        if (locale == 'hi') return 'सुरक्षा';
        if (locale == 'kn') return 'ಭದ್ರತೆ';
        if (locale == 'ml') return 'സെക്യൂരിറ്റി';
        return 'Security';
      }
      if (key == 'cook') {
        if (locale == 'te') return 'వంటమనిషి';
        if (locale == 'ta') return 'சமையல்காரர்';
        if (locale == 'hi') return 'रसोइया';
        if (locale == 'kn') return 'ಅಡುಗೆಯವರು';
        if (locale == 'ml') return 'പാചകക്കാരൻ';
        return 'Cook';
      }
      if (key == 'cleaning_staff') {
        if (locale == 'te') return 'క్లీనింగ్ స్టాఫ్';
        if (locale == 'ta') return 'சுத்திகரிப்பு பணியாளர்கள்';
        if (locale == 'hi') return 'सफाई कर्मचारी';
        if (locale == 'kn') return 'ಸ್ವಚ್ಛತಾ ಸಿಬ್ಬಂದಿ';
        if (locale == 'ml') return 'ശുചീകരണ തൊഴിലാളി';
        return 'Cleaning Staff';
      }
      if (key == 'digital_certificate') {
        if (locale == 'te') return 'డిజిటల్ సర్టిఫికేట్';
        if (locale == 'ta') return 'டிஜிட்டல் சான்றிதழ்';
        if (locale == 'hi') return 'डिजिटल प्रमाणपत्र';
        if (locale == 'kn') return 'ಡಿಜಿಟಲ್ ಪ್ರಮಾಣಪತ್ರ';
        if (locale == 'ml') return 'ഡിജിറ്റൽ സർട്ടിഫിക്കറ്റ്';
        return 'Digital Certificate';
      }
      if (key == 'digital_certificate_instruction') {
        if (locale == 'te') {
          return 'అసోసియేషన్ సభ్యత్వం మరియు డిజిటల్ సర్టిఫికేట్ కోసం దరఖాస్తు చేయడానికి ఒక ప్రాపర్టీని ఎంచుకోండి.';
        }
        if (locale == 'ta') {
          return 'சங்க உறுப்பினர் மற்றும் டிஜிட்டல் சான்றிதழுக்கு விண்ணப்பிக்க ஒரு சொத்தைத் தேர்ந்தெடுக்கவும்.';
        }
        if (locale == 'hi') {
          return 'एसोसिएशन सदस्यता और डिजिटल प्रमाणपत्र के लिए आवेदन करने के लिए एक संपत्ति का चयन करें।';
        }
        if (locale == 'kn') {
          return 'ಅಸೋಸಿಯೇಷನ್ ಸದಸ್ಯತ್ವ ಮತ್ತು ಡಿಜಿಟಲ್ ಪ್ರಮಾಣಪತ್ರಕ್ಕಾಗಿ ಅರ್ಜಿ ಸಲ್ಲಿಸಲು ಆಸ್ತಿಯನ್ನು ಆಯ್ಕೆಮಾಡಿ.';
        }
        if (locale == 'ml') {
          return 'അസോസിയേഷൻ അംഗത്വത്തിനും ഡിജിറ്റൽ സർട്ടിഫിക്കറ്റിനും അപേക്ഷിക്കാൻ ഒരു പ്രോപ്പർട്ടി തിരഞ്ഞെടുക്കുക.';
        }
        return 'Select a property to apply for association membership and digital certificate.';
      }
      if (key == 'not_applied') {
        if (locale == 'te') return 'దరఖాస్తు చేయలేదు';
        if (locale == 'ta') return 'விண்ணப்பிக்கவில்லை';
        if (locale == 'hi') return 'आवेदन नहीं किया';
        if (locale == 'kn') return 'ಅನ್ವಯಿಸಿಲ್ಲ';
        if (locale == 'ml') return 'അപേക്ഷിച്ചിട്ടില്ല';
        return 'Not Applied';
      }
      if (key == 'apply_now') {
        if (locale == 'te') return 'ఇప్పుడే దరหัสు చేసుకోండి';
        if (locale == 'ta') return 'இப்போதே விண்ணப்பிக்கவும்';
        if (locale == 'hi') return 'अभी आवेदन करें';
        if (locale == 'kn') return 'ಈಗಲೇ ಅರ್ಜಿ ಹಾಕಿ';
        if (locale == 'ml') return 'ഇപ്പോൾ അപേക്ഷിക്കുക';
        return 'Apply Now';
      }
      if (key == 'certification_secured') {
        if (locale == 'te') return 'సర్టిఫికేషన్ పొందింది';
        if (locale == 'ta') return 'சான்றிதழ் பெறப்பட்டது';
        if (locale == 'hi') return 'प्रमाणपत्र सुरक्षित';
        if (locale == 'kn') return 'ಪ್ರಮಾಣೀಕರಣ ಪಡೆಯಲಾಗಿದೆ';
        if (locale == 'ml') return 'സർട്ടിഫിക്കേഷൻ നേടി';
        return 'Certification Secured';
      }
      if (key == 'trust_level') {
        if (locale == 'te') return 'నమ్మక స్థాయి';
        if (locale == 'ta') return 'நம்பிக்கை நிலை';
        if (locale == 'hi') return 'विश्वास स्तर';
        if (locale == 'kn') return 'ವಿಶ್ವಾಸಾರ್ಹತೆಯ ಮಟ್ಟ';
        if (locale == 'ml') return 'വിശ്വാസ്യത നില';
        return 'Trust Level';
      }
      if (key == 'audit_score') {
        if (locale == 'te') return 'ఆడిట్ స్కోర్';
        if (locale == 'ta') return 'தணிக்கை மதிப்பெண்';
        if (locale == 'hi') return 'ऑडिट स्कोर';
        if (locale == 'kn') return 'ಆಡಿಟ್ ಸ್ಕೋರ್';
        if (locale == 'ml') return 'ഓഡിറ്റ് സ്കോർ';
        return 'Audit Score';
      }
      if (key == 'golden_pg') {
        if (locale == 'te') return 'గోల్డెన్ పిజి';
        if (locale == 'ta') return 'கோல்டன் பிஜி';
        if (locale == 'hi') return 'गोल्डन पीजी';
        if (locale == 'kn') return 'ಗೋಲ್ಡನ್ ಪಿಜಿ';
        if (locale == 'ml') return 'ഗോൾഡൻ പിജി';
        return 'Golden PG';
      }
      if (key == 'stay_india_verified') {
        if (locale == 'te') return 'స్టే ఇండియా వెరిఫైడ్';
        if (locale == 'ta') return 'ஸ்டே இந்தியா சரிபார்க்கப்பட்டது';
        if (locale == 'hi') return 'स्टे इंडिया सत्यापित';
        if (locale == 'kn') return 'ಸ್ಟೇ ಇಂಡಿಯಾ ಪರಿಶೀಲಿಸಲಾಗಿದೆ';
        if (locale == 'ml') return 'സ്റ്റേ ഇന്ത്യ വെരിഫൈഡ്';
        return 'Stay India Verified';
      }
      if (key == 'standard_registry') {
        if (locale == 'te') return 'స్టాండర్డ్ రిజిస్ట్రీ';
        if (locale == 'ta') return 'தரநிலைப் பதிவு';
        if (locale == 'hi') return 'मानक रजिस्ट्री';
        if (locale == 'kn') return 'ಸ್ಟ್ಯಾಂಡರ್ಡ್ ರಿಜಿಸ್ಟ್ರಿ';
        if (locale == 'ml') return 'സ്റ്റാൻഡേർഡ് രജിസ്ട്രി';
        return 'Standard Registry';
      }
      if (key == 'approved') {
        if (locale == 'te') return 'ఆమోదించబడింది';
        if (locale == 'ta') return 'அங்கீகரிக்கப்பட்டது';
        if (locale == 'hi') return 'स्वीकृत';
        if (locale == 'kn') return 'ಅನುಮೋದಿಸಲಾಗಿದೆ';
        if (locale == 'ml') return 'അംഗീകരിച്ചു';
        return 'Approved';
      }
      if (key == 'rejected') {
        if (locale == 'te') return 'తిరస్కరించబడింది';
        if (locale == 'ta') return 'நிராகரிக்கப்பட்டது';
        if (locale == 'hi') return 'अस्वीकृत';
        if (locale == 'kn') return 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';
        if (locale == 'ml') return 'നിരസിച്ചു';
        return 'Rejected';
      }
      if (key.startsWith('day_')) {
        final day = key.replaceFirst('day_', '');
        switch (day) {
          case 'mon':
            if (locale == 'te') return 'సోమ';
            if (locale == 'ta') return 'திங்கள்';
            if (locale == 'hi') return 'सोमवार';
            if (locale == 'kn') return 'ಸೋಮವಾರ';
            if (locale == 'ml') return 'തിങ്കൾ';
            return 'Mon';
          case 'tue':
            if (locale == 'te') return 'మంగళ';
            if (locale == 'ta') return 'செவ்வாய்';
            if (locale == 'hi') return 'मंगलवार';
            if (locale == 'kn') return 'ಮಂಗಳವಾರ';
            if (locale == 'ml') return 'ചൊവ്വ';
            return 'Tue';
          case 'wed':
            if (locale == 'te') return 'బుధ';
            if (locale == 'ta') return 'புதன்';
            if (locale == 'hi') return 'बुधवार';
            if (locale == 'kn') return 'ಬುಧವಾರ';
            if (locale == 'ml') return 'ബുധൻ';
            return 'Wed';
          case 'thu':
            if (locale == 'te') return 'గురు';
            if (locale == 'ta') return 'வியாழன்';
            if (locale == 'hi') return 'गुरुवार';
            if (locale == 'kn') return 'ಗುರುವಾರ';
            if (locale == 'ml') return 'വ്യാഴം';
            return 'Thu';
          case 'fri':
            if (locale == 'te') return 'శుక్ర';
            if (locale == 'ta') return 'வெள்ளி';
            if (locale == 'hi') return 'शुक्रवार';
            if (locale == 'kn') return 'ಶುಕ್ರವಾರ';
            if (locale == 'ml') return 'വെള്ളി';
            return 'Fri';
          case 'sat':
            if (locale == 'te') return 'శని';
            if (locale == 'ta') return 'சனி';
            if (locale == 'hi') return 'शनिवार';
            if (locale == 'kn') return 'ಶನಿವಾರ';
            if (locale == 'ml') return 'ശനി';
            return 'Sat';
          case 'sun':
            if (locale == 'te') return 'ఆది';
            if (locale == 'ta') return 'ஞாயிறு';
            if (locale == 'hi') return 'रविवार';
            if (locale == 'kn') return 'ಭಾನುವಾರ';
            if (locale == 'ml') return 'ഞായർ';
            return 'Sun';
        }
      }

      if (key == 'service_agreement_title') {
        if (locale == 'te') return 'సర్వీస్ అగ్రిమెంట్';
        if (locale == 'ta') return 'சேவை ஒப்பந்தம்';
        if (locale == 'hi') return 'सेवा समझौता';
        if (locale == 'kn') return 'ಸೇವಾ ಒಪ್ಪಂದ';
        if (locale == 'ml') return 'സേവന കരാർ';
        return 'Service Agreement';
      }
      if (key == 'master_service_agreement_subtitle') {
        if (locale == 'te') return 'మాస్టర్ సర్వీస్ అగ్రిమెంట్ & ప్రైవసీ పాలసీ';
        if (locale == 'ta') {
          return 'முதன்மை சேவை ஒப்பந்தம் & தனியுரிமைக் கொள்கை';
        }
        if (locale == 'hi') return 'मास्टर सेवा समझौता और गोपनीयता नीति';
        if (locale == 'kn') return 'ಮಾಸ್ಟರ್ ಸೇವಾ ಒಪ್ಪಂದ ಮತ್ತು ಗೌಪ್ಯತೆ ನೀತಿ';
        if (locale == 'ml') return 'മാസ്റ്റർ സേവന കരാറും സ്വകാര്യതാ നയവും';
        return 'Master Service Agreement & Privacy Policy';
      }
      if (key == 'welcome_stay_india') {
        if (locale == 'te') return 'స్టే ఇండియాకు స్వాగతం!';
        if (locale == 'ta') return 'ஸ்டே இந்தியாவிற்கு வரவேற்கிறோம்!';
        if (locale == 'hi') return 'स्टे इंडिया में आपका स्वागत है!';
        if (locale == 'kn') return 'ಸ್ಟೇ ಇಂಡಿಯಾಗೆ ಸುಸ್ವಾಗತ!';
        if (locale == 'ml') return 'ಸ್ಟೇ ఇండియాയിലേക്ക് സ്വാഗതം!';
        return 'Welcome to Stay India!';
      }
      if (key == 'welcome_stay_india_desc') {
        if (locale == 'te') {
          return 'మా యాప్‌ను ఉపయోగించడం ద్వారా, మీరు ఈ క్రింది నిబంధనలు మరియు షరతులకు అంగీకరిస్తున్నారు. స్టే ఇండియా అనేది దేశవ్యాప్తంగా సేవలను అందించే సాంకేతిక ప్లాట్‌ఫారమ్ (SaaS).';
        }
        if (locale == 'ta') {
          return 'எங்கள் செயலியைப் பயன்படுத்துவதன் மூலம், பின்வரும் விதிமுறைகள் மற்றும் நிபந்தனைகளை ஒப்புக்கொள்கிறீர்கள். ஸ்டே இந்தியா என்பது நாடு முழுவதும் சேவைகளை வழங்கும் ஒரு தொழில்நுட்ப தளமாகும் (SaaS).';
        }
        if (locale == 'hi') {
          return 'हमारे ऐप का उपयोग करके, आप निम्नलिखित नियमों और शर्तों से सहमत होते हैं। स्टे इंडिया देश भर में सेवाएं प्रदान करने वाला एक प्रौद्योगिकी मंच (SaaS) है।';
        }
        if (locale == 'kn') {
          return 'ನಮ್ಮ ಆ್ಯಪ್ ಬಳಸುವ ಮೂಲಕ, ನೀವು ಈ ಕೆಳಗಿನ ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳಿಗೆ ಒಪ್ಪುತ್ತೀರಿ. ಸ್ಟೇ ಇಂಡಿಯಾ ದೇಶಾದ್ಯಂತ ಸೇವೆಗಳನ್ನು ಒದಗಿಸುವ ತಂತ್ರಜ್ಞಾನ ವೇದಿಕೆಯಾಗಿದೆ (SaaS).';
        }
        if (locale == 'ml') {
          return 'ഞങ്ങളുടെ ആപ്പ് ഉപയോഗിക്കുന്നതിലൂടെ, നിങ്ങൾ താഴെ പറയുന്ന നിബന്ധനകളും വ്യവസ്ഥകളും അംഗീകരിക്കുന്നു. രാജ്യത്തുടനീളം സേവനങ്ങൾ നൽകുന്ന ഒരു സാങ്കേതിക പ്ലാറ്റ്‌ഫോമാണ് (SaaS) സ്റ്റേ ഇന്ത്യ.';
        }
        return 'By using our app, you agree to the following terms and conditions. Stay India is a technology platform (SaaS) providing services across the country.';
      }
      if (key == 'pan_india_services_title') {
        if (locale == 'te') return '1. పాన్-ఇండియా సేవలు';
        if (locale == 'ta') return '1. அகில இந்திய சேவைகள்';
        if (locale == 'hi') return '1. अखिल भारतीय सेवाएँ';
        if (locale == 'kn') return '1. ಪ್ಯಾನ್-ಇಂಡಿಯಾ ಸೇವೆಗಳು';
        if (locale == 'ml') return '1. পാൻ-ഇന്ത്യ സേവനങ്ങൾ';
        return '1. Pan-India Services';
      }
      if (key == 'pan_india_services_desc') {
        if (locale == 'te') {
          return 'స్టే ఇండియా అనేది భారతదేశం అంతటా తన సేవలను అందించే ఒక అధునాతన సాఫ్ట్‌వేర్ ప్లాట్‌ఫారమ్. దేశంలోని ఏ ప్రాంతం నుండైనా PG యజమానులు మరియు నివాసితులు మా డిజిటల్ సేవలను ఉపయోగించుకోవచ్చు.';
        }
        if (locale == 'ta') {
          return 'ஸ்டே இந்தியா என்பது இந்தியா முழுவதும் தனது சேவைகளை வழங்கும் ஒரு மேம்பட்ட மென்பொருள் தளமாகும். நாட்டின் எந்தப் பகுதியிலிருந்தும் பிஜி உரிமையாளர்களும் குடியிருப்பாளர்களும் எங்களது டிஜிட்டல் சேவைகளைப் பயன்படுத்திக் கொள்ளலாம்.';
        }
        if (locale == 'hi') {
          return 'स्टे इंडिया पूरे भारत में अपनी सेवाएं प्रदान करने वाला एक उन्नत सॉफ्टवेयर प्लेटफॉर्म है। देश के किसी भी हिस्से से पीजी मालिक और निवासी हमारी डिजिटल सेवाओं का उपयोग कर सकते हैं।';
        }
        if (locale == 'kn') {
          return 'ಸ್ಟೇ ಇಂಡಿಯಾ ಇಡೀ ಭಾರತದಾದ್ಯಂತ ತನ್ನ ಸೇವೆಗಳನ್ನು ಒದಗಿಸುವ ಸುಧಾರಿತ ಸಾಫ್ಟ್‌ವೇರ್ ವೇದಿಕೆಯಾಗಿದೆ. ದೇಶದ ಯಾವುದೇ ಭಾಗದ ಪಿಜಿ ಮಾಲೀಕರು ಮತ್ತು ನಿವಾಸಿಗಳು ನಮ್ಮ ಡಿಜಿಟಲ್ ಸೇವೆಗಳನ್ನು ಬಳಸಿಕೊಳ್ಳಬಹುದು.';
        }
        if (locale == 'ml') {
          return 'ഇന്ത്യയിലുടനീളം സേവനങ്ങൾ നൽകുന്ന ഒരു നൂതന സോഫ്റ്റ്‌വെയർ പ്ലാറ്റ്‌ഫോമാണ് സ്റ്റേ ഇന്ത്യ. രാജ്യത്തിന്റെ ഏത് ഭാഗത്തുനിന്നുമുള്ള പിജി ഉടമകൾക്കും താമസക്കാർക്കും ഞങ്ങളുടെ ഡിജിറ്റൽ സേവനങ്ങൾ ഉപയോഗിക്കാം.';
        }
        return 'Stay India is an advanced software platform providing its services all over India. PG owners and residents from any part of the country can utilize our digital services.';
      }
      if (key == 'saas_liability_title') {
        if (locale == 'te') return '2. SaaS & బాధ్యత పరిమితి';
        if (locale == 'ta') return '2. SaaS & பொறுப்பு வரம்பு';
        if (locale == 'hi') return '2. SaaS और दायित्व की सीमा';
        if (locale == 'kn') return '2. SaaS ಮತ್ತು ಹೊಣೆಗಾರಿಕೆಯ ಮಿತಿ';
        if (locale == 'ml') return '2. SaaS & ബാധ്യതയുടെ പരിധി';
        return '2. SaaS & Limitation of Liability';
      }
      if (key == 'saas_liability_desc') {
        if (locale == 'te') {
          return 'మేము ఖచ్చితంగా సాఫ్ట్‌వేర్ యాజ్ ఏ సర్వీస్ (SaaS) ప్రొవైడర్‌లం మరియు PG యజమానులు మరియు నివాసితుల మధ్య వారధిగా మాత్రమే వ్యవహరిస్తాము.\n\n• భౌతిక సౌకర్యాలు: PGలోని ఫర్నిచర్ నాణ్యత, గది పరిస్థితులు లేదా ఏదైనా భౌతిక ఆస్తులకు స్టే ఇండియా బాధ్యత వహించదు.\n\n• ఆహార నాణ్యత: PGలో అందించే ఆహారం యొక్క నాణ్యత, రుచి లేదా మెనూకు కంపెనీ బాధ్యత వహించదు. నివాసితులు దీనిని వ్యక్తిగతంగా ధృవీకరించుకోవాలి.';
        }
        if (locale == 'ta') {
          return 'நாங்கள் மென்பொருள் சேவை (SaaS) வழங்குநர் மட்டுமே, பிஜி உரிமையாளர்களுக்கும் குடியிருப்பாளர்களுக்கும் இடையே ஒரு பாலமாக மட்டுமே செயல்படுகிறோம்.\n\n• உடற்பயிற்சி வசதிகள்: பிஜியில் உள்ள தளபாடங்களின் தரம், அறை நிலைகள் அல்லது எந்தவொரு உடல் சொத்துக்களுக்கும் ஸ்டே இந்தியா பொறுப்பல்ல.\n\n• உணவு தரம்: பிஜியில் வழங்கப்படும் உணவின் தரம், சுவை அல்லது மெனுவிற்கு நிறுவனம் பொறுப்பேற்காது. குடியிருப்பாளர்கள் இதை தனிப்பட்ட முறையில் சரிபார்க்க வேண்டும்.';
        }
        if (locale == 'hi') {
          return 'हम पूरी तरह से एक सॉफ्टवेयर सेवा (SaaS) प्रदाता हैं और केवल पीजी मालिकों और निवासियों के बीच एक पुल के रूप में कार्य करते हैं।\n\n• भौतिक सुविधाएं: स्टे इंडिया पीजी के भीतर फर्नीचर की गुणवत्ता, कमरे की स्थिति या किसी भी भौतिक संपत्ति के लिए जिम्मेदार नहीं है।\n\n• भोजन की गुणवत्ता: कंपनी पीजी में प्रदान किए जाने वाले भोजन की गुणवत्ता, स्वाद या मेनू की जिम्मेदारी नहीं लेती है। निवासियों को व्यक्तिगत रूप से इसकी पुष्टि होनी चाहिए।';
        }
        if (locale == 'kn') {
          return 'ನಾವು ಕೇವಲ ಸಾಫ್ಟ್‌ವೇರ್ ಸೇವೆ (SaaS) ಪೂರೈಕೆದಾರರಾಗಿದ್ದು, ಪಿಜಿ ಮಾಲೀಕರು ಮತ್ತು ನಿವಾಸಿಗಳ ನಡುವೆ ಸೇತುವೆಯಾಗಿ ಮಾತ್ರ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತೇವೆ.\n\n• ಭೌತಿಕ ಸೌಲಭ್ಯಗಳು: ಪಿಜಿಯಲ್ಲಿನ ಪೀಠೋಪಕರಣಗಳ ಗುಣಮಟ್ಟ, ಕೋಣೆಯ ಪರಿಸ್ಥಿತಿಗಳು ಅಥವಾ ಯಾವುದೇ ಭೌತಿಕ ಆಸ್ತಿಗಳಿಗೆ ಸ್ಟೇ ಇಂಡಿಯಾ ಜವಾಬ್ದಾರನಾಗಿರುವುದಿಲ್ಲ.\n\n• ಆಹಾರದ ಗುಣಮಟ್ಟ: ಪಿಜಿಯಲ್ಲಿ ಒದಗಿಸುವ ಆಹಾರದ ಗುಣಮಟ್ಟ, ರುಚಿ ಅಥವಾ ಮೆನುಗೆ ಕಂಪನಿಯು ಜವಾಬ್ದಾರಿಯನ್ನು ತೆಗೆದುಕೊಳ್ಳುವುದಿಲ್ಲ. ನಿವಾಸಿಗಳು ಇದನ್ನು ವೈಯಕ್ತಿಕವಾಗಿ ಪರಿಶೀಲಿಸಬೇಕು.';
        }
        if (locale == 'ml') {
          return 'ഞങ്ങൾ കർശനമായി ഒരു സോഫ്റ്റ്‌വെയർ സേവന (SaaS) ദാതാവാണ്, കൂടാതെ PG ഉടമകൾക്കും താമസക്കാർക്കും ഇടയിൽ ഒരു പാലമായി മാത്രമേ പ്രവർത്തിക്കൂ.\n\n• ഭൗതിക സൗകര്യങ്ങൾ: PG-ക്കുള്ളിലെ ഫർണിച്ചറുകളുടെ ഗുണനിലവാരം, റൂം അവസ്ഥകൾ അല്ലെങ്കിൽ ഏതെങ്കിലും ഭൗതിക ആസ്തികൾ എന്നിവയ്ക്ക് സ്റ്റേ ഇന്ത്യ ഉത്തരവാദിയല്ല.\n\n• ഭക്ഷണത്തിന്റെ ഗുണനിലവാരം: PG-യിൽ നൽകുന്ന ഭക്ഷണത്തിന്റെ ഗുണനിലവാരം, രുചി അല്ലെങ്കിൽ മെനു എന്നിവയ്ക്ക് കമ്പനി ഉത്തരവാദിത്തം ഏറ്റെടുക്കുന്നില്ല. താമസക്കാർ ഇത് വ്യക്തിപരമായി പരിശോധിക്കണം.';
        }
        return 'We are strictly a Software as a Service (SaaS) provider and act only as a bridge between PG owners and residents.\n\n• Physical Facilities: Stay India is not responsible for the quality of furniture, room conditions, or any physical assets within the PG.\n\n• Food Quality: The company does not take responsibility for the quality, taste, or menu of the food provided at the PG. Residents must verify this personally.';
      }
      if (key == 'data_privacy_title') {
        if (locale == 'te') return '3. డేటా గోప్యత & భద్రత';
        if (locale == 'ta') return '3. தரவு தனியுரிமை & பாதுகாப்பு';
        if (locale == 'hi') return '3. डेटा गोपनीयता और सुरक्षा';
        if (locale == 'kn') return '3. ಡೇಟಾ ಗೌಪ್ಯತೆ ಮತ್ತು ಸುರಕ್ಷತೆ';
        if (locale == 'ml') return '3. ഡാറ്റാ സ്വകാര്യതയും സുരക്ഷയും';
        return '3. Data Privacy & Security';
      }
      if (key == 'data_privacy_desc') {
        if (locale == 'te') {
          return 'మీ వ్యక్తిగత సమాచారం మా వద్ద అత్యంత సురక్షితంగా ఉంటుంది.\n\n• సేకరణ: మేము మీ పేరు, ఫోన్ నంబర్ మరియు ధృవీకరణ ప్రయోజనాల కోసం మాత్రమే ఆధార్ కార్డ్ వంటి వివరాలను సేకరిస్తాము.\n\n• రక్షణ: మేము మీ వ్యక్తిగత డేటాను విక్రయించము. ఇది గోప్యంగా ఉంటుంది మరియు చట్టం ప్రకారం అవసరమైతే తప్ప షేర్ చేయబడదు.';
        }
        if (locale == 'ta') {
          return 'உங்கள் தனிப்பட்ட தகவல் எங்களிடம் மிகவும் பாதுகாப்பாக உள்ளது.\n\n• சேகரிப்பு: சரிபார்ப்பு நோக்கங்களுக்காக மட்டுமே உங்கள் பெயர், தொலைபேசி எண் மற்றும் ஆதார் அட்டை போன்ற விவரங்களை நாங்கள் சேகரிக்கிறோம்.\n\n• பாதுகாப்பு: உங்கள் தனிப்பட்ட தரவை நாங்கள் விற்க மாட்டோம். இது ரகசியமாக இருக்கும் மற்றும் சட்டப்படி தேவைப்பட்டால் மட்டுமே பகிரப்படும்.';
        }
        if (locale == 'hi') {
          return 'आपकी व्यक्तिगत जानकारी हमारे पास अत्यधिक सुरक्षित है।\n\n• संग्रह: हम केवल सत्यापन उद्देश्यों के लिए आपका नाम, फ़ोन नंबर और आधार कार्ड जैसे विवरण एकत्र करते हैं।\n\n• सुरक्षा: हम आपका व्यक्तिगत डेटा नहीं बेचते हैं। यह गोपनीय रहता है और केवल कानून द्वारा आवश्यक होने पर ही साझा किया जाएगा।';
        }
        if (locale == 'kn') {
          return 'ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಮಾಹಿತಿ ನಮ್ಮ ಬಳಿ ಅತ್ಯಂತ ಸುರಕ್ಷಿತವಾಗಿದೆ.\n\n• ಸಂಗ್ರಹಣೆ: ಪರಿಶೀಲನೆ ಉದ್ದೇಶಗಳಿಗಾಗಿ ಮಾತ್ರ ನಾವು ನಿಮ್ಮ ಹೆಸರು, ಫೋನ್ ಸಂಖ್ಯೆ ಮತ್ತು ಆಧಾರ ಕಾರ್ಡ್‌ನಂತಹ ವಿವರಗಳನ್ನು ಸಂಗ್ರಹಿಸುತ್ತೇವೆ.\n\n• ರಕ್ಷಣೆ: ನಾವು ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಡೇಟಾವನ್ನು ಮಾರಾಟ ಮಾಡುವುದಿಲ್ಲ. ಇದು ಗೌಪ್ಯವಾಗಿರುತ್ತದೆ ಮತ್ತು ಕಾಯಿದೆಯ ಪ್ರಕಾರ ಅಗತ್ಯವಿದ್ದರೆ ಮಾತ್ರ ಹಂಚಿಕೊಳ್ಳಲಾಗುತ್ತದೆ.';
        }
        if (locale == 'ml') {
          return 'നിങ്ങളുടെ വ്യക്തിഗത വിവരങ്ങൾ ഞങ്ങളുടെ പക്കൽ സുരക്ഷിതമാണ്.\n\n• ശേഖരണം: പരിശോധനാ ആവശ്യങ്ങൾക്കായി മാത്രം ഞങ്ങൾ നിങ്ങളുടെ പേര്, ഫോൺ നമ്പർ, ആധാർ കാർഡ് തുടങ്ങിയ വിവരങ്ങൾ ശേഖരിക്കുന്നു.\n\n• സംരക്ഷണം: ഞങ്ങൾ നിങ്ങളുടെ വ്യക്തിഗത വിവരങ്ങൾ വിൽക്കില്ല. ഇത് രഹസ്യമായി സൂക്ഷിക്കുകയും നിയമപ്രകാരം ആവശ്യമാണെങ്കിൽ മാത്രം പങ്കിടുകയും ചെയ്യും.';
        }
        return 'Your personal information is highly secure with us.\n\n• Collection: We collect details like your name, phone number, and Aadhaar card for verification purposes only.\n\n• Protection: We do not sell your personal data. It remains confidential and will only be shared if required by law.';
      }
      if (key == 'payments_methods_title') {
        if (locale == 'te') return '4. చెల్లింపులు & పద్ధతులు';
        if (locale == 'ta') return '4. கொடுப்பனவுகள் & முறைகள்';
        if (locale == 'hi') return '4. भुगतान और तरीके';
        if (locale == 'kn') return '4. ಪಾವತಿಗಳು ಮತ್ತು ವಿಧಾನಗಳು';
        if (locale == 'ml') return '4. പേയ്‌മെന്റുകളും രീതികളും';
        return '4. Payments & Methods';
      }
      if (key == 'payments_methods_desc') {
        if (locale == 'te') {
          return '• చెల్లింపు ప్రక్రియ: నివాసితులు నేరుగా QR కోడ్, డెబిట్/క్రెడిట్ కార్డ్, ఇంటర్నెట్ బ్యాంకింగ్ లేదా ప్లాట్‌ఫారమ్‌లో అందుబాటులో ఉన్న ఇతర ఆన్‌లైన్ చెల్లింపు పద్ధతులను ఉపయోగించి PG యజమానికి అద్దె చెల్లించాలి.\n\n• బాధ్యత: ఏదైనా లావాదేవీ విఫలమవడం, చెల్లింపు వివాదాలు లేదా రీఫండ్ సమస్యలకు స్టే ఇండియా బాధ్యత వహించదు. వీటిని నివాసి మరియు యజమాని మధ్య పరిష్కరించుకోవాలి.';
        }
        if (locale == 'ta') {
          return '• கட்டண செயல்முறை: தளத்தில் கிடைக்கும் கியூஆர் குறியீடு, டெபிட்/கிரெடிட் கார்டு, இணைய வங்கி அல்லது பிற ஆன்லைன் கட்டண முறைகளைப் பயன்படுத்தி குடியிருப்பாளர்கள் வாடகையை trực tiếp பிஜி உரிமையாளருக்கு செலுத்த வேண்டும்.\n\n• பொறுப்பு: எந்தவொரு பரிவர்த்தனை தோல்விகள், கட்டண தகராறுகள் அல்லது பணத்தைத் திரும்பப்பெறுதல் சிக்கல்களுக்கு ஸ்டே இந்தியா பொறுப்பல்ல. குடியிருப்பாளருக்கும் உரிமையாளருக்கும் இடையில் இவை தீர்க்கப்பட வேண்டும்.';
        }
        if (locale == 'hi') {
          return '• भुगतान प्रक्रिया: निवासी मंच पर उपलब्ध क्यूआर कोड, डेबिट/क्रेडिट कार्ड, इंटरनेट बैंकिंग या अन्य ऑनलाइन भुगतान विधियों का उपयोग करके सीधे पीजी मालिक को किराए का भुगतान करेंगे।\n\n• दायित्व: स्टे इंडिया किसी भी लेनदेन की विफलता, भुगतान विवाद या धनवापसी के मुद्दों के लिए जिम्मेदार नहीं है। इन्हें निवासी और मालिक के बीच सुलझाया जाना चाहिए।';
        }
        if (locale == 'kn') {
          return '• ಪಾವತಿ ಪ್ರಕ್ರಿಯೆ: ನಿವಾಸಿಗಳು ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ನಲ್ಲಿ ಲಭ್ಯವಿರುವ ಕ್ಯೂಆರ್ ಕೋಡ್, ಡೆಬಿಟ್/ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್, ಇಂಟರ್ನೆಟ್ ಬ್ಯಾಂಕಿಂಗ್ ಅಥವಾ ಇತರ ಆನ್‌ಲೈನ್ ಪಾವತಿ ವಿಧಾನಗಳನ್ನು ಬಳಸಿಕೊಂಡು ನೇರವಾಗಿ ಪಿಜಿ ಮಾಲೀಕರಿಗೆ ಬಾಡಿಗೆಯನ್ನು ಪಾವತಿಸಬೇಕು.\n\n• ಹೊಣೆಗಾರಿಕೆ: ಯಾವುದೇ ವಹಿವಾಟು ವಿಫಲತೆಗಳು, ಪಾವತಿ ವಿವಾದಗಳು ಅಥವಾ ಮರುಪಾವತಿ ಸಮಸ್ಯೆಗಳಿಗೆ ಸ್ಟೇ ಇಂಡಿಯಾ ಜವಾಬ್ದಾರನಾಗಿರುವುದಿಲ್ಲ. ಇವುಗಳನ್ನು ನಿವಾಸಿ ಮತ್ತು ಮಾಲೀಕರ ನಡುವೆ ಬಗೆಹರಿಸಿಕೊಳ್ಳಬೇಕು.';
        }
        if (locale == 'ml') {
          return '• പേയ്‌മെന്റ് പ്രക്രിയ: താമസക്കാർ ക്യുആർ കോഡ്, ഡെബിറ്റ്/ക്രെഡിറ്റ് കാർഡ്, ഇന്റർനെറ്റ് ബാങ്കിംഗ് അല്ലെങ്കിൽ പ്ലാറ്റ്‌ഫോമിൽ ലഭ്യമായ മറ്റ് പേയ്‌മെന്റ് രീതികൾ ഉപയോഗിച്ച് നേരിട്ട് പിജി ഉടമയ്ക്ക് വാടക നൽകണം.\n\n• ബാധ്യത: ഏതെങ്കിലും ഇടപാട് പരാജയങ്ങൾക്കോ പേയ്‌മെന്റ് തർക്കങ്ങൾക്കോ റീഫണ്ട് പ്രശ്നങ്ങൾക്കോ സ്റ്റೇ ഇന്ത്യ ഉത്തരവാദിയല്ല. താമസക്കാരനും ഉടമയും തമ്മിൽ ഇവ പരിഹരിക്കേണ്ടതാണ്.';
        }
        return '• Payment Process: Residents shall pay rent directly to the PG owner using the QR code, Debit/Credit Card, Internet Banking, or other online payment methods available on the platform.\n\n• Liability: Stay India is not responsible for any transaction failures, payment disputes, or refund issues. These must be settled between the resident and the owner.';
      }
      if (key == 'tenant_conduct_title') {
        if (locale == 'te') return '5. అద్దెదారు ప్రవర్తన & నష్టం';
        if (locale == 'ta') return '5. குடியிருப்பாளர் நடத்தை & சேதம்';
        if (locale == 'hi') return '5. किरायेदार का आचरण और क्षति';
        if (locale == 'kn') return '5. ಬಾಡಿಗೆದಾರರ ನಡವಳಿಕೆ ಮತ್ತು ಹಾನಿ';
        if (locale == 'ml') return '5. താമസക്കാരന്റെ പെരുമാറ്റവും നാശനഷ്ടവും';
        return '5. Tenant Conduct & Damage';
      }
      if (key == 'tenant_conduct_desc') {
        if (locale == 'te') {
          return '• క్రమశిక్షణ: నివాసితులు PG నిబంధనలను ఉల్లంఘించడం, ఆలస్యంగా రావడం లేదా యజమానులతో వ్యక్తిగత విభేదాల నుండి ఉత్పన్నమయ్యే వివాదాలలో స్టే ఇండియా ప్రమేయం ఉండదు.\n\n• ఆస్తి నష్టం: PG ఫర్నిచర్ లేదా ఆస్తికి నివాసితులు కలిగించే ఏదైనా నష్టం నివాసి మరియు యజమాని మధ్య ప్రైవేట్ విషయం. యాప్ ఎటువంటి పరిహారానికి బాధ్యత వహించదు.';
        }
        if (locale == 'ta') {
          return '• ஒழுக்கம்: குடியிருப்பாளர்கள் பிஜி விதிகளை மீறுதல், தாமதமாக நுழைதல் அல்லது உரிமையாளர்களுடன் ஏற்படும் தனிப்பட்ட மோதல்கள் ஆகியவற்றால் ஏற்படும் தகராறுகளில் ஸ்டே இந்தியா ஈடுபடாது.\n\n• சொத்து சேதம்: பிஜி தளபாடங்கள் அல்லது சொத்துக்களுக்கு குடியிருப்பாளர்களால் ஏற்படும் சேதங்கள் குடியிருப்பாளருக்கும் உரிமையாளருக்கும் இடையிலான தனிப்பட்ட விஷயம். செயலி எந்த இழப்பீட்டிற்கும் பொறுப்பல்ல.';
        }
        if (locale == 'hi') {
          return '• अनुशासन: निवासियों द्वारा पीजी नियमों का उल्लंघन करने, देर से प्रवेश करने या मालिकों के साथ व्यक्तिगत संघर्षों से उत्पन्न विवादों में स्टे इंडिया शामिल नहीं है।\n\n• संपत्ति की क्षति: निवासियों द्वारा पीजी के फर्नीचर या संपत्ति को नुकसान पहुंचाना निवासी और मालिक के बीच का निजी मामला है। ऐप किसी भी मुआवजे के लिए उत्तरदायी नहीं है।';
        }
        if (locale == 'kn') {
          return '• ಶಿಸ್ತು: ನಿವಾಸಿಗಳು ಪಿಜಿ ನಿಯಮಗಳನ್ನು ಉಲ್ಲಂಘಿಸುವುದು, ತಡವಾಗಿ ಪ್ರವೇಶಿಸುವುದು ಅಥವಾ ಮಾಲೀಕರೊಂದಿಗೆ ವೈಯಕ್ತಿಕ ಸಂಘರ್ಷಗಳಿಂದ ಉಂಟಾಗುವ ವಿವಾದಗಳಲ್ಲಿ ಸ್ಟೇ ಇಂಡಿಯಾ ಭಾಗಿಯಾಗುವುದಿಲ್ಲ.\n\n• ಆಸ್ತಿ ಹಾನಿ: ಪಿಜಿ ಪೀಠೋಪಕರಣಗಳು ಅಥವಾ ಆಸ್ತಿಗೆ ನಿವಾಸಿಗಳು ಉಂಟುಮಾಡುವ ಯಾವುದೇ ಹಾನಿ ನಿವಾಸಿ ಮತ್ತು ಮಾಲೀಕರ ನಡುವಿನ ವೈಯಕ್ತಿಕ ವಿಷಯವಾಗಿದೆ. ಆ್ಯಪ್ ಯಾವುದೇ ಪರಿಹಾರಕ್ಕೆ ಹೊಣೆಯಲ್ಲ.';
        }
        if (locale == 'ml') {
          return '• അച്ചടക്കം: താമസക്കാർ പിജി നിയമങ്ങൾ ലംഘിക്കുന്നതിൽ നിന്നോ വൈകി പ്രവേശിക്കുന്നതിൽ നിന്നോ ഉടമകളുമായുള്ള വ്യക്തിപരമായ തർക്കങ്ങളിൽ നിന്നോ ഉണ്ടാകുന്ന തർക്കങ്ങളിൽ സ്റ്റേ ഇന്ത്യ ഇടപെടില്ല.\n\n• പ്രോപ്പർട്ടി നാശനഷ്ടം: താമസക്കാർ പിജി ഫർണിച്ചറുകൾക്കോ വസ്തുവകകൾക്കോ വരുത്തുന്ന നാശനഷ്ടങ്ങൾ താമസക്കാരനും ഉടമയും തമ്മിലുള്ള സ്വകാര്യ കാര്യമാണ്. ആപ്പ് യാതൊരു നഷ്ടപരിഹാരത്തിനും ബാധ്യസ്ഥനല്ല.';
        }
        return '• Discipline: Stay India is not involved in disputes arising from residents violating PG rules, late entries, or personal conflicts with owners.\n\n• Property Damage: Any damage caused by residents to the PG furniture or property is a private matter between the resident and the owner. The app is not liable for any compensation.';
      }
      if (key == 'app_support_title') {
        if (locale == 'te') return '6. యాప్ సపోర్ట్ & కస్టమర్ కేర్';
        if (locale == 'ta') return '6. செயலி ஆதரவு & வாடிக்கையாளர் சேவை';
        if (locale == 'hi') return '6. ऐप सहायता और कस्टमर केयर';
        if (locale == 'kn') return '6. ಆ್ಯಪ್ ಬೆಂಬಲ ಮತ್ತು ಗ್ರಾಹಕ ಸೇವೆ';
        if (locale == 'ml') return '6. ആപ്പ് സപ്പോർട്ടും കസ്റ്റമർ കെയറും';
        return '6. App Support & Customer Care';
      }
      if (key == 'app_support_desc') {
        if (locale == 'te') {
          return '• సాఫ్ట్‌వేర్ సమస్యలు: యాప్ నెమ్మదిగా ఉన్నా లేదా ఏదైనా ఫీచర్ సరిగ్గా పనిచేయకపోయినా, మీరు సాంకేతిక మద్దతు కోసం వెంటనే మా కస్టమర్ కేర్‌ను సంప్రదించవచ్చు.\n\n• సహాయం: సాఫ్ట్‌వేర్‌కు సంబంధించిన ఏదైనా సాంకేతిక సహాయం కోసం, దయచేసి మా మద్దతు నంబర్‌కు కాల్ చేయండి: +91 9888936836. మీకు సహాయం చేయడానికి మా బృందం సిద్ధంగా ఉంది.';
        }
        if (locale == 'ta') {
          return '• மென்பொருள் சிக்கல்கள்: செயலி மெதுவாக இருந்தால் அல்லது ஏதேனும் அம்சம் சரியாக வேலை செய்யவில்லை என்றால், தொழில்நுட்ப ஆதரவுக்காக உடனடியாக எங்கள் வாடிக்கையாளர் சேவையைத் தொடர்பு கொள்ளலாம்.\n\n• உதவி: மென்பொருள் தொடர்பான ஏதேனும் தொழில்நுட்ப உதவிக்கு, தயவுசெய்து எங்களது ஆதரவு எண்ணை அழைக்கவும்: +91 9888936836. உங்களுக்கு உதவ எங்களது குழு தயாராக உள்ளது.';
        }
        if (locale == 'hi') {
          return '• सॉफ्टवेयर संबंधी समस्याएं: यदि ऐप धीमा है या कोई सुविधा ठीक से काम नहीं कर रही है, तो आप तकनीकी सहायता के लिए तुरंत हमारे कस्टमर केयर से संपर्क कर सकते हैं।\n\n• सहायता: सॉफ्टवेयर से संबंधित किसी भी तकनीकी मदद के लिए, कृपया हमारे सहायता नंबर पर कॉल करें: +91 9888936836। हमारी टीम आपकी सहायता के लिए तैयार है।';
        }
        if (locale == 'kn') {
          return '• ಸಾಫ್ಟ್‌ವೇರ್ समस्याಗಳು: ಆ್ಯಪ್ ನಿಧಾನವಾಗಿದ್ದರೆ ಅಥವಾ ಯಾವುದೇ ವೈಶಿಷ್ಟ್ಯವು ಸರಿಯಾಗಿ ಕಾರ್ಯನಿರ್ವಹಿಸದಿದ್ದರೆ, ತಾಂತ್ರಿಕ ಬೆಂಬಲಕ್ಕಾಗಿ ನೀವು ತಕ್ಷಣ ನಮ್ಮ ಗ್ರಾಹಕ ಸೇವೆಯನ್ನು ಸಂಪರ್ಕಿಸಬಹುದು.\n\n• ನೆರವು: ಸಾಫ್ಟ್‌ವೇರ್‌ಗೆ ಸಂಬಂಧಿಸಿದ ಯಾವುದೇ ತಾಂತ್ರಿಕ ಸಹಾಯಕ್ಕಾಗಿ, ದಯವಿಟ್ಟು ನಮ್ಮ ಬೆಂಬಲ ಸಂಖ್ಯೆಗೆ ಕರೆ ಮಾಡಿ: +91 9888936836. ನಿಮಗೆ ಸಹಾಯ ಮಾಡಲು ನಮ್ಮ ತಂಡ ಸಿದ್ಧವಾಗಿದೆ.';
        }
        if (locale == 'ml') {
          return '• സോഫ്റ്റ്‌വെയർ പ്രശ്നങ്ങൾ: ആപ്പ് സ്ലോ ആണെങ്കിൽ അല്ലെങ്കിൽ ഏതെങ്കിലും ഫീച്ചർ ശരിയായി പ്രവർത്തിക്കുന്നില്ലെങ്കിൽ, സാങ്കേതിക പിന്തുണയ്ക്കായി നിങ്ങൾക്ക് ഉടൻ തന്നെ ഞങ്ങളുടെ കസ്റ്റമർ കെയറുമായി ബന്ധപ്പെടാം.\n\n• സഹായം: സോഫ്റ്റ്‌വെയറുമായി ബന്ധപ്പെട്ട ഏതെങ്കിലും സാങ്കേതിക സഹായത്തിന്, ദയവായി ഞങ്ങളുടെ സപ്പോർട്ട് നമ്പറിൽ വിളിക്കുക: +91 9888936836. നിങ്ങളെ സഹായിക്കാൻ ഞങ്ങളുടെ ടീം സന്നദ്ധരാണ്.';
        }
        return '• Software Issues: If the app is slow or if any feature is not functioning correctly, you can immediately contact our customer care for technical support.\n\n• Assistance: For any technical help related to the software, please call our support number: +91 9888936836. Our team is ready to assist you.';
      }
      if (key == 'validity_changes_title') {
        if (locale == 'te') return '7. చెల్లుబాటు & మార్పులు';
        if (locale == 'ta') return '7. செல்லுபடியாகும் தன்மை & மாற்றங்கள்';
        if (locale == 'hi') return '7. वैधता और परिवर्तन';
        if (locale == 'kn') return '7. ಸಿಂಧುತ್ವ ಮತ್ತು ಬದಲಾವಣೆಗಳು';
        if (locale == 'ml') return '7. സാധുതയും മാറ്റങ്ങളും';
        return '7. Validity & Changes';
      }
      if (key == 'validity_changes_desc') {
        if (locale == 'te') {
          return 'మీరు యాప్‌ని ఉపయోగిస్తున్నంత కాలం ఈ అగ్రిమెంట్ చెల్లుబాటులో ఉంటుంది. ఈ నిబంధనలకు ఏదైనా భవిష్యత్తు మార్పులు యాప్ ద్వారా తెలియజేయబడతాయి. అప్పటి వరకు, ప్రస్తుత నిబంధనలు వర్తిస్తాయి.';
        }
        if (locale == 'ta') {
          return 'நீங்கள் செயலியைப் பயன்படுத்தும் வரை இந்த ஒப்பந்தம் செல்லுபடியாகும். இந்த விதிமுறைகளில் ஏதேனும் எதிர்கால மாற்றங்கள் செயலி மூலம் தெரிவிக்கப்படும். அதுவரை தற்போதைய விதிமுறைகளே பொருந்தும்.';
        }
        if (locale == 'hi') {
          return 'यह समझौता तब तक वैध रहेगा जब तक आप ऐप का उपयोग करेंगे। इन शर्तों में भविष्य में होने वाले किसी भी बदलाव की सूचना ऐप के माध्यम से दी जाएगी। तब तक, वर्तमान शर्तें लागू रहेंगी।';
        }
        if (locale == 'kn') {
          return 'ನೀವು ಆ್ಯಪ್ ಬಳಸುವವರೆಗೆ ಈ ಒಪ್ಪಂದವು ಜಾರಿಯಲ್ಲಿರುತ್ತದೆ. ಈ ನಿಯಮಗಳಿಗೆ ಯಾವುದೇ ಭವಿಷ್ಯದ ಬದಲಾವಣೆಗಳನ್ನು ಆ್ಯಪ್ ಮೂಲಕ ತಿಳಿಸಲಾಗುತ್ತದೆ. ಅಲ್ಲಿಯವರೆಗೆ, ಪ್ರಸ್ತುತ ನಿಯಮಗಳು ಅನ್ವಯಿಸುತ್ತವೆ.';
        }
        if (locale == 'ml') {
          return 'നിങ്ങൾ ആപ്പ് ഉപയോഗിക്കുന്നിടത്തോളം ഈ കരാർ സാധുവായിരിക്കും. ഈ വ്യവസ്ഥകളിൽ ഭാവിയിലുണ്ടാകുന്ന എന്തെങ്കിലും മാറ്റങ്ങൾ ആപ്പ് വഴി അറിയിക്കുന്നതാണ്. അതുവരെ, നിലവിലെ നിബന്ധനകൾ ബാധകമായിരിക്കും.';
        }
        return 'This agreement remains valid as long as you use the app. Any future changes to these terms will be notified through the app. Until then, the current terms shall apply.';
      }
      if (key == 'contact_us_title') {
        if (locale == 'te') return 'మమ్మల్ని సంప్రదించండి';
        if (locale == 'ta') return 'எங்களைத் தொடர்பு கொள்ளவும்';
        if (locale == 'hi') return 'संपर्क करें';
        if (locale == 'kn') return 'ನಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸಿ';
        if (locale == 'ml') return 'ഞങ്ങളെ ബന്ധപ്പെടുക';
        return 'Contact Us';
      }
      if (key == 'last_updated') {
        if (locale == 'te') return 'చివరిగా నవీకరించబడింది: {date}';
        if (locale == 'ta') return 'கடைசியாக புதுப்பிக்கப்பட்டது: {date}';
        if (locale == 'hi') return 'अंतिम बार अपडेट किया गया: {date}';
        if (locale == 'kn') return 'ಕೊನೆಯದಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ: {date}';
        if (locale == 'ml') return 'അവസാനം പുതുക്കിയത്: {date}';
        return 'Last updated: {date}';
      }
      if (key == 'agree_terms_checkbox') {
        if (locale == 'te') {
          return 'పైన పేర్కొన్న అన్ని నియమ నిబంధనలను నేను చదివాను మరియు పాటించడానికి అంగీకరిస్తున్నాను.';
        }
        if (locale == 'ta') {
          return 'மேலே குறிப்பிட்டுள்ள அனைத்து விதிமுறைகள் மற்றும் ஒழுங்குமுறைகளை நான் படித்து ஒப்புக்கொள்கிறேன்.';
        }
        if (locale == 'hi') {
          return 'मैंने ऊपर उल्लिखित सभी नियमों और विनियमों को पढ़ लिया है और उनका पालन करने के लिए सहमत हूँ।';
        }
        if (locale == 'kn') {
          return 'ಮೇಲೆ ತಿಳಿಸಲಾದ ಎಲ್ಲಾ ನಿಯಮಗಳು ಮತ್ತು ನಿಬಂಧನೆಗಳನ್ನು ನಾನು ಓದಿದ್ದೇನೆ ಮತ್ತು ಪಾಲಿಸಲು ಒಪ್ಪುತ್ತೇನೆ.';
        }
        if (locale == 'ml') {
          return 'മുകളിൽ പറഞ്ഞിരിക്കുന്ന എല്ലാ നിയമങ്ങളും ചട്ടങ്ങളും ഞാൻ വായിച്ചുനോക്കി, പാലിക്കാൻ സമ്മതിക്കുന്നു.';
        }
        return 'I have read and I agree to follow all the Rules and Regulations mentioned above.';
      }
      if (key == 'accept_continue_button') {
        if (locale == 'te') return 'అంగీకరించి కొనసాగండి';
        if (locale == 'ta') return 'ஏற்றுக்கொண்டு தொடரவும்';
        if (locale == 'hi') return 'स्वीकार करें और जारी रखें';
        if (locale == 'kn') return 'ಒಪ್ಪಿ ಮುಂದುವರಿಯಿರಿ';
        if (locale == 'ml') return 'അംഗീകരിച്ച് തുടരുക';
        return 'Accept & Continue';
      }
      if (key == 'agreement_accepted_msg') {
        if (locale == 'te') {
          return 'సర్వీస్ అగ్రిమెంట్ విజయవంతంగా అంగీకరించబడింది!';
        }
        if (locale == 'ta') {
          return 'சேவை ஒப்பந்தம் வெற்றிகரமாக ஏற்றுக்கொள்ளப்பட்டது!';
        }
        if (locale == 'hi') return 'सेवा समझौता सफलतापूर्वक स्वीकार किया गया!';
        if (locale == 'kn') {
          return 'ಸೇವಾ ಒಪ್ಪಂದವನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಸ್ವೀಕರಿಸಲಾಗಿದೆ!';
        }
        if (locale == 'ml') return 'ಸೇവന കരാർ വിജയകരമായി അംഗീകരിച്ചു!';
        return 'Service agreement accepted successfully!';
      }

      if (key == 'app_name') return 'Stay India';
      if (key == 'pg_owners_community') {
        if (locale == 'te') return 'PG యజమానుల సంఘం';
        return 'PG Owners Community';
      }
      if (key == 'feed_updates_title') {
        if (locale == 'te') return 'ఫీడ్ అప్‌డేట్లు';
        return 'Feed Updates';
      }
      if (key == 'all_posts_read_msg') {
        if (locale == 'te') {
          return 'అన్ని పోస్ట్‌లు చదివినట్లుగా గుర్తించబడ్డాయి';
        }
        return 'All posts marked as read';
      }
      if (key == 'mark_all_read') {
        if (locale == 'te') return 'అన్నీ చదివినట్లుగా గుర్తించు';
        return 'Mark all as read';
      }
      if (key == 'new_posts_count') {
        final count = namedArgs?['count'] ?? '0';
        if (locale == 'te') return '$count కొత్త పోస్ట్‌లు అందుబాటులో ఉన్నాయి';
        return '$count new posts available';
      }
      if (key == 'all_caught_up') {
        if (locale == 'te') return 'మీరు అన్నీ చూశారు!';
        return 'You\'re all caught up!';
      }
      if (key == 'feed_scroll_msg') {
        if (locale == 'te') {
          return 'తాజా అప్‌డేట్‌లను చూడటానికి ఫీడ్‌ను స్క్రోల్ చేయండి.';
        }
        return 'Scroll through the feed to see latest updates.';
      }
      if (key == 'no_unread_announcements') {
        if (locale == 'te') return 'ప్రస్తుతానికి కొత్త ప్రకటనలు ఏవీ లేవు.';
        return 'No new announcements at the moment.';
      }
      if (key == 'delete_post_title') {
        if (locale == 'te') return 'పోస్ట్‌ను తొలగించు';
        return 'Delete Post';
      }
      if (key == 'delete_post_confirm') {
        if (locale == 'te') {
          return 'మీరు ఖచ్చితంగా ఈ పోస్ట్‌ను తొలగించాలనుకుంటున్నారా?';
        }
        return 'Are you sure you want to remove this post?';
      }
      if (key == 'remove') {
        if (locale == 'te') return 'తొలగించు';
        return 'Remove';
      }
      if (key == 'select_property_err') {
        if (locale == 'te') return 'దయచేసి ముందుగా ప్రాపర్టీని ఎంచుకోండి';
        return 'Please select a property first';
      }
      if (key == 'national_level_communities') {
        final name = namedArgs?['name'] ?? '';
        if (locale == 'te') return '$name స్థాయి సంఘాలు';
        return 'National level communities in $name';
      }
      if (key == 'level_state') {
        if (locale == 'te') return 'రాష్ట్ర స్థాయి';
        return 'State Level';
      }
      if (key == 'level_district') {
        if (locale == 'te') return 'జిల్లా స్థాయి';
        return 'District Level';
      }
      if (key == 'level_ward') {
        if (locale == 'te') return 'వార్డు స్థాయి';
        return 'LOCALITIES';
      }
      if (key == 'district_label') {
        if (locale == 'te') return 'జిల్లా';
        return 'District';
      }
      if (key == 'ward_label') {
        if (locale == 'te') return 'వార్డు';
        return 'Locality';
      }
      if (key == 'state_level_communities') {
        final name = namedArgs?['name'] ?? '';
        if (locale == 'te') return '$name రాష్ట్ర స్థాయి సంఘాలు';
        return 'State level communities in $name';
      }
      if (key == 'explore_districts_in') {
        final name = namedArgs?['name'] ?? '';
        if (locale == 'te') return '$name జిల్లాలను అన్వేషించండి';
        return 'Explore districts in $name';
      }
      if (key == 'communities_in') {
        final name = namedArgs?['name'] ?? '';
        if (locale == 'te') return '$name సంఘాలు';
        return 'Communities in $name';
      }
      if (key == 'explore_wards_in') {
        final name = namedArgs?['name'] ?? '';
        if (locale == 'te') return '$name వార్డులను అన్వేషించండి';
        return 'Explore Localities in $name';
      }
      if (key == 'search_level_hint') {
        final level = namedArgs?['level'] ?? '';
        if (locale == 'te') return '$level వెతకండి...';
        return 'Search $level...';
      }
      if (key == 'selection_required') {
        if (locale == 'te') return 'ఎంపిక అవసరం';
        return 'Selection Required';
      }
      if (key == 'selection_required_desc') {
        final requirement = namedArgs?['requirement'] ?? '';
        if (locale == 'te') {
          return 'వార్డులను చూడటానికి దయచేసి ముందుగా $requirement ఎంచుకోండి.';
        }
        return 'Please select a $requirement first to view localities.';
      }
      if (key == 'go_to_district_tab') {
        if (locale == 'te') return 'జిల్లా ట్యాబ్‌కు వెళ్లండి';
        return 'Go to District Tab';
      }
      if (key == 'no_level_items_found') {
        final level = namedArgs?['level'] ?? '';
        if (locale == 'te') return '$level అంశాలేవీ కనుగొనబడలేదు';
        return 'No $level items found';
      }
      if (key == 'no_states_found') {
        if (locale == 'te') return 'రాష్ట్రాలేవీ కనుగొనబడలేదు';
        return 'No states found';
      }
      if (key == 'no_communities_found_in') {
        final level = namedArgs?['level'] ?? '';
        if (locale == 'te') return 'ఈ $level లో సంఘాలేవీ లేవు';
        return 'No communities found in this $level';
      }
      if (key == 'create_community_in') {
        final name = namedArgs?['name'] ?? '';
        if (locale == 'te') return '$name లో మొదటి సంఘాన్ని సృష్టించండి';
        return 'Be the first to create a community in $name';
      }
      if (key == 'create_new_community') {
        if (locale == 'te') return 'కొత్త సంఘాన్ని సృష్టించండి';
        return 'Create New Community';
      }
      if (key == 'failed_vote_err') {
        if (locale == 'te') return 'ఓటు వేయడం విఫలమైంది';
        return 'Failed to vote';
      }
      if (key == 'failed_delete_post_err') {
        if (locale == 'te') return 'పోస్ట్‌ను తొలగించడం విఫలమైంది';
        return 'Failed to delete post';
      }
      if (key == 'failed_update_post_err') {
        if (locale == 'te') return 'పోస్ట్‌ను నవీకరించడం విఫలమైంది';
        return 'Failed to update post';
      }
      if (key == 'failed_create_post_err') {
        if (locale == 'te') return 'పోస్ట్‌ను సృష్టించడం విఫలమైంది';
        return 'Failed to create post';
      }

      if (key == 'help_support_title') {
        if (locale == 'te') return 'సహాయం & మద్దతు';
        return 'Help & Support';
      }
      if (key == 'call_us_option') {
        if (locale == 'te') return 'మాకు కాల్ చేయండి';
        return 'Call Us';
      }
      if (key == 'whatsapp_option') return 'WhatsApp';
      if (key == 'email_option') {
        if (locale == 'te') return 'ఈమెయిల్';
        return 'Email';
      }
      if (key == 'faq_title') {
        if (locale == 'te') return 'తరచుగా అడిగే ప్రశ్నలు';
        return 'Frequently Asked Questions';
      }
      if (key == 'quick_links_title') {
        if (locale == 'te') return 'త్వరిత లింకులు';
        return 'Quick Links';
      }
      if (key == 'video_tutorials_link') {
        if (locale == 'te') return 'వీడియో ట్యుటోరియల్స్';
        return 'Video Tutorials';
      }
      if (key == 'user_guide_link') {
        if (locale == 'te') return 'యూజర్ గైడ్ (PDF)';
        return 'User Guide (PDF)';
      }

      if (key == 'faq_q1') {
        if (locale == 'te') return 'నేను కొత్త అద్దెదారుని ఎలా చేర్చాలి?';
        return 'How do I add a new tenant?';
      }
      if (key == 'faq_a1') {
        if (locale == 'te') {
          return 'రూమ్ ఆక్యుపెన్సీ పేజీకి వెళ్లి, ఏదైనా ఖాళీ బెడ్‌పై ట్యాప్ చేసి, "అద్దెదారుని జోడించు" ఎంచుకోండి. KYC పత్రాలు మరియు చెల్లింపు సమాచారంతో సహా అద్దెదారు వివరాలను పూరించండి.';
        }
        return 'Go to the Room Occupancy page, tap on any vacant bed, and select "Add Tenant". Fill in the tenant details including KYC documents and payment information.';
      }
      if (key == 'faq_q2') {
        if (locale == 'te') return 'నేను అద్దె చెల్లింపులను ఎలా సేకరించాలి?';
        return 'How do I collect rent payments?';
      }
      if (key == 'faq_a2') {
        if (locale == 'te') {
          return 'టెనెంట్స్ లిస్ట్ నుండి అద్దెదారుని ఎంచుకోండి, "పేమెంట్ జోడించు" పై ట్యాప్ చేయండి, మొత్తం మరియు పేమెంట్ మోడ్‌ను నమోదు చేయండి మరియు హిస్టరీని అప్‌డేట్ చేయడానికి సేవ్ చేయండి.';
        }
        return 'Select a tenant from the Tenants list, tap on "Add Payment", enter the amount and payment mode, and save to update the history.';
      }
      if (key == 'start_by_adding_property_desc') {
        if (locale == 'te') {
          return 'ఈ విభాగాన్ని నిర్వహించడానికి దయచేసి ముందుగా ఒక ప్రాపర్టీని జోడించండి.';
        }
        if (locale == 'hi') {
          return 'कृपया इस अनुभाग को प्रबंधित करने के लिए पहले एक संपत्ति जोड़ें।';
        }
        if (locale == 'ta') {
          return 'இந்த பகுதியை నిர்வகிக்க முதலில் ஒரு சொத்தைச் சேர்க்கவும்.';
        }
        if (locale == 'kn') {
          return 'ಈ ವಿಭಾಗವನ್ನು ನಿರ್ವಹಿಸಲು ದಯವಿಟ್ಟು ಮೊದಲು ಆಸ್ತಿಯನ್ನು ಸೇರಿಸಿ.';
        }
        if (locale == 'ml') {
          return 'ഈ വിഭാഗം ನಿಯന്ത്രിക്കുന്നതിന് ದయവായി ആദ്യം ಒಂದು ಪ್ರಾಪರ್ಟಿ ಸೇರಿಸಿ.';
        }
        return 'Please add a property first to manage this section.';
      }
      if (key == 'financial_insights') {
        if (locale == 'te') return 'ఆర్థిక వివరాలు';
        if (locale == 'hi') return 'वित्तीय इनसाइट्स';
        if (locale == 'ta') return 'நிதி புள்ளிவிவரங்கள்';
        if (locale == 'kn') return 'ಹಣಕಾಸಿನ ಒಳನೋಟಗಳು';
        return 'Financial Insights';
      }
      if (key == 'financial_insights_sub') {
        if (locale == 'te') return 'ఆదాయం మరియు ఖర్చులు';
        if (locale == 'hi') return 'अपनी कमाई और खर्चों को ट्रैक करें';
        if (locale == 'ta') {
          return 'உங்கள் வருமானம் மற்றும் செலவுகளைக் கண்காணிக்கவும்';
        }
        if (locale == 'kn') return 'ನಿಮ್ಮ ಆದಾಯ ಮತ್ತು ವೆಚ್ಚಗಳನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಿ';
        return 'Track your earnings and expenses';
      }
      if (key == 'faq_q3') {
        if (locale == 'te') {
          return 'నేను అద్దెదారుని మరొక బెడ్‌కు ఎలా మార్చాలి?';
        }
        return 'How do I transfer a tenant to another bed?';
      }
      if (key == 'faq_a3') {
        if (locale == 'te') {
          return 'అద్దెదారు వివరాలను తెరిచి, "బెడ్ బదిలీ" ఎంచుకోండి, రూమ్ మరియు బెడ్ నంబర్‌ను ఎంచుకుని, బదిలీని నిర్ధారించండి.';
        }
        return 'Open the tenant details, select "Transfer Bed", choose the target room and bed number, and confirm the transfer.';
      }
      if (key == 'faq_q4') {
        if (locale == 'te') {
          return 'అద్దెదారు చెక్అవుట్‌ను నేను ఎలా ప్రాసెస్ చేయాలి?';
        }
        return 'How do I process a tenant checkout?';
      }
      if (key == 'faq_a4') {
        if (locale == 'te') {
          return 'అద్దెదారు వివరాలలో, "చెక్అవుట్" పై ట్యాప్ చేయండి, ఏవైనా బాకీ ఉన్న బకాయిలను క్లియర్ చేయండి మరియు బెడ్ విడుదలను నిర్ధారించండి.';
        }
        return 'In the tenant details, tap on "Checkout", clear any outstanding dues, and confirm the release of the occupied bed.';
      }
      if (key == 'faq_q5') {
        if (locale == 'te') return 'నేను స్టాఫ్ యాక్సెస్‌ను ఎలా నిర్వహించాలి?';
        return 'How do I manage staff access?';
      }
      if (key == 'faq_a5') {
        if (locale == 'te') {
          return 'కొత్త సభ్యులను చేర్చడానికి మరియు వారి అనుమతి స్థాయిలను నిర్వచించడానికి సెట్టింగ్‌లలోని స్టాఫ్ మేనేజ్‌మెంట్‌కు వెళ్లండి.';
        }
        return 'Go to Staff Management in Settings to add new members and define their specific permission levels.';
      }
      if (key == 'faq_q6') {
        if (locale == 'te') {
          return 'నేను మెయింటెనెన్స్ సమస్యను ఎలా నివేదించాలి?';
        }
        return 'How do I report a maintenance issue?';
      }
      if (key == 'faq_a6') {
        if (locale == 'te') {
          return 'అద్దెదారులు వారి యాప్ ద్వారా నివేదించవచ్చు లేదా మీరు డ్యాష్‌బోర్డ్ లోని "ఫిర్యాదులు" విభాగంలో మాన్యువల్‌గా ఫిర్యాదును జోడించవచ్చు.';
        }
        return 'Tenants can report via their app, or you can manually add a complaint in the "Complaints" section of the dashboard.';
      }

      if (key == 'refer_friend') {
        if (locale == 'te') return 'స్నేహితుడిని రిఫర్ చేయండి';
        if (locale == 'ta') return 'நண்பரைப் பரிந்துரைக்கவும்';
        if (locale == 'hi') return 'मित्र को संदर्भित करें';
        if (locale == 'kn') return 'ಸ್ನೇಹಿತನನ್ನು ಶಿಫಾರಸು ಮಾಡಿ';
        if (locale == 'ml') return 'கூട്ടുകാരനെ പരിചയപ്പെടുത്തുക';
        return 'Refer a Friend';
      }
      if (key == 'refer_title') {
        if (locale == 'te') return 'రిఫర్ చేయండి మరియు సంపాదించండి';
        if (locale == 'ta') return 'பரிந்துரைத்து வெகுமதிகளைப் பெறுங்கள்';
        if (locale == 'hi') return 'रेफर करें और पुरस्कार अर्जित करें';
        if (locale == 'kn') return 'ಶಿಫಾರಸು ಮಾಡಿ ಮತ್ತು ಬಹುಮಾನ ಗೆಲ್ಲಿ';
        if (locale == 'ml') return 'റഫർ ചെയ്ത് സമ്മാനങ്ങൾ നേടുക';
        return 'Refer & Earn Rewards';
      }
      if (key == 'refer_desc') {
        if (locale == 'te') {
          return 'మీ రిఫరల్ కోడ్‌ను మీ స్నేహితులతో పంచుకోండి మరియు వారు స్టే ఇండియా యాప్‌లో చేరినప్పుడు అద్భుతమైన రివార్డులను పొందండి.';
        }
        if (locale == 'ta') {
          return 'உங்கள் பரிந்துரைக் குறியீட்டை உங்கள் நண்பர்களுடன் பகிர்ந்து கொள்ளுங்கள் மற்றும் அவர்கள் ஸ்டே இந்தியா குடும்பத்தில் இணையும் போது அற்புதமான வெகுமதிகளைப் பெறுங்கள்.';
        }
        if (locale == 'hi') {
          return 'अपने दोस्तों के साथ अपना रेफरल कोड साझा करें और जब वे स्टे इंडिया परिवार में शामिल हों तो रोमांचक पुरस्कार अर्जित करें।';
        }
        if (locale == 'kn') {
          return 'ನಿಮ್ಮ ರೆಫರಲ್ ಕೋಡ್ ಅನ್ನು ನಿಮ್ಮ ಸ್ನೇಹಿತರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಿ ಮತ್ತು ಅವರು ಸ್ಟೇ ಇಂಡಿಯಾ ಕುಟುಂಬವನ್ನು ಸೇರಿದಾಗ ರೋಮಾಂಚಕಾರಿ ಬಹುಮಾನಗಳನ್ನು ಗಳಿಸಿ.';
        }
        if (locale == 'ml') {
          return 'നിങ്ങളുടെ റഫറൽ കോഡ് നിങ്ങളുടെ ചങ്ങാതിമാരുമായി പങ്കിടുക, അവർ സ്റ്റേ ഇന്ത്യ കുടുംബത്തിൽ ചേരുമ്പോൾ ആവേശകരമായ സമ്മാനങ്ങൾ നേടുക.';
        }
        return 'Share your referral code with your friends and earn exciting rewards when they join the Stay India family.';
      }
      if (key == 'your_referral_code') {
        if (locale == 'te') return 'మీ రిఫరల్ కోడ్';
        if (locale == 'ta') return 'உங்கள் பரிந்துரைக் குறியீடு';
        if (locale == 'hi') return 'आपका रेफरल कोड';
        if (locale == 'kn') return 'ನಿಮ್ಮ ರೆಫರಲ್ ಕೋಡ್';
        if (locale == 'ml') return 'ನಿങ്ങളുടെ റഫറൽ കോഡ്';
        return 'YOUR REFERRAL CODE';
      }
      if (key == 'code_copied') {
        if (locale == 'te') return 'కోడ్ కాపీ చేయబడింది!';
        if (locale == 'ta') return 'பரிந்துரைக் குறியீடு நகலெடுக்கப்பட்டது!';
        if (locale == 'hi') return 'रेफरल कोड कॉपी किया गया!';
        if (locale == 'kn') return 'ರೆಫರಲ್ ಕೋಡ್ ನಕಲಿಸಲಾಗಿದೆ!';
        if (locale == 'ml') return 'റഫറൽ കോഡ് കോപ്പി ചെയ്തു!';
        return 'Referral code copied!';
      }
      if (key == 'copy') {
        if (locale == 'te') return 'కాపీ';
        if (locale == 'ta') return 'நகலெடு';
        if (locale == 'hi') return 'कॉपी';
        if (locale == 'kn') return 'ನಕಲಿಸು';
        if (locale == 'ml') return 'കോപ്പി';
        return 'Copy';
      }
      if (key == 'share_whatsapp') {
        if (locale == 'te') return 'వాట్సాప్‌లో షేర్ చేయండి';
        if (locale == 'ta') return 'வாட்ஸ்அப்பில் பகிரவும்';
        if (locale == 'hi') return 'व्हाट्सएप पर साझा करें';
        if (locale == 'kn') return 'ವಾಟ್ಸಾಪ್‌ನಲ್ಲಿ ಹಂಚಿಕೊಳ್ಳಿ';
        if (locale == 'ml') return 'ವಾട്സ്ആപ്പിൽ പങ്കിടുക';
        return 'Share on WhatsApp';
      }
      if (key == 'share_referral_link') {
        if (locale == 'te') return 'రిఫరల్ లింక్‌ను షేర్ చేయండి';
        if (locale == 'ta') return 'பரிந்துரை இணைப்பைப் பகிரவும்';
        if (locale == 'hi') return 'रेफरल लिंक साझा करें';
        if (locale == 'kn') return 'ರೆಫರಲ್ ಲಿಂಕ್ ಹಂಚಿಕೊಳ್ಳಿ';
        if (locale == 'ml') return 'റഫറൽ ಲಿಂಕ್ പങ്കിടുക';
        return 'Share Referral Link';
      }
      if (key == 'announcements_title') {
        if (locale == 'te') return 'ప్రకటనలు';
        if (locale == 'ta') return 'அறிவிப்புகள்';
        if (locale == 'hi') return 'घोषणाएँ';
        if (locale == 'kn') return 'ಘೋಷಣೆಗಳು';
        if (locale == 'ml') return 'അറിയിപ്പുകൾ';
        return 'Announcements';
      }
      if (key == 'broadcasting_center_title') {
        if (locale == 'te') return 'బ్రాడ్‌కాస్టింగ్ సెంటర్';
        if (locale == 'ta') return 'ஒளிபரப்பு மையம்';
        if (locale == 'hi') return 'प्रसारण केंद्र';
        if (locale == 'kn') return 'ಪ್ರಸಾರ ಕೇಂದ್ರ';
        if (locale == 'ml') return 'ബ്രോഡ്കാസ്റ്റിംഗ് സെന്റർ';
        return 'Broadcasting Center';
      }
      if (key == 'broadcasting_center_desc') {
        if (locale == 'te') {
          return 'ముఖ్యమైన అప్‌డేట్‌లతో మీ నివాసితులందరినీ తక్షణమే చేరుకోండి.';
        }
        if (locale == 'ta') {
          return 'முக்கியமான புதுப்பிப்புகளுடன் உங்கள் குடியிருப்பாளர்கள் அனைவரையும் உடனடியாக சென்றடையுங்கள்.';
        }
        if (locale == 'hi') {
          return 'महत्वपूर्ण अपडेट के साथ अपने सभी निवासियों तक तुरंत पहुँचें।';
        }
        if (locale == 'kn') {
          return 'ಪ್ರಮುಖ ನವೀಕರಣಗಳೊಂದಿಗೆ ನಿಮ್ಮ ಎಲ್ಲಾ ನಿವಾಸಿಗಳನ್ನು தಕ್ಷಣ ತಲುಪಿ.';
        }
        if (locale == 'ml') {
          return 'പ്രധാനപ്പെട്ട അപ്‌ഡേറ്റുകൾ ഉപയോഗിച്ച് നിങ്ങളുടെ എല്ലാ താമസക്കാരിലേക്കും തൽക്ഷണം എത്തിച്ചേരുക.';
        }
        return 'Reach all your residents instantly with important updates.';
      }
      if (key == 'templates_tab') {
        if (locale == 'te') return 'టెంప్లేట్లు';
        if (locale == 'ta') return 'டெம்ப்ளேட்டுகள்';
        if (locale == 'hi') return 'टेम्पलेट्स';
        if (locale == 'kn') return 'ಟೆಂಪ್ಲೇಟ್‌ಗಳು';
        if (locale == 'ml') return 'ടെംപ്ലേറ്റുകൾ';
        return 'Templates';
      }
      if (key == 'recent_sent_tab') {
        if (locale == 'te') return 'ఇటీవల పంపినవి';
        if (locale == 'ta') return 'சமீபத்தில் அனுப்பியவை';
        if (locale == 'hi') return 'हाल ही में भेजे गए';
        if (locale == 'kn') return 'ಇತ್ತೀಚೆಗೆ ಕಳುಹಿಸಲಾಗಿದೆ';
        if (locale == 'ml') return 'അടുത്തിടെ അയച്ചവ';
        return 'Recent Sent';
      }
      if (key == 'search_templates_hint') {
        if (locale == 'te') return 'టెంప్లేట్‌ల కోసం వెతకండి...';
        if (locale == 'ta') return 'டெம்ப்ளேட்டுகளைத் தேடுங்கள்...';
        if (locale == 'hi') return 'टेम्पलेट्स खोजें...';
        if (locale == 'kn') return 'ಟೆಂಪ್ಲೇಟ್‌ಗಳನ್ನು ಹುಡುಕಿ...';
        if (locale == 'ml') return 'ടെംപ്ലേറ്റുകൾ തിരയുക...';
        return 'Search templates...';
      }
      if (key == 'write_custom_announcement') {
        if (locale == 'te') return 'కస్టమ్ ప్రకటన రాయండి';
        if (locale == 'ta') return 'தனிப்பயன் அறிவிப்பை எழுதுங்கள்';
        if (locale == 'hi') return 'कस्टम घोषणा लिखें';
        if (locale == 'kn') return 'ಕಸ್ಟಮ್ ಘೋಷಣೆ ಬರೆಯಿರಿ';
        if (locale == 'ml') return 'ഇഷ്‌ടാനുസൃത അറിയിപ്പ് എഴുതുക';
        return 'Write Custom Announcement';
      }
      if (key == 'category_all') {
        if (locale == 'te') return 'అన్నీ';
        if (locale == 'ta') return 'அனைத்தும்';
        if (locale == 'hi') return 'सभी';
        if (locale == 'kn') return 'ಎಲ್ಲಾ';
        if (locale == 'ml') return 'എല്ലാം';
        return 'All';
      }
      if (key == 'category_food') {
        if (locale == 'te') return 'ఆహారం';
        if (locale == 'ta') return 'உணவு';
        if (locale == 'hi') return 'भोजन';
        if (locale == 'kn') return 'ಆಹಾರ';
        if (locale == 'ml') return 'ഭക്ഷണം';
        return 'Food';
      }
      if (key == 'category_payments') {
        if (locale == 'te') return 'చెల్లింపులు';
        if (locale == 'ta') return 'கட்டணங்கள்';
        if (locale == 'hi') return 'भुगतान';
        if (locale == 'kn') return 'ಪಾವತಿಗಳು';
        if (locale == 'ml') return 'പേയ്‌മെന്റുകൾ';
        return 'Payments';
      }
      if (key == 'category_maintenance') {
        if (locale == 'te') return 'నిర్వహణ';
        if (locale == 'ta') return 'பராமரிப்பு';
        if (locale == 'hi') return 'रखरखाव';
        if (locale == 'kn') return 'ನಿವರ್ಹಣೆ';
        if (locale == 'ml') return 'മെയിന്റനൻസ്';
        return 'Maintenance';
      }
      if (key == 'category_rules') {
        if (locale == 'te') return 'నిబంధనలు';
        if (locale == 'ta') return 'விதிகள்';
        if (locale == 'hi') return 'नियम';
        if (locale == 'kn') return 'ನಿಯಮಗಳು';
        if (locale == 'ml') return 'നിയമങ്ങൾ';
        return 'Rules';
      }
      if (key == 'category_events') {
        if (locale == 'te') return 'ఈవెంట్స్';
        if (locale == 'ta') return 'நிகழ்வுகள்';
        if (locale == 'hi') return 'कार्यक्रम';
        if (locale == 'kn') return 'ಕಾರ್ಯಕ್ರಮಗಳು';
        if (locale == 'ml') return 'പരിപാടികൾ';
        return 'Events';
      }
      if (key == 'template_today_menu_title') {
        if (locale == 'te') return 'నేటి మెనూ';
        if (locale == 'ta') return 'இன்றைய மெனு';
        if (locale == 'hi') return 'आज का मेनू';
        if (locale == 'kn') return 'ಇಂದಿನ ಮೆನು';
        if (locale == 'ml') return 'ഇന്നത്തെ ಮೆനു';
        return 'Today\'s Menu';
      }
      if (key == 'template_today_menu_desc') {
        if (locale == 'te') {
          return 'తాజా భోజనం సిద్ధం! మెస్ ఏరియాలో నేటి రుచికరమైన మెనూని చూడండి.';
        }
        if (locale == 'ta') {
          return 'புதிய உணவுகள் பரிமாறப்படுகின்றன! மெஸ் பகுதியில் இன்றைய சுவையான மெனுவை பாருங்கள்.';
        }
        if (locale == 'hi') {
          return 'ताजा भोजन परोसा गया! मेस क्षेत्र में आज का स्वादिष्ट मेनू देखें।';
        }
        if (locale == 'kn') {
          return 'ತಾಜಾ ಊಟ ಸಿದ್ಧವಾಗಿದೆ! ಮೆಸ್ ಪ್ರದೇಶದಲ್ಲಿ ಇಂದಿನ ರುಚಿಕರವಾದ ಮೆನುವನ್ನು ಪರಿಶೀಲಿಸಿ.';
        }
        if (locale == 'ml') {
          return 'ഫ്രഷ് ഭക്ഷണം തയാറാണ്! മെസ് ഏരിയയിലെ ഇന്നത്തെ സ്വാദിഷ്ടമായ മെനു പരിശോധിക്കുക.';
        }
        return 'Fresh meals served! Check out today\'s delicious menu in the mess area.';
      }
      if (key == 'template_rent_reminder_title') {
        if (locale == 'te') return 'అద్దె రిమైండర్';
        if (locale == 'ta') return 'வாடகை நினைவூட்டல்';
        if (locale == 'hi') return 'किराया अनुस्मारक';
        if (locale == 'kn') return 'ಬಾಡಿಗೆ ಜ್ಞಾಪನೆ';
        if (locale == 'ml') return 'வாടക ഓർമ്മപ്പെടുത്തൽ';
        return 'Rent Reminder';
      }
      if (key == 'template_rent_reminder_desc') {
        if (locale == 'te') {
          return 'అద్దె చెల్లించవలసిన గడువు 5వ తేదీ వరకు అని గుర్తు చేస్తున్నాము. దయచేసి సకాలంలో చెల్లింపును నిర్ధారించుకోండి.';
        }
        if (locale == 'ta') {
          return 'வாடகை 5 ஆம் தேதிக்குள் செலுத்தப்பட வேண்டும் என்பதற்கான நட்பு நினைவூட்டல். தயவுசெய்து சரியான நேரத்தில் பணம் செலுத்துவதை உறுதிசெய்யவும்.';
        }
        if (locale == 'hi') {
          return 'किराया 5 तारीख तक देय होने का अनुस्मारक। कृपया समय पर भुगतान सुनिश्चित करें।';
        }
        if (locale == 'kn') {
          return 'ಬಾಡಿಗೆಯನ್ನು 5 ನೇ ತಾರೀಖಿನೊಳಗೆ పಾವತಿಸಬೇಕೆಂಬ ಜ್ಞಾಪನೆ. ದಯವಿಟ್ಟು ಸಮಯಕ್ಕೆ ಸರಿಯಾಗಿ ಪಾವತಿಯನ್ನು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.';
        }
        if (locale == 'ml') {
          return 'വാടക 5-ാം തീയതിക്കുള്ളിൽ അടയ്ക്കണമെന്ന് ഓർമ്മിപ്പിക്കുന്നു. കൃത്യസമയത്ത് പേയ്‌മെന്റ് ഉറപ്പാക്കുക.';
        }
        return 'Friendly reminder that rent is due by the 5th. Please ensure timely payment.';
      }
      if (key == 'template_water_update_title') {
        if (locale == 'te') return 'నీటి సరఫరా అప్‌డేట్';
        if (locale == 'ta') return 'குடிநீர் விநியோக அறிவிப்பு';
        if (locale == 'hi') return 'जलापूर्ति अपडेट';
        if (locale == 'kn') return 'ನೀರು ಸರಬరాಜು ಅಪ್ಡೇಟ್';
        if (locale == 'ml') return 'കുടിവെള്ള വിതരണ അറിയിപ്പ്';
        return 'Water Supply Update';
      }
      if (key == 'template_water_update_desc') {
        if (locale == 'te') {
          return 'ఈ రోజు మధ్యాహ్నం 2 గంటల నుండి 4 గంటల వరకు నిర్వహణ పనుల కారణంగా నీటి సరఫరా తాత్కాలికంగా నిలిపివేయబడుతుంది.';
        }
        if (locale == 'ta') {
          return 'பராமரிப்பு பணி காரணமாக இன்று மதியம் 2 மணி முதல் 4 மணி வரை குடிநீர் விநியோகம் தற்காலிகமாக நிறுத்தப்படும்.';
        }
        if (locale == 'hi') {
          return 'रखरखाव के कारण आज दोपहर 2 बजे से 4 बजे तक जलापूर्ति अस्थायी रूप से निलंबित रहेगी।';
        }
        if (locale == 'kn') {
          return 'ನಿರ್ವಹಣಾ ಕೆಲಸದ ಹಿನ್ನೆಲೆಯಲ್ಲಿ ಇಂದು ಮಧ್ಯಾಹ್ನ 2 ರಿಂದ 4 ರವರೆಗೆ ನೀರು ಸರಬರಾಜನ್ನು ತಾತ್ಕಾಲಿಕವಾಗಿ ಸ್ಥಗಿತಗೊಳಿಸಲಾಗುವುದು.';
        }
        if (locale == 'ml') {
          return 'അറ്റകുറ്റപ്പണികൾ കാരണം ഇന്ന് ഉച്ചയ്ക്ക് 2 മണി മുതൽ 4 മണി വരെ കുടിവെള്ള വിതരണം താൽക്കാലികമായി തടസ്സപ്പെടും.';
        }
        return 'Water supply will be temporarily suspended for maintenance today from 2 PM to 4 PM.';
      }
      if (key == 'template_gate_timing_title') {
        if (locale == 'te') return 'గేట్ సమయాల రిమైండర్';
        if (locale == 'ta') return 'கேட் நேர நினைவூட்டல்';
        if (locale == 'hi') return 'गेट टाइमिंग रिमाइंडर';
        if (locale == 'kn') return 'ಗೇಟ್ ಸಮಯದ ಜ್ಞಾಪನೆ';
        if (locale == 'ml') return 'ಗೇറ്റ് സമയ ഓർമ്മപ്പെടുത്തൽ';
        return 'Gate Timing Reminder';
      }
      if (key == 'template_gate_timing_desc') {
        if (locale == 'te') {
          return 'ప్రధాన గేట్ ప్రతిరోజూ రాత్రి 10:30 గంటలకు మూసివేయబడుతుందని గుర్తుంచుకోండి. దయచేసి సెక్యూరిటీ బృందానికి సహకరించండి.';
        }
        if (locale == 'ta') {
          return 'தினமும் இரவு 10:30 மணிக்கு பிரதான கேட் மூடப்படும் என்பதை நினைவிற் கொள்ளவும். பாதுகாப்பு குழுவினருக்கு ஒத்துழைப்பு நல்கவும்.';
        }
        if (locale == 'hi') {
          return 'कृपया ध्यान दें कि मुख्य गेट प्रतिदिन रात 10:30 बजे बंद हो जाता है। कृपया सुरक्षा टीम का सहयोग करें।';
        }
        if (locale == 'kn') {
          return 'ಮುಖ್ಯ ಗೇಟ್ ಪ್ರತಿದಿನ ರಾತ್ರಿ 10:30 ಕ್ಕೆ ಮುಚ್ಚಲ್ಪಡುತ್ತದೆ ಎಂಬುದನ್ನು ದಯವಿಟ್ಟು ನೆನಪಿನಲ್ಲಿಡಿ. ದಯವಿಟ್ಟು ಭದ್ರತಾ ಸಿಬ್ಬಂದಿಗೆ ಸಹಕರಿಸಿ.';
        }
        if (locale == 'ml') {
          return 'ಪ್ರധാന ഗേറ്റ് ദിവസവും രാത്രി 10:30-ന് അടയ്ക്കുമെന്ന് ദയവായി ഓർക്കുക. സെക്യൂരിറ്റി ടീമുമായി സഹകരിക്കുക.';
        }
        return 'Please remember that the main gate closes at 10:30 PM daily. Kindly cooperate with the security team.';
      }
      if (key == 'template_movie_night_title') {
        if (locale == 'te') return 'ఈ రాత్రికి మూవీ నైట్';
        if (locale == 'ta') return 'இன்று இரவு திரைப்பட இரவு';
        if (locale == 'hi') return 'आज रात मूवी नाइट';
        if (locale == 'kn') return 'ಇಂದು ರಾತ್ರಿ ಮೂವಿ ನೈಟ್';
        if (locale == 'ml') return 'ഇന്ന് രാത്രി മൂവി നൈറ്റ്';
        return 'Movie Night Tonight';
      }
      if (key == 'template_movie_night_desc') {
        if (locale == 'te') {
          return 'ఈ రోజు రాత్రి 8 గంటలకు కామన్ ఏరియాలో జరిగే మూవీ స్క్రీనింగ్‌కు విచ్చేయండి. ఉచిత స్నాక్స్ అందించబడతాయి!';
        }
        if (locale == 'ta') {
          return 'இன்று இரவு 8 மணிக்கு பொது இடத்தில் நடைபெறும் திரைப்படக் காட்சியில் எங்களோடு இணையுங்கள். இலவச தின்பண்டங்கள் வழங்கப்படும்!';
        }
        if (locale == 'hi') {
          return 'आज रात 8 बजे कॉमन एरिया में मूवी स्क्रीनिंग के लिए आएं। मुफ्त स्नैक्स दिए जाएंगे!';
        }
        if (locale == 'kn') {
          return 'ಇಂದು ರಾತ್ರಿ 8 ಗಂಟೆಗೆ ಕಾಮನ್ ಏರಿಯಾದಲ್ಲಿ ನಡೆಯಲಿರುವ ಚലನಚಿತ್ರ ಪ್ರದರ್ಶನಕ್ಕೆ ನಮ್ಮೊಂದಿಗೆ ಸೇರಿಕೊಳ್ಳಿ. ಉಚಿತ ಸ್ನ್ಯาಕ್ಸ್ ನೀಡಲಾಗುವುದು!';
        }
        if (locale == 'ml') {
          return 'ഇന്ന് രാത്രി 8 മണിക്ക് കോമൺ ഏരിയയിൽ നടക്കുന്ന സിനിമ പ്രദർശനത്തിലേക്ക് എല്ലാവരെയും സ്വാഗതം ചെയ്യുന്നു. സൗജന്യ സ്നാക്സ് ഉണ്ടായിരിക്കും!';
        }
        return 'Join us for a movie screening tonight at 8 PM in the common area. Free snacks provided!';
      }
      if (key == 'reports_analytics_title') {
        if (locale == 'te') return 'నివేదికలు & విశ్లేషణలు';
        if (locale == 'ta') return 'அறிக்கைகள் & பகுப்பாய்வு';
        if (locale == 'hi') return 'रिपोर्ट और विश्लेषिकी';
        if (locale == 'kn') return 'ವರದಿಗಳು ಮತ್ತು ವಿಶ್ಲೇಷಣೆ';
        if (locale == 'ml') return 'റിപ്പോർട്ടുകളും വിശകലനവും';
        return 'Reports & Analytics';
      }
      if (key == 'date_range_label') {
        if (locale == 'te') return 'తేదీ పరిధి';
        if (locale == 'ta') return 'தேதி வரம்பு';
        if (locale == 'hi') return 'तारीख सीमा';
        if (locale == 'kn') return 'ದಿನಾಂಕದ ಶ್ರೇಣಿ';
        if (locale == 'ml') return 'තീയതി പരിധി';
        return 'DATE RANGE';
      }
      if (key == 'property_filter_label') {
        if (locale == 'te') return 'ప్రాపర్టీ ఫిల్టర్';
        if (locale == 'ta') return 'சொத்து வடிகட்டி';
        if (locale == 'hi') return 'संपत्ति फ़िल्टर';
        if (locale == 'kn') return 'ಆಸ್ತಿ ಫಿಲ್ಟರ್';
        if (locale == 'ml') return 'പ്രോപ്പർട്ടി ഫിൽട്ടർ';
        return 'PROPERTY FILTER';
      }
      if (key == 'all_properties_hint') {
        if (locale == 'te') return 'అన్ని ప్రాపర్టీలు';
        if (locale == 'ta') return 'அனைத்து சொத்துக்களும்';
        if (locale == 'hi') return 'सभी संपत्तियां';
        if (locale == 'kn') return 'ಎಲ್ಲಾ ಆಸ್ತಿಗಳು';
        if (locale == 'ml') return 'എല്ലാ പ്രോപ്പർട്ടികളും';
        return 'All Properties';
      }
      if (key == 'select_report_type_label') {
        if (locale == 'te') return 'నివేదిక రకాన్ని ఎంచుకోండి';
        if (locale == 'ta') return 'அறிக்கை வகையைத் தேர்ந்தெடுக்கவும்';
        if (locale == 'hi') return 'रिपोर्ट प्रकार चुनें';
        if (locale == 'kn') return 'ವರದಿ ಪ್ರಕಾರವನ್ನು ಆಯ್ಕೆಮಾಡಿ';
        if (locale == 'ml') return 'റിപ്പോർട്ട് തരം തിരഞ്ഞെടുക്കുക';
        return 'SELECT REPORT TYPE';
      }
      if (key == 'payments_report') {
        if (locale == 'te') return 'చెల్లింపులు';
        if (locale == 'ta') return 'கட்டணங்கள்';
        if (locale == 'hi') return 'भुगतान';
        if (locale == 'kn') return 'ಪಾವತಿಗಳು';
        if (locale == 'ml') return 'പേയ്‌മെന്റുകൾ';
        return 'Payments';
      }
      if (key == 'tenants_report') {
        if (locale == 'te') return 'టెనెంట్స్';
        if (locale == 'ta') return 'குடியிருப்பாளர்கள்';
        if (locale == 'hi') return 'किरायेदार';
        if (locale == 'kn') return 'ಬಾಡಿಗೆದಾರರು';
        if (locale == 'ml') return 'താമസക്കാർ';
        return 'Tenants';
      }
      if (key == 'bookings_report') {
        if (locale == 'te') return 'బుకింగ్స్';
        if (locale == 'ta') return 'பதிவுகள்';
        if (locale == 'hi') return 'बुकिंग';
        if (locale == 'kn') return 'ಬುಕಿಂಗ್‌ಗಳು';
        if (locale == 'ml') return 'ಬುക്കിംഗുകൾ';
        return 'Bookings';
      }
      if (key == 'data_preview_label') {
        if (locale == 'te') return 'డేటా ప్రివ్యూ';
        if (locale == 'ta') return 'தரவு முன்னோட்டம்';
        if (locale == 'hi') return 'डेटा पूर्वावलोकन';
        if (locale == 'kn') return 'ಡೇಟಾ ಮುನ್ನೋಟ';
        if (locale == 'ml') return 'ಡാറ്റ പ്രിവ്യൂ';
        return 'DATA PREVIEW';
      }
      if (key == 'showing_latest_5') {
        if (locale == 'te') return 'తాజా 5 చూపిస్తున్నాము';
        if (locale == 'ta') return 'சமீபத்திய 5 காட்டப்படுகிறது';
        if (locale == 'hi') return 'नवीनतम 5 दिखा रहा है';
        if (locale == 'kn') return 'ಇತ್ತೀಚಿನ 5 ಅನ್ನು ತೋರಿಸಲಾಗುತ್ತಿದೆ';
        if (locale == 'ml') return 'ഏറ്റവും പുതിയ 5 കാണിക്കുന്നു';
        return 'Showing latest 5';
      }
      if (key == 'export_data_label') {
        if (locale == 'te') return 'డేటాను ఎగుమతి చేయండి';
        if (locale == 'ta') return 'தரவை ஏற்றுமதி செய்';
        if (locale == 'hi') return 'डेटा निर्यात करें';
        if (locale == 'kn') return 'ಡೇಟಾವನ್ನು ರಫ್ತು ಮಾಡಿ';
        if (locale == 'ml') return 'ಡಾറ്റ കയറ്റുമതി ചെയ്യുക';
        return 'EXPORT DATA';
      }
      if (key == 'excel_export') {
        if (locale == 'te') return 'ఎక్సెల్ (.xlsx)';
        if (locale == 'ta') return 'எக்செல் (.xlsx)';
        if (locale == 'hi') return 'एक्सेल (.xlsx)';
        if (locale == 'kn') return 'ಎಕ್ಸೆಲ್ (.xlsx)';
        if (locale == 'ml') return 'ಎക്സൽ (.xlsx)';
        return 'Excel (.xlsx)';
      }
      if (key == 'pdf_report') {
        if (locale == 'te') return 'PDF నివేదిక';
        if (locale == 'ta') return 'PDF அறிக்கை';
        if (locale == 'hi') return 'पीडीएफ रिपोर्ट';
        if (locale == 'kn') return 'ಪಿಡಿಎಫ್ ವರದಿ';
        if (locale == 'ml') return 'പിಡಿഎഫ് റിപ്പോർട്ട്';
        return 'PDF Report';
      }
      if (key == 'processing_request') {
        if (locale == 'te') return 'అభ్యర్థనను ప్రాసెస్ చేస్తున్నాము...';
        if (locale == 'ta') return 'கோரிக்கையைச் செயலாக்குகிறது... ...';
        if (locale == 'hi') return 'अनुरोध पर कार्रवाई की जा रही है...';
        if (locale == 'kn') return 'ವಿನಂತಿಯನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗುತ್ತಿದೆ...';
        if (locale == 'ml') return 'അഭ്യർത്ഥന പ്രോസസ്സ് ചെയ്യുന്നു...';
        return 'Processing request...';
      }
      if (key == 'crunching_numbers_msg') {
        if (locale == 'te') return 'లెక్కలు వేస్తున్నాము...';
        if (locale == 'ta') return 'மதிப்புகளைக் கணக்கிடுகிறது...';
        if (locale == 'hi') return 'आंकड़ों की गणना की जा रही है...';
        if (locale == 'kn') return 'ಲೆಕ್ಕಾಚಾರ ಮಾಡಲಾಗುತ್ತಿದೆ...';
        if (locale == 'ml') return 'കണക്കുകൂട്ടലുകൾ നടത്തുന്നു...';
        return 'Crunching numbers...';
      }
      if (key == 'report_download_success') {
        if (locale == 'te') return 'నివేదిక విజయవంతంగా డౌన్‌లోడ్ చేయబడింది!';
        if (locale == 'ta') {
          return 'அறிக்கை வெற்றிகரமாக பதிவிறக்கம் செய்யப்பட்டது!';
        }
        if (locale == 'hi') return 'रिपोर्ट सफलतापूर्वक डाउनलोड की गई!';
        if (locale == 'kn') return 'ವರದಿಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಡೌನ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ!';
        if (locale == 'ml') return 'റിപ്പോർട്ട് വിജയകരമായി ഡൗൺലോഡ് ചെയ്‌തു!';
        return 'Report downloaded successfully!';
      }
      if (key == 'report_download_failed') {
        if (locale == 'te') return 'నివేదికను డౌన్‌లోడ్ చేయడంలో విఫలమైంది';
        if (locale == 'ta') return 'அறிக்கையைப் பதிவிறக்குவதில் தோல்வி';
        if (locale == 'hi') return 'रिपोर्ट डाउनलोड करने में विफल';
        if (locale == 'kn') return 'ವರದಿಯನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ';
        if (locale == 'ml') {
          return 'റിപ്പോർട്ട് ഡൗൺലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു';
        }
        return 'Failed to download report';
      }

      if (key == 'manage_offers') {
        if (locale == 'te') return 'ఆఫర్లను నిర్వహించండి';
        return 'Manage Offers';
      }
      if (key == 'create_offer') {
        if (locale == 'te') return 'ఆఫర్ను సృష్టించండి';
        return 'Create Offer';
      }
      if (key == 'search_offers_hint') {
        if (locale == 'te') return 'ఆఫర్లు, కోడ్స్ కోసం వెతకండి...';
        return 'Search offers, codes...';
      }
      if (key == 'no_offers_yet') {
        if (locale == 'te') return 'ఇంకా ఆఫర్లు ఏవీ లేవు';
        return 'No offers yet';
      }
      if (key == 'create_offer_desc') {
        if (locale == 'te') {
          return 'మీ ప్రాపర్టీల కోసం ప్రమోషనల్ ఆఫర్లను సృష్టించడం ప్రారంభించండి';
        }
        return 'Start creating promotional offers for your properties';
      }
      if (key == 'ends_label') {
        final dateStr = context != null
            ? (namedArgs?['date'] ?? '')
            : (namedArgs?['date'] ?? '');
        if (locale == 'te') return '$dateStrన ముగుస్తుంది';
        return 'Ends $dateStr';
      }
      if (key == 'starts_label') {
        final dateStr = context != null
            ? (namedArgs?['date'] ?? '')
            : (namedArgs?['date'] ?? '');
        if (locale == 'te') return '$dateStrన ప్రారంభమవుతుంది';
        return 'Starts $dateStr';
      }
      if (key == 'never') {
        if (locale == 'te') return 'ఎప్పుడూ కాదు';
        return 'never';
      }
      if (key == 'delete_offer_title') {
        if (locale == 'te') return 'ఆఫర్ను తొలగించాలా?';
        return 'Delete Offer?';
      }
      if (key == 'delete_offer_confirm') {
        if (locale == 'te') {
          return 'మీరు ఖచ్చితంగా ఈ ఆఫర్ను తొలగించాలనుకుంటున్నారా?';
        }
        return 'Are you sure you want to delete this offer?';
      }
      if (key == 'cancel') {
        if (locale == 'te') return 'రద్దు చేయి';
        return 'Cancel';
      }
      if (key == 'delete') {
        if (locale == 'te') return 'తొలగించు';
        return 'Delete';
      }
      if (key == 'edit_offer_details') {
        if (locale == 'te') return 'ఆఫర్ వివరాలను సవరించండి';
        return 'Edit Offer Details';
      }
      if (key == 'offer_title_hint') {
        if (locale == 'te') return 'ఆఫర్ శీర్షిక (ఉదా: వెల్కమ్ డిస్కౌంట్)';
        return 'Offer Title (e.g., Welcome Discount)';
      }
      if (key == 'offer_desc_hint') {
        if (locale == 'te') return 'ఆఫర్ వివరణ';
        return 'Offer Description';
      }
      if (key == 'promo_code_hint') {
        if (locale == 'te') return 'ప్రోమో కోడ్ (ఆప్షనల్)';
        return 'Promo Code (Optional)';
      }
      if (key == 'offer_type') {
        if (locale == 'te') return 'ఆఫర్ రకం';
        return 'Offer Type';
      }
      if (key == 'offer_type_promotional') {
        if (locale == 'te') return 'ప్రమోషనల్';
        return 'Promotional';
      }
      if (key == 'offer_type_percentage') {
        if (locale == 'te') return 'శాతం';
        return 'Percentage';
      }
      if (key == 'offer_type_flat') {
        if (locale == 'te') return 'ఫ్లాట్';
        return 'Flat';
      }
      if (key == 'offer_type_referral') {
        if (locale == 'te') return 'రెఫరల్';
        return 'Referral';
      }
      if (key == 'discount_percentage') {
        if (locale == 'te') return 'డిస్కౌంట్ శాతం (%)';
        return 'Discount Percentage (%)';
      }
      if (key == 'flat_discount_amount') {
        if (locale == 'te') return 'ఫ్లాట్ డిస్కౌంట్ మొత్తం (₹)';
        return 'Flat Discount Amount (₹)';
      }
      if (key == 'applicable_property_hint') {
        if (locale == 'te') return 'వర్తించే ప్రాపర్టీ';
        return 'Applicable Property';
      }
      if (key == 'global_all_properties') {
        if (locale == 'te') return 'అన్ని ప్రాపర్టీలు';
        return 'Global (All Properties)';
      }
      if (key == 'ends_never') {
        if (locale == 'te') return 'ఎప్పటికీ ముగియదు';
        return 'Ends: Never';
      }
      if (key == 'make_active_immediately') {
        if (locale == 'te') return 'వెంటనే యాక్టివ్ చేయండి';
        return 'Make active immediately';
      }
      if (key == 'publish_offer') {
        if (locale == 'te') return 'ఆఫర్ను ప్రచురించండి';
        return 'Publish Offer';
      }
      if (key == 'save_changes') {
        if (locale == 'te') return 'మార్పులను సేవ్ చేయి';
        return 'Save Changes';
      }
      if (key == 'search_room_tenant') {
        if (locale == 'te') return 'రూమ్ లేదా టెనెంట్ కోసం వెతకండి...';
        return 'Search room or tenant...';
      }
      if (key == 'no_residents_found') {
        if (locale == 'te') return 'నివాసితులు ఎవరూ కనుగొనబడలేదు';
        return 'No residents found';
      }
      if (key == 'select_property') {
        if (locale == 'te') return 'ప్రాపర్టీని ఎంచుకోండి';
        return 'Select Property';
      }
      if (key == 'switch_property') {
        if (locale == 'te') return 'ప్రాపర్టీని మార్చండి';
        return 'Switch Property';
      }

      if (key == 'bookings_title') {
        if (locale == 'te') return 'బుకింగ్‌లు';
        return 'Bookings';
      }
      if (key == 'bookings_subtitle') {
        if (locale == 'te') {
          return 'మీ అతిథి అభ్యర్థనలు మరియు బసలను నిర్వహించండి';
        }
        return 'Manage your guest requests and stays';
      }
      if (key == 'tab_requests') {
        if (locale == 'te') return 'అభ్యర్థనలు';
        return 'Requests';
      }
      if (key == 'tab_active') {
        if (locale == 'te') return 'ప్రస్తుత';
        return 'Active';
      }
      if (key == 'tab_history') {
        if (locale == 'te') return 'చరిత్ర';
        return 'History';
      }
      if (key == 'assign_room') {
        if (locale == 'te') return 'గది కేటాయించండి';
        return 'Assign Room';
      }
      if (key == 'reject') {
        if (locale == 'te') return 'తిరస్కరించండి';
        return 'Reject';
      }
      if (key == 'change_room') {
        if (locale == 'te') return 'గది మార్చండి';
        return 'Change Room';
      }
      if (key == 'checkout') {
        if (locale == 'te') return 'చెక్-అవుట్';
        return 'Check-out';
      }
      if (key == 'checkin_date') {
        if (locale == 'te') return 'చెక్-ఇన్ తేదీ';
        return 'Check-in Date';
      }
      if (key == 'room_type') {
        if (locale == 'te') return 'గది రకం';
        return 'Room Type';
      }
      if (key == 'kyc_pending') {
        if (locale == 'te') return 'KYC పెండింగ్';
        return 'KYC Pending';
      }
      if (key == 'no_bed_assigned') {
        if (locale == 'te') return 'బెడ్ కేటాయించలేదు';
        return 'No bed assigned';
      }
      if (key == 'booking_cancelled_status') {
        if (locale == 'te') return 'బుకింగ్ రద్దు చేయబడింది';
        return 'BOOKING CANCELLED';
      }
      if (key == 'stay_completed') {
        if (locale == 'te') return 'బస పూర్తయింది';
        return 'STAY COMPLETED';
      }
      if (key == 'no_pending_requests') {
        if (locale == 'te') return 'పెండింగ్ అభ్యర్థనలు ఏవీ లేవు';
        return 'No pending requests';
      }
      if (key == 'new_booking_requests_here') {
        if (locale == 'te') return 'కొత్త బుకింగ్ అభ్యర్థనలు ఇక్కడ కనిపిస్తాయి';
        return 'New booking requests will appear here';
      }
      if (key == 'filter_bookings') {
        if (locale == 'te') return 'బుకింగ్‌లను ఫిల్టర్ చేయండి';
        return 'Filter Bookings';
      }
      if (key == 'reset') {
        if (locale == 'te') return 'రీసెట్';
        return 'Reset';
      }
      if (key == 'kyc_status') {
        if (locale == 'te') return 'KYC స్థితి';
        return 'KYC Status';
      }
      if (key == 'verified') {
        if (locale == 'te') return 'ధృవీకరించబడింది';
        return 'Verified';
      }
      if (key == 'apply_filters') {
        if (locale == 'te') return 'ఫిల్టర్లను వర్తించు';
        return 'Apply Filters';
      }
      if (key == 'reject_booking_title') {
        if (locale == 'te') return 'బుకింగ్‌ను తిరస్కరించాలా?';
        return 'Reject Booking?';
      }
      if (key == 'reject_booking_confirm') {
        final name = namedArgs?['name'] ?? '';
        if (locale == 'te') {
          return 'మీరు ఖచ్చితంగా $name యొక్క బుకింగ్‌ను తిరస్కరించాలనుకుంటున్నారా?';
        }
        return 'Are you sure you want to reject the booking for $name?';
      }
      if (key == 'confirm_checkout_title') {
        if (locale == 'te') return 'చెక్-అవుట్ నిర్ధారించండి';
        return 'Confirm Check-out';
      }
      if (key == 'confirm_checkout_desc') {
        final name = namedArgs?['name'] ?? '';
        if (locale == 'te') {
          return 'మీరు ఖచ్చితంగా $name ని చెక్-అవుట్ చేయాలనుకుంటున్నారా?';
        }
        return 'Are you sure you want to check-out $name?';
      }
      if (key == 'no') {
        if (locale == 'te') return 'కాదు';
        return 'No';
      }
      if (key == 'make_active_immediately') {
        if (locale == 'te') return 'వెంటనే యాక్టివ్ చేయండి';
        return 'Make active immediately';
      }
      if (key == 'publish_offer') {
        if (locale == 'te') return 'ఆఫర్ను ప్రచురించండి';
        return 'Publish Offer';
      }
      if (key == 'save_changes') {
        if (locale == 'te') return 'మార్పులను సేవ్ చేయి';
        return 'Save Changes';
      }
      if (key == 'search_room_tenant') {
        if (locale == 'te') return 'రూమ్ లేదా టెనెంట్ కోసం వెతకండి...';
        return 'Search room or tenant...';
      }
      if (key == 'no_residents_found') {
        if (locale == 'te') return 'నివాసితులు ఎవరూ కనుగొనబడలేదు';
        return 'No residents found';
      }
      if (key == 'select_property') {
        if (locale == 'te') return 'ప్రాపర్టీని ఎంచుకోండి';
        return 'Select Property';
      }
      if (key == 'switch_property') {
        if (locale == 'te') return 'ప్రాపర్టీని మార్చండి';
        return 'Switch Property';
      }

      if (key == 'stock_management') {
        if (locale == 'te') return 'స్టాక్ మేనేజ్‌మెంట్';
        return 'Stock Management';
      }
      if (key == 'total_value') {
        if (locale == 'te') return 'మొత్తం విలువ';
        return 'Total Value';
      }
      if (key == 'low_stock') {
        if (locale == 'te') return 'తక్కువ స్టాక్';
        return 'Low Stock';
      }
      if (key == 'search_stock_hint') {
        if (locale == 'te') return 'కూరగాయలు, కిరాణా సామాగ్రిని వెతకండి...';
        return 'Search vegetables, groceries...';
      }
      if (key == 'grocery') {
        if (locale == 'te') return 'కిరాణా';
        return 'Grocery';
      }
      if (key == 'vegetables') {
        if (locale == 'te') return 'కూరగాయలు';
        return 'Vegetables';
      }
      if (key == 'cleaning') {
        if (locale == 'te') return 'క్లీనింగ్';
        return 'Cleaning';
      }
      if (key == 'other') {
        if (locale == 'te') return 'ఇతర';
        return 'Other';
      }
      if (key == 'no_matching_items') {
        if (locale == 'te') return 'సరిపోలే వస్తువులేవీ లేవు';
        return 'No matching items';
      }
      if (key == 'adjust_search_filters') {
        if (locale == 'te') {
          return 'మీ శోధన లేదా ఫిల్టర్‌లను సర్దుబాటు చేయడానికి ప్రయత్నించండి.';
        }
        return 'Try adjusting your search or filters.';
      }
      if (key == 'new_item') {
        if (locale == 'te') return 'కొత్త వస్తువు';
        return 'New Item';
      }
      if (key == 'in_stock') {
        if (locale == 'te') return 'స్టాక్‌లో ఉంది';
        return 'In Stock';
      }
      if (key == 'out_of_stock') {
        if (locale == 'te') return 'స్టాక్ అయిపోయింది';
        return 'Out of Stock';
      }

      if (key == 'quick_entry') {
        if (locale == 'te') return 'త్వరిత నమోదు';
        return 'Quick Entry';
      }
      if (key == 'select_stock_item') {
        if (locale == 'te') return 'స్టాక్ వస్తువును ఎంచుకోండి';
        return 'Select Stock Item';
      }
      if (key == 'search_ingredients') {
        if (locale == 'te') return 'పదార్థాలను వెతకండి...';
        return 'Search ingredients...';
      }
      if (key == 'no_items_available') {
        if (locale == 'te') return 'వస్తువులేవీ అందుబాటులో లేవు';
        return 'No items available';
      }
      if (key == 'use_query') {
        final query = namedArgs?['query'] ?? '';
        if (locale == 'te') return '"$query" ఉపయోగించండి';
        return 'Use "$query"';
      }
      if (key == 'item_name_label') {
        if (locale == 'te') return 'వస్తువు పేరు';
        return 'Item Name';
      }
      if (key == 'search_placeholder') {
        if (locale == 'te') return 'బియ్యం, పాలు, ఫినైల్ వెతకండి...';
        return 'Search Rice, Milk, Phenyl...';
      }
      if (key == 'category_label') {
        if (locale == 'te') return 'వర్గం';
        return 'Category';
      }
      if (key == 'unit_label') {
        if (locale == 'te') return 'యూనిట్';
        return 'Unit';
      }
      if (key == 'quantity_label') {
        if (locale == 'te') return 'పరిమాణం';
        return 'Quantity';
      }
      if (key == 'price_unit_label') {
        if (locale == 'te') return 'ధర/యూనిట్ (₹)';
        return 'Price/Unit (₹)';
      }
      if (key == 'total_amount_label') {
        if (locale == 'te') return 'మొత్తం మొత్తం (₹)';
        return 'Total Amount (₹)';
      }
      if (key == 'payment_mode_label') {
        if (locale == 'te') return 'చెల్లింపు విధానం';
        return 'Payment Mode';
      }
      if (key == 'notes_optional_label') {
        if (locale == 'te') return 'గమనికలు (ఐచ్ఛికం)';
        return 'Notes (Optional)';
      }
      if (key == 'add_note_hint') {
        if (locale == 'te') return 'ఒక గమనికను జోడించండి...';
        return 'Add a note...';
      }
      if (key == 'save_entry') {
        if (locale == 'te') return 'ఎంట్రీని సేవ్ చేయండి';
        return 'Save Entry';
      }
      if (key == 'select_item_error') {
        if (locale == 'te') return 'దయచేసి వస్తువు పేరును ఎంచుకోండి';
        return 'Please select an item name';
      }

      if (key == 'kg') return locale == 'te' ? 'కిలో' : 'kg';
      if (key == 'liters') return locale == 'te' ? 'లీటర్లు' : 'liters';
      if (key == 'pieces') return locale == 'te' ? 'ముక్కలు' : 'pieces';
      if (key == 'packets') return locale == 'te' ? 'ప్యాకెట్లు' : 'packets';
      if (key == 'units') return locale == 'te' ? 'యూనిట్లు' : 'units';

      if (key == 'upi') return 'UPI';
      if (key == 'cash') return locale == 'te' ? 'నగదు' : 'Cash';
      if (key == 'bank_transfer') {
        return locale == 'te' ? 'బ్యాంక్ బదిలీ' : 'Bank Transfer';
      }

      if (key == 'activity_history') {
        if (locale == 'te') return 'యాక్టివిటీ చరిత్ర';
        return 'Activity History';
      }
      if (key == 'current_stock') {
        if (locale == 'te') return 'ప్రస్తుత స్టాక్';
        return 'Current Stock';
      }
      if (key == 'threshold') {
        if (locale == 'te') return 'కనీస పరిమితి';
        return 'Threshold';
      }
      if (key == 'avg_price') {
        if (locale == 'te') return 'సగటు ధర';
        return 'Avg Price';
      }
      if (key == 'refill') {
        if (locale == 'te') return 'రీఫిల్';
        return 'Refill';
      }
      if (key == 'consume') {
        if (locale == 'te') return 'వినియోగం';
        return 'Consume';
      }
      if (key == 'inventory_added') {
        if (locale == 'te') return 'ఇన్వెంటరీ జోడించబడింది';
        return 'Inventory Added';
      }
      if (key == 'inventory_used') {
        if (locale == 'te') return 'ఇన్వెంటరీ ఉపయోగించబడింది';
        return 'Inventory Used';
      }
      if (key == 'restock_item') {
        if (locale == 'te') return 'వస్తువును రీస్టాక్ చేయండి';
        return 'Restock Item';
      }
      if (key == 'consume_item') {
        if (locale == 'te') return 'వస్తువును వినియోగించండి';
        return 'Consume Item';
      }
      if (key == 'qty_to_add') {
        final unit = namedArgs?['unit'] ?? '';
        if (locale == 'te') return 'జోడించాల్సిన పరిమాణం ($unit)';
        return 'Quantity to add ($unit)';
      }
      if (key == 'qty_to_remove') {
        final unit = namedArgs?['unit'] ?? '';
        if (locale == 'te') return 'తొలగించాల్సిన పరిమాణం ($unit)';
        return 'Quantity to remove ($unit)';
      }
      if (key == 'save_transaction') {
        if (locale == 'te') return 'లావాదేవీని సేవ్ చేయండి';
        return 'Save Transaction';
      }
      if (key == 'no_history_found') {
        if (locale == 'te') return 'చరిత్ర ఏదీ కనుగొనబడలేదు';
        return 'No history found';
      }
      if (key == 'type_custom_rule_hint') {
        if (locale == 'te') return 'మీ నియమాన్ని ఇక్కడ నమోదు చేయండి...';
        return 'Type your custom rule here...';
      }
      if (key == 'save_rules_timings') {
        if (locale == 'te') return 'నియమాలు & సమయాలను సేవ్ చేయండి';
        return 'Save Rules & Timings';
      }
      if (key == 'add_photo_optional') {
        if (locale == 'te') return 'ఫోటోను జోడించండి (ఐచ్ఛికం)';
        return 'Add Photo (Optional)';
      }
      if (key == 'fixed_tag') {
        if (locale == 'te') return 'స్థిరమైనది';
        return 'FIXED';
      }
      if (key == 'every_month_ordinal') {
        final day = namedArgs?['day'] ?? '';
        final ord = namedArgs?['ordinal'] ?? '';
        if (locale == 'te') return 'ప్రతి నెల $dayవ తేదీ';
        return 'Every month $day$ord';
      }

      if (key == 'hostel_profile_title') {
        if (locale == 'te') return 'హాస్టల్ ప్రొఫైల్';
        return 'Hostel Profile';
      }
      if (key == 'basic_info') {
        if (locale == 'te') return 'ప్రాథమిక సమాచారం';
        return 'BASIC INFO';
      }
      if (key == 'hostel_name') {
        if (locale == 'te') return 'హాస్టల్ పేరు';
        return 'Hostel Name';
      }
      if (key == 'hostel_type') {
        if (locale == 'te') return 'హాస్టల్ రకం';
        return 'Hostel Type';
      }
      if (key == 'category') {
        if (locale == 'te') return 'వర్గం';
        return 'Category';
      }
      if (key == 'location_details') {
        if (locale == 'te') return 'స్థల వివరాలు';
        return 'LOCATION DETAILS';
      }
      if (key == 'state') {
        if (locale == 'te') return 'రాష్ట్రం';
        return 'State';
      }
      if (key == 'district') {
        if (locale == 'te') return 'జిల్లా';
        return 'District';
      }
      if (key == 'city_village') {
        if (locale == 'te') return 'నగరం / గ్రామం';
        return 'City / Village';
      }
      if (key == 'area_landmark') {
        if (locale == 'te') return 'ప్రాంతం / ల్యాండ్‌మార్క్';
        return 'Area / Landmark';
      }
      if (key == 'pincode') {
        if (locale == 'te') return 'పిన్‌కోడ్';
        return 'Pincode';
      }
      if (key == 'full_address_hint') {
        if (locale == 'te') return 'పూర్తి చిరునామా';
        return 'Full Address';
      }
      if (key == 'contact_description') {
        if (locale == 'te') return 'సంప్రదింపు వివరాలు & వివరణ';
        return 'CONTACT & DESCRIPTION';
      }
      if (key == 'contact_number') {
        if (locale == 'te') return 'సంప్రదింపు సంఖ్య';
        return 'Contact Number';
      }
      if (key == 'official_email') {
        if (locale == 'te') return 'అధికారిక ఇమెయిల్';
        return 'Official Email';
      }
      if (key == 'about_hostel') {
        if (locale == 'te') return 'హాస్టల్ గురించి';
        return 'About Hostel';
      }
      if (key == 'property_documents') {
        if (locale == 'te') return 'ప్రాపర్టీ పత్రాలు';
        return 'Property Documents';
      }
      if (key == 'manage_docs_sub') {
        if (locale == 'te') {
          return 'కేవైసీ మరియు ప్రాపర్టీ పత్రాలను నిర్వహించండి';
        }
        return 'Manage KYC & property documents';
      }
      if (key == 'save_property_profile') {
        if (locale == 'te') return 'ప్రాపర్టీ ప్రొఫైల్‌ను సేవ్ చేయండి';
        return 'SAVE PROPERTY PROFILE';
      }
      if (key == 'fetching') {
        if (locale == 'te') return 'సేకరిస్తోంది...';
        return 'Fetching...';
      }
      if (key == 'gps_fetch') {
        if (locale == 'te') return 'జీపీఎస్ నుండి పొందండి';
        return 'FETCH FROM GPS';
      }
      if (key == 'location_verified') {
        if (locale == 'te') return 'స్థలం ధృవీకరించబడింది';
        return 'Location Verified';
      }
      if (key == 'add_hostel_photos') {
        if (locale == 'te') return 'హాస్టల్ ఫోటోలను జోడించండి';
        return 'ADD HOSTEL PHOTOS';
      }
      if (key == 'no_images') {
        if (locale == 'te') return 'చిత్రాలు ఏవీ లేవు';
        return 'No images found';
      }

      if (key == 'amenities_title') {
        if (locale == 'te') return 'అమెనిటీస్ (సౌకర్యాలు)';
        return 'Amenities';
      }
      if (key == 'add_custom_amenity') {
        if (locale == 'te') return 'అనుకూల అమెనిటీని జోడించండి';
        return 'Add Custom Amenity';
      }
      if (key == 'custom_amenity_hint') {
        if (locale == 'te') return 'అమెనిటీ పేరు (ఉదా. గ్రీజర్)';
        return 'Amenity name (e.g. Geyser)';
      }
      if (key == 'cancel') {
        if (locale == 'te') return 'రద్దు చేయి';
        return 'Cancel';
      }
      if (key == 'btn_add') {
        if (locale == 'te') return 'జోడించు';
        return 'ADD';
      }
      if (key == 'save_changes') {
        if (locale == 'te') return 'మార్పులను సేవ్ చేయి';
        return 'SAVE CHANGES';
      }
      if (key == 'no_hostel_selected') {
        if (locale == 'te') return 'హాస్టల్ ఏదీ ఎంచుకోబడలేదు';
        return 'No hostel selected';
      }
      if (key == 'add_property_first') {
        if (locale == 'te') return 'ముందుగా ఒక ప్రాపర్టీని జోడించండి';
        if (locale == 'hi') return 'पहले संपत्ति जोड़ें';
        if (locale == 'ta') return 'முதலில் சொத்தைச் சேர்க்கவும்';
        if (locale == 'kn') return 'ಮೊದಲು ಆಸ್ತಿಯನ್ನು ಸೇರಿಸಿ';
        if (locale == 'ml') return 'ആദ്യം പ്രോപ്പർട്ടി ചേർക്കുക';
        return 'Add property first';
      }
      if (key == 'start_by_adding_property_desc') {
        if (locale == 'te') {
          return 'ఈ విభాగాన్ని నిర్వహించడానికి దయచేసి ముందుగా ఒక ప్రాపర్టీని జోడించండి.';
        }
        if (locale == 'hi') {
          return 'कृपया इस अनुभाग को प्रबंधित करने के लिए पहले एक संपत्ति जोड़ें।';
        }
        if (locale == 'ta') {
          return 'இந்த பகுதியை நிர்வகிக்க முதலில் ஒரு சொத்தைச் சேர்க்கவும்.';
        }
        if (locale == 'kn') {
          return 'ಈ ವಿಭಾಗವನ್ನು ನಿರ್ವಹಿಸಲು ದಯವಿಟ್ಟು ಮೊದಲು ಆಸ್ತಿಯನ್ನು ಸೇರಿಸಿ.';
        }
        if (locale == 'ml') {
          return 'ഈ വിഭാഗം നിയന്ത്രിക്കുന്നതിന് ദയവായി ആദ്യം ഒരു പ്രോപ്പർട്ടി ചേർക്കുക.';
        }
        return 'Please add a property first to manage this section.';
      }
      if (key == 'confirm_broadcast_title') return 'Confirm Broadcast';
      if (key == 'confirm_broadcast_desc') {
        return 'Are you sure you want to send this announcement to all residents?';
      }
      if (key == 'no_property_data_available') {
        return 'No property data available. Please add a property first.';
      }
      if (key == 'search_staff_hint') {
        return 'Search staff name, role, phone...';
      }
      if (key == 'add_staff_button') return 'Add Staff';
    }
    return translated;
  }

  static String formatSharingType(
    String type, [
    BuildContext? context,
    int? capacity,
  ]) {
    switch (type.toUpperCase()) {
      case 'SINGLE':
        return translate(
          'sharing_type',
          namedArgs: {'count': '1'},
          context: context,
        );
      case 'DOUBLE':
        return translate(
          'sharing_type',
          namedArgs: {'count': '2'},
          context: context,
        );
      case 'TRIPLE':
        return translate(
          'sharing_type',
          namedArgs: {'count': '3'},
          context: context,
        );
      case 'QUADRUPLE':
        return translate(
          'sharing_type',
          namedArgs: {'count': '4'},
          context: context,
        );
      case 'QUINTUPLE':
        return translate(
          'sharing_type',
          namedArgs: {'count': '5'},
          context: context,
        );
      case 'DORMITORY':
        if (capacity != null && capacity > 0) {
          return translate(
            'sharing_count',
            namedArgs: {'count': capacity.toString()},
            context: context,
          );
        }
        return translate('dormitory_short', context: context);
      default:
        final digits = RegExp(r'\d+').firstMatch(type)?.group(0);
        if (digits != null) {
          return translate(
            'sharing_count',
            namedArgs: {'count': digits},
            context: context,
          );
        }
        return type;
    }
  }

  static String mapCapacityToSharing(int capacity) {
    switch (capacity) {
      case 1:
        return 'SINGLE';
      case 2:
        return 'DOUBLE';
      case 3:
        return 'TRIPLE';
      case 4:
        return 'QUADRUPLE';
      case 5:
        return 'QUINTUPLE';
      default:
        return 'DORMITORY';
    }
  }
}
