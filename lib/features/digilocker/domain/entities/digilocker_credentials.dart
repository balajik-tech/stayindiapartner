/// Central place for your DigiLocker (meon.co.in) API credentials.
///
/// IMPORTANT: Never hardcode [secretToken] in source control for a real app.
/// Load it from --dart-define, a secure backend, or a secrets manager instead.
class DigiLockerCredentials {
  final String companyName;
  final String secretToken;
  final String redirectUrl;

  const DigiLockerCredentials({
    required this.companyName,
    required this.secretToken,
    required this.redirectUrl,
  });

  /// Example factory reading from compile-time environment variables:
  /// flutter run --dart-define=DIGILOCKER_COMPANY=xxx --dart-define=DIGILOCKER_TOKEN=yyy
  factory DigiLockerCredentials.fromEnv() {
    const company = String.fromEnvironment('DIGILOCKER_COMPANY');
    const token = String.fromEnvironment('DIGILOCKER_TOKEN');
    const redirect = String.fromEnvironment(
      'DIGILOCKER_REDIRECT',
      defaultValue: 'https://your-redirect-url.com',
    );
    return const DigiLockerCredentials(
      companyName: company,
      secretToken: token,
      redirectUrl: redirect,
    );
  }
}
