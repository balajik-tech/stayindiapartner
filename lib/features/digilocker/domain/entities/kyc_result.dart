/// App-level KYC result, decoupled from the plugin's response shape so the
/// rest of the app (state management, storage, UI) doesn't depend directly
/// on a third-party package's types.
class KycResult {
  final String? name;
  final String? aadharNumber;
  final String? aadharAddress;
  final String? dob;
  final String? gender;
  final String? panNumber;
  final String? nameOnPan;
  final DateTime capturedAt;

  const KycResult({
    this.name,
    this.aadharNumber,
    this.aadharAddress,
    this.dob,
    this.gender,
    this.panNumber,
    this.nameOnPan,
    required this.capturedAt,
  });

  /// Masks all but the last 4 digits — never display/store full Aadhaar
  /// numbers in logs or UI unless your compliance requirements say otherwise.
  static String? maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.length < 4) return aadhaar;
    final last4 = aadhaar.substring(aadhaar.length - 4);
    return 'XXXX-XXXX-$last4';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'aadharNumber': aadharNumber,
        'aadharAddress': aadharAddress,
        'dob': dob,
        'gender': gender,
        'panNumber': panNumber,
        'nameOnPan': nameOnPan,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory KycResult.fromJson(Map<String, dynamic> json) {
    return KycResult(
      name: json['name'],
      aadharNumber: json['aadharNumber'],
      aadharAddress: json['aadharAddress'],
      dob: json['dob'],
      gender: json['gender'],
      panNumber: json['panNumber'],
      nameOnPan: json['nameOnPan'],
      capturedAt: DateTime.parse(json['capturedAt']),
    );
  }
}
