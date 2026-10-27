import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../utils/logger.dart';

/// Listens for verified share links (Android App Links / iOS Universal Links)
/// on [ApiConstants.shareLinkHost] and keeps the referral code from
/// `https://<host>/r/<referralId>` until sign-up consumes it.
class DeepLinkService {
  static const _pendingReferralKey = 'pending_referral_code';

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  DeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  Future<void> init() async {
    if (_subscription != null) return;
    _subscription = _appLinks.uriLinkStream.listen(
      _handleLink,
      onError: (Object e) => AppLogger.warning('Deep link stream error: $e'),
    );
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) await _handleLink(initial);
    } catch (e) {
      AppLogger.warning('Reading initial deep link failed: $e');
    }
  }

  Future<void> _handleLink(Uri uri) async {
    if (uri.host != ApiConstants.shareLinkHost) return;
    AppLogger.info('Opened via share link: $uri');

    final code = referralCodeFrom(uri);
    if (code != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingReferralKey, code);
    }
  }

  /// `/r/<code>`, or a legacy `?ref=<code>` query.
  static String? referralCodeFrom(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments.first == 'r') {
      return segments[1].isNotEmpty ? segments[1] : null;
    }
    final ref = uri.queryParameters['ref'];
    return (ref != null && ref.isNotEmpty) ? ref : null;
  }

  /// Referral code from the last opened link that hasn't been used yet.
  Future<String?> getPendingReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingReferralKey);
  }

  Future<void> clearPendingReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingReferralKey);
  }
}
