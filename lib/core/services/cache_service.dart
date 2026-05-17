import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:hive/hive.dart';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/core/utils/logger.dart';

class CacheService {
  final TokenStorage _tokenStorage;
  static const String _lastVersionKey = 'last_app_version';

  CacheService(this._tokenStorage);

  Future<void> checkAndFlushOnUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
      final lastVersion = prefs.getString(_lastVersionKey);

      if (lastVersion != null && lastVersion != currentVersion) {
        AppLogger.warning('App updated from $lastVersion to $currentVersion. Flushing all local data...');
        await flushAllCache();
      }

      await prefs.setString(_lastVersionKey, currentVersion);
    } catch (e) {
      AppLogger.error('Error during update check: $e');
    }
  }

  Future<void> flushAllCache() async {
    AppLogger.info('Wiping all local application data...');
    
    try {
      // 1. Clear SharedPreferences while preserving locale and app version
      final prefs = await SharedPreferences.getInstance();
      final String? locale = prefs.getString('locale');
      final String? appVersion = prefs.getString(_lastVersionKey);

      await prefs.clear();
      AppLogger.debug('SharedPreferences cleared.');

      if (locale != null) {
        await prefs.setString('locale', locale);
      }
      if (appVersion != null) {
        await prefs.setString(_lastVersionKey, appVersion);
      }
      
      // 2. Clear TokenStorage (Secure Storage)
      await _tokenStorage.clearAll();
      AppLogger.debug('Secure storage cleared.');
      
      // 3. Clear HydratedBloc Storage completely
      try {
        await HydratedBloc.storage.clear();
        AppLogger.debug('HydratedBloc storage fully cleared.');
      } catch (e) {
        AppLogger.error('Failed to clear HydratedBloc storage: $e');
      }

      // 4. Clear Hive completely
      try {
        await Hive.deleteFromDisk();
        AppLogger.debug('Hive storage deleted from disk.');
      } catch (e) {
        AppLogger.error('Failed to delete Hive from disk: $e');
      }
      
      AppLogger.success('All local data flushed successfully.');
    } catch (e) {
      AppLogger.error('Critical failure during data flush: $e');
    }
  }
}
