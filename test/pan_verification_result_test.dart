import 'package:flutter_test/flutter_test.dart';
import 'package:stayindia_owner/features/bank_account/domain/entities/pan_verification_result.dart';

void main() {
  test('PanVerificationResult maps latest Digiverification payload', () {
    final result = PanVerificationResult.fromJson({
      'client_id': 'pan_comprehensive_tKJRscXthzyxpmyauiup',
      'pan_number': 'ECZPK1568J',
      'full_name': 'BALAJI KOLUKULURI',
      'full_name_split': ['BALAJI', '', 'KOLUKULURI'],
      'masked_aadhaar': '60XXXXXXXX94',
      'address': {
        'line_1': '',
        'line_2': '',
        'street_name': '',
        'zip': '',
        'city': '',
        'state': '',
        'country': '',
        'full': '',
      },
      'email': null,
      'phone_number': null,
      'gender': 'M',
      'dob': '1991-12-27',
      'input_dob': null,
      'aadhaar_linked': true,
      'dob_verified': false,
      'dob_check': false,
      'category': 'person',
      'status': 'valid',
      'less_info': false,
    });

    expect(result.pan, 'ECZPK1568J');
    expect(result.fullname, 'BALAJI KOLUKULURI');
    expect(result.firstName, 'BALAJI');
    expect(result.lastName, 'KOLUKULURI');
    expect(result.gender, 'M');
    expect(result.dob, '1991-12-27');
    expect(result.aadhaarLinked, isTrue);
    expect(result.panStatus, 'valid');
    expect(result.mobile, isEmpty);
    expect(result.email, isEmpty);
    expect(result.address.city, isEmpty);
  });
}
