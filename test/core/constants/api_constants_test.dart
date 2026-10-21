import 'package:flutter_test/flutter_test.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

void main() {
  test('builds S3 image URLs for the configured environment', () {
    final isProduction = ApiConstants.environment == 'PROD';
    final expectedBucket = isProduction
        ? 'https://stayindia-production.s3.ap-south-2.amazonaws.com'
        : 'https://stayindia.s3.ap-south-2.amazonaws.com';
    final expectedApiUrl = isProduction
        ? 'https://aws-api.stayindia.in/api/v1'
        : 'https://api.stayindia.in/api/v1';

    expect(ApiConstants.effectiveBaseUrl, expectedApiUrl);
    expect(
      ApiConstants.getImageUrl('stay-india/documents/avatar.jpg'),
      '$expectedBucket/stay-india/documents/avatar.jpg',
    );
    expect(
      ApiConstants.TERMS_AND_CONDITIONS,
      'https://www.stayindia.in/privacy.html',
    );
    expect(ApiConstants.ABOUT_US, 'https://www.stayindia.in/aboutus.html');
  });
}
