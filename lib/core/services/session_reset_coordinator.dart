import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:stayindia_owner/injection_container.dart' as di;
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import 'package:stayindia_owner/core/services/offline_queue_service.dart';
import 'package:stayindia_owner/core/services/cache_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:hive/hive.dart';

class SessionResetCoordinator {
  static Future<void> resetSession() async {
    AppLogger.warning('🚨 Starting Atomic Owner Session Reset Lifecycle...');

    try {
      
      try {
        if (di.sl.isRegistered<SocketService>()) {
          AppLogger.info('Disconnecting and clearing Socket.io instances...');
          di.sl<SocketService>().disconnect();
        }
      } catch (e) {
        AppLogger.error('Failed to disconnect socket: $e');
      }

      
      try {
        AppLogger.info('Deleting FCM token registry on device...');
        await FirebaseMessaging.instance.deleteToken();
        NotificationService().reset();
      } catch (e) {
        AppLogger.error('Failed to reset FCM token registry: $e');
      }

      
      try {
        if (di.sl.isRegistered<OfflineQueueService>()) {
          AppLogger.info('Wiping pending offline mutation queues...');
          await di.sl<OfflineQueueService>().clearQueue();
        }
      } catch (e) {
        AppLogger.error('Failed to clear Hive offline queue: $e');
      }

      
      try {
        if (di.sl.isRegistered<CacheService>()) {
          AppLogger.info('Invoking CacheService selective cache flush...');
          await di.sl<CacheService>().flushAllCache();
        }
      } catch (e) {
        AppLogger.error('Failed to flush CacheService: $e');
      }

      
      try {
        AppLogger.info('Evicting in-memory Image Caches...');
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      } catch (e) {
        AppLogger.error('Failed to clear image cache: $e');
      }

      
      AppLogger.info('Recalibrating dependency injection container (GetIt)...');
      await di.resetInjections();

      AppLogger.success('🚀 Atomic Owner Session Reset Complete.');
    } catch (e, stack) {
      AppLogger.error('Critical crash during session reset execution', e, stack);
    }
  }

  static void postResetCleanup() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          AppLogger.warning('🧹 Post-Logout Cache Cleanup: Wiping HydratedBloc and Hive storage...');
          await HydratedBloc.storage.clear();
          await Hive.deleteFromDisk();
          AppLogger.success('🧹 Post-Logout Cache Cleanup complete!');
        } catch (e) {
          AppLogger.error('Failed to perform post-logout cleanup: $e');
        }
      });
    } catch (_) {
      
      try {
        AppLogger.warning('🧹 Post-Logout Cache Cleanup (Immediate): Wiping HydratedBloc and Hive storage...');
        HydratedBloc.storage.clear();
        Hive.deleteFromDisk();
      } catch (e) {
        AppLogger.error('Failed to perform immediate post-logout cleanup: $e');
      }
    }
  }
}
