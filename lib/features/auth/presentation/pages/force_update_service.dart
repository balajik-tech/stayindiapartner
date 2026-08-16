import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/force_update_model.dart';


class ForceUpdateService {
  ForceUpdateService._();

  static final ForceUpdateService instance =
  ForceUpdateService._();

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Get actual installed app version
      final packageInfo = await PackageInfo.fromPlatform();

      final String currentVersion = packageInfo.version;

      debugPrint(
        'Current App Version: $currentVersion',
      );

      // STATIC RESPONSE FOR TESTING
      final Map<String, dynamic> staticResponse = {
        'success': true,
        'data': {
          'android': {
            'minimumVersion': '2.5.0',
            'latestVersion': '2.6.0',
            'forceUpdate': true,
            'updateUrl':
            'https://play.google.com/store/apps/details?id=com.example.myapp',
          },
          'ios': {
            'minimumVersion': '2.5.0',
            'latestVersion': '2.6.0',
            'forceUpdate': true,
            'updateUrl':
            'https://apps.apple.com/app/id123456789',
          },
        },
      };

      // Convert JSON → Model
      final ForceUpdateResponse response =
      ForceUpdateResponse.fromJson(
        staticResponse,
      );

      // if (!response.success) {
      //   return;
      // }

      // Select platform
      final PlatformUpdate platformUpdate =
      Platform.isAndroid
          ? response.data.android
          : response.data.ios;

      debugPrint(
        'Minimum Version: ${platformUpdate.minimumVersion}',
      );

      debugPrint(
        'Latest Version: ${platformUpdate.latestVersion}',
      );

      debugPrint(
        'Force Update: ${platformUpdate.forceUpdate}',
      );

      // Check version
      final bool updateRequired =
      _isUpdateRequired(
        currentVersion,
        platformUpdate.minimumVersion,
      );

      if (!updateRequired) {
        debugPrint('No update required');
        return;
      }

      if (!platformUpdate.forceUpdate) {
        debugPrint(
          'Update available but forceUpdate is false',
        );
        return;
      }

      if (!context.mounted) {
        return;
      }

      _showForceUpdateDialog(
        context,
        platformUpdate.updateUrl,
      );
    } catch (e) {
      debugPrint(
        'Force update check failed: $e',
      );
    }
  }

  bool _isUpdateRequired(
      String currentVersion,
      String minimumVersion,
      ) {
    final current = _parseVersion(currentVersion);
    final minimum = _parseVersion(minimumVersion);

    for (int i = 0; i < 3; i++) {
      if (current[i] < minimum[i]) {
        return true;
      }

      if (current[i] > minimum[i]) {
        return false;
      }
    }

    return false;
  }

  List<int> _parseVersion(String version) {
    final parts = version.split('.');

    return [
      int.tryParse(
        parts.isNotEmpty ? parts[0] : '0',
      ) ??
          0,
      int.tryParse(
        parts.length > 1 ? parts[1] : '0',
      ) ??
          0,
      int.tryParse(
        parts.length > 2 ? parts[2] : '0',
      ) ??
          0,
    ];
  }

  void _showForceUpdateDialog(
      BuildContext context,
      String storeUrl,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'Update Required',
            ),
            content: const Text(
              'A new version of the app is available. '
                  'Please update the app to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await _openStore(storeUrl);
                },
                child: const Text(
                  'Update Now',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openStore(String storeUrl) async {
    if (storeUrl.isEmpty) {
      return;
    }

    final Uri uri = Uri.parse(storeUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}