# DigiLocker Feature

A clean architecture implementation for DigiLocker Aadhaar and PAN verification using the `flutter_digilocker_aadhar_pan` package.

## Feature Structure

```
lib/features/digilocker/
├── domain/
│   ├── entities/
│   │   ├── digilocker_credentials.dart
│   │   └── kyc_result.dart
│   ├── repositories/
│   │   └── digilocker_repository.dart
│   └── usecases/
│       └── verify_documents.dart
├── data/
│   └── repositories/
│       └── digilocker_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── digilocker_verification_screen.dart
    │   └── kyc_result_screen.dart
    ├── widgets/
    │   └── kyc_result_card.dart
    └── utils/
        └── digilocker_navigator.dart
```

## Usage

### Basic Usage with Reusable Navigation

The easiest way to use DigiLocker verification is through the `DigiLockerNavigator` helper:

```dart
import 'package:flutter/material.dart';
import 'package:stayindia/features/digilocker/domain/entities/digilocker_credentials.dart';
import 'package:stayindia/features/digilocker/presentation/utils/digilocker_navigator.dart';

// In your widget
ElevatedButton(
  onPressed: () async {
    final credentials = DigiLockerCredentials(
      companyName: 'your_company_name',
      secretToken: 'your_secret_token',
      redirectUrl: 'https://your-redirect-url.com/digilocker/thank-you-page',
    );

    await DigiLockerNavigator.verifyWithDigiLocker(
      context,
      credentials: credentials,
      documents: 'aadhaar', // or 'aadhaar,pan'
      onResult: (result) {
        if (result != null) {
          // Handle successful verification
          print('Name: ${result.name}');
          print('Aadhaar: ${result.aadharNumber}');
          // Save to backend, update UI, etc.
        }
      },
    );
  },
  child: const Text('Verify with DigiLocker'),
)
```

### Convenience Methods

For common use cases, use the convenience methods:

```dart
// Verify Aadhaar only
await DigiLockerNavigator.verifyAadhaar(
  context,
  credentials: credentials,
  onResult: (result) {
    // Handle result
  },
);

// Verify both Aadhaar and PAN
await DigiLockerNavigator.verifyAadhaarAndPan(
  context,
  credentials: credentials,
  panName: 'John Doe', // Optional pre-fill
  panNo: 'ABCDE1234F', // Optional pre-fill
  onResult: (result) {
    // Handle result
  },
);
```

### Custom Navigation

If you need more control, you can navigate directly:

```dart
import 'package:stayindia/features/digilocker/presentation/pages/digilocker_verification_screen.dart';
import 'package:stayindia/features/digilocker/presentation/pages/kyc_result_screen.dart';

final result = await Navigator.push<KycResult>(
  context,
  MaterialPageRoute(
    builder: (_) => DigiLockerVerificationScreen(
      credentials: credentials,
      documents: 'aadhaar,pan',
    ),
  ),
);

if (result != null) {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => KycResultScreen(result: result)),
  );
}
```

### Without Result Screen

If you want to handle the result yourself without showing the built-in result screen:

```dart
await DigiLockerNavigator.verifyWithDigiLocker(
  context,
  credentials: credentials,
  documents: 'aadhaar',
  showResultScreen: false,
  onResult: (result) {
    if (result != null) {
      // Custom handling - save to backend, show custom UI, etc.
      _saveKycResult(result);
    }
  },
);
```

## Security Note

**Important**: Never hardcode your `secretToken` in source code. Use environment variables or a secure backend:

```dart
// Using environment variables (recommended for development)
final credentials = DigiLockerCredentials.fromEnv();

// Run with: flutter run --dart-define=DIGILOCKER_COMPANY=xxx --dart-define=DIGILOCKER_TOKEN=yyy

// Or load from your backend API in production
final credentials = await _fetchCredentialsFromBackend();
```

## Entities

### DigiLockerCredentials
- `companyName`: Your DigiLocker company name
- `secretToken`: Your DigiLocker secret token
- `redirectUrl`: URL to redirect after verification

### KycResult
- `name`: User's name
- `aadharNumber`: Masked Aadhaar number
- `aadharAddress`: User's address
- `dob`: Date of birth
- `gender`: Gender
- `panNumber`: PAN number (if verified)
- `nameOnPan`: Name on PAN card (if verified)
- `capturedAt`: Timestamp of verification

## Dependency Injection

The feature is automatically registered in `lib/core/di/injection_container.dart` via `DigiLockerDI.init(sl)`.

Available dependencies:
- `DigiLockerRepository`: For backend validation/processing
- `VerifyDocuments`: Use case for document verification
