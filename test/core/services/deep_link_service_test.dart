import 'package:flutter_test/flutter_test.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkService.referralCodeFrom', () {
    test('reads the code from /r/<code>', () {
      final uri = Uri.parse('https://share.stayindia.in/r/ABC123');
      expect(DeepLinkService.referralCodeFrom(uri), 'ABC123');
    });

    test('reads a legacy ?ref= query', () {
      final uri = Uri.parse('https://share.stayindia.in/partner?ref=XYZ');
      expect(DeepLinkService.referralCodeFrom(uri), 'XYZ');
    });

    test('returns null when there is no code', () {
      expect(
        DeepLinkService.referralCodeFrom(
          Uri.parse('https://share.stayindia.in/r/'),
        ),
        isNull,
      );
      expect(
        DeepLinkService.referralCodeFrom(
          Uri.parse('https://share.stayindia.in/'),
        ),
        isNull,
      );
    });
  });

  test('referral links round-trip through the parser', () {
    final link = ApiConstants.referralLink('ABC 123');
    expect(Uri.parse(link).host, ApiConstants.shareLinkHost);
    expect(DeepLinkService.referralCodeFrom(Uri.parse(link)), 'ABC 123');
  });
}
