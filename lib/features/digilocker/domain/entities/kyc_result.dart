/// App-level KYC result, decoupled from the plugin's response shape so the
/// rest of the app (state management, storage, UI) doesn't depend directly
/// on a third-party package's types.
class KycResult {
  final bool? isAadharVerified;
  final String? name;
  final String? fatherName;
  final String? aadharNumber;
  final String? maskedAadhaar;
  final String? aadharAddress;
  final String? dob;
  final String? gender;
  // final String? panNumber;
  // final String? nameOnPan;
  final String? dateTime;
  final String? aadharFilename;
  final String? aadharImgFilename;
  final String? adharImg;
  // final String? aadharXml;
  final DateTime capturedAt;

  const KycResult({
    this.isAadharVerified,
    this.name,
    this.fatherName,
    this.aadharNumber,
    this.maskedAadhaar,
    this.aadharAddress,
    this.dob,
    this.gender,
    // this.panNumber,
    // this.nameOnPan,
    this.dateTime,
    this.aadharFilename,
    this.aadharImgFilename,
    this.adharImg,
    // this.aadharXml,
    required this.capturedAt,
  });

  /// Masks all but the last 4 digits of Aadhaar.
  static String? maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.length < 4) return aadhaar;
    final last4 = aadhaar.substring(aadhaar.length - 4);
    return 'XXXX-XXXX-$last4';
  }

  Map<String, dynamic> toJson() => {
    'is_aadhar_verified': isAadharVerified,
    'name': name,
    'fathername': fatherName,
    'aadharNumber': aadharNumber,
    'masked_aadhaar': maskedAadhaar,
    'aadharAddress': aadharAddress,
    'dob': dob,
    'gender': gender,
    // 'panNumber': panNumber,
    // 'nameOnPan': nameOnPan,
    'date_time': dateTime,
    'aadhar_filename': aadharFilename,
    'aadhar_img_filename': aadharImgFilename,
    'adharimg': adharImg,
    // 'aadhar_xml': aadharXml,
    'capturedAt': capturedAt.toIso8601String(),
  };

  factory KycResult.fromJson(Map<String, dynamic> json) {
    return KycResult(
      isAadharVerified: json['is_aadhar_verified'],
      name: json['name'],
      fatherName: json['fathername'],
      aadharNumber: json['aadharNumber'] ?? json['aadhar_no'],
      maskedAadhaar: json['masked_aadhaar'],
      aadharAddress: json['aadharAddress'] ?? json['aadhar_address'],
      dob: json['dob'],
      gender: json['gender'],
      // panNumber: json['panNumber'],
      // nameOnPan: json['nameOnPan'],
      dateTime: json['date_time'],
      aadharFilename: json['aadhar_filename'],
      aadharImgFilename: json['aadhar_img_filename'],
      adharImg: json['adharimg'],
      // aadharXml: json['aadhar_xml'],
      capturedAt: json['capturedAt'] != null
          ? DateTime.parse(json['capturedAt'])
          : DateTime.now(),
    );
  }
}
