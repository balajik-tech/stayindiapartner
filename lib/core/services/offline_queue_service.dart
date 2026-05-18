import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

class OfflineAction {
  final String id;
  final String type; 
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int retryCount;
  final DateTime? lastAttempt;

  OfflineAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
    this.lastAttempt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
        'lastAttempt': lastAttempt?.toIso8601String(),
      };

  factory OfflineAction.fromJson(Map<String, dynamic> json) => OfflineAction(
        id: json['id'],
        type: json['type'],
        payload: Map<String, dynamic>.from(json['payload']),
        timestamp: DateTime.parse(json['timestamp']),
        retryCount: json['retryCount'] ?? 0,
        lastAttempt: json['lastAttempt'] != null ? DateTime.parse(json['lastAttempt']) : null,
      );
}

class OfflineQueueService {
  static const String _boxName = 'offline_mutation_queue_box';
  bool _isSyncing = false;

  OfflineQueueService();

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  Future<void> enqueueAction(String type, Map<String, dynamic> payload) async {
    final box = await _getBox();
    
    final newAction = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      payload: payload,
      timestamp: DateTime.now().toUtc(),
    );

    await box.put(newAction.id, newAction.toJson());
    AppLogger.info('[OFFLINE QUEUE] Queued action: $type for path: ${payload['path']}');
  }

  Future<List<OfflineAction>> getPendingActions() async {
    final box = await _getBox();
    final List<OfflineAction> actions = [];
    
    for (var key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        try {
          actions.add(OfflineAction.fromJson(Map<String, dynamic>.from(value)));
        } catch (e) {
          AppLogger.error('Failed to parse offline action', e);
        }
      }
    }
    
    actions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return actions;
  }

  Future<void> removeAction(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> updateAction(OfflineAction action) async {
    final box = await _getBox();
    await box.put(action.id, action.toJson());
  }

  Future<void> clearQueue() async {
    final box = await _getBox();
    await box.clear();
    AppLogger.info('[OFFLINE QUEUE] Cleared.');
  }

  void startSyncListener(Dio dio) {
    AppLogger.info('[OFFLINE QUEUE] Listening for connectivity changes to sync queue...');
    Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        AppLogger.info('[OFFLINE QUEUE] Internet connection restored, starting sync...');
        syncOfflineQueue(dio);
      }
    });
  }

  Future<void> syncOfflineQueue(Dio dio) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final actions = await getPendingActions();
      if (actions.isEmpty) {
        _isSyncing = false;
        return;
      }

      AppLogger.info('[OFFLINE QUEUE] Replaying ${actions.length} pending actions...');

      for (var action in actions) {
        
        if (action.lastAttempt != null) {
          final timeSinceLastAttempt = DateTime.now().toUtc().difference(action.lastAttempt!);
          final requiredDelay = Duration(seconds: 5 * action.retryCount);
          if (timeSinceLastAttempt < requiredDelay) {
            AppLogger.info('[OFFLINE QUEUE] Skipping action ${action.id} due to retry throttle (retry count: ${action.retryCount})');
            continue;
          }
        }

        
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          AppLogger.warning('[OFFLINE QUEUE] Internet lost during sync. Stopping sync.');
          break;
        }

        bool success = false;
        try {
          final payload = action.payload;
          
          AppLogger.info('[OFFLINE QUEUE] Replaying action ${action.id}: ${payload['method']} ${payload['path']}');
          
          final response = await dio.request(
            payload['path'],
            data: payload['data'],
            queryParameters: payload['queryParameters'] != null 
                ? Map<String, dynamic>.from(payload['queryParameters']) 
                : null,
            options: Options(
              method: payload['method'],
              headers: payload['headers'] != null 
                  ? Map<String, dynamic>.from(payload['headers']) 
                  : null,
            ),
          );

          if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
            success = true;
            AppLogger.info('[OFFLINE QUEUE] Replay succeeded for action ${action.id}');
          }
        } on DioException catch (de) {
          final statusCode = de.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 400 && statusCode < 500) {
              
              
              success = true;
              AppLogger.warning('[OFFLINE QUEUE] Replay failed with status $statusCode. Removing invalid request from queue.');
            } else {
              
              AppLogger.error('[OFFLINE QUEUE] Replay failed with server error $statusCode. Keeping in queue for retry.');
            }
          } else {
            
            AppLogger.error('[OFFLINE QUEUE] Replay failed with network error. Keeping in queue for retry.');
          }
        } catch (e) {
          AppLogger.error('[OFFLINE QUEUE] Replay failed with unexpected error: $e. Keeping in queue.');
        }

        if (success) {
          await removeAction(action.id);
        } else {
          
          final updatedAction = OfflineAction(
            id: action.id,
            type: action.type,
            payload: action.payload,
            timestamp: action.timestamp,
            retryCount: action.retryCount + 1,
            lastAttempt: DateTime.now().toUtc(),
          );
          await updateAction(updatedAction);
        }
      }
    } catch (e) {
      AppLogger.error('[OFFLINE QUEUE] Sync failed with error: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
