import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/kyc_result.dart';

class DigiLockerStorage {
  static const String _key = 'digi_locker_details';

  /// Save DigiLocker details
  static Future<void> saveDigiLockerDetails(KycResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(result.toJson()),
    );
  }

  /// Get DigiLocker details
  static Future<KycResult?> getDigiLockerDetails() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final Map<String, dynamic> json =
    jsonDecode(jsonString) as Map<String, dynamic>;

    return KycResult.fromJson(json);
  }

  /// Get Aadhaar address
  static Future<String?> getAddress() async {
    final result = await getDigiLockerDetails();
    return result?.aadharAddress;
  }

  /// Clear DigiLocker details
  static Future<void> clearDigiLockerDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}