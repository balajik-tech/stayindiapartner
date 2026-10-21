import 'package:flutter_test/flutter_test.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

void main() {
  test('builds S3 image URLs for the configured environment', () {
    final expectedBucket = ApiConstants.environment == 'PROD'
        ? 'stayindia-production'
        : 'stayindia';

    expect(
      ApiConstants.getImageUrl('stay-india/documents/avatar.jpg'),
      'https://$expectedBucket.s3.ap-south-2.amazonaws.com/'
      'stay-india/documents/avatar.jpg',
    );
  });
}
