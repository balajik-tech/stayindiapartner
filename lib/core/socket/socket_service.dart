import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/injection_container.dart';
import '../utils/logger.dart';

class SocketService {
  final String baseUrl;
  io.Socket? _socket;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageEditedController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeletedController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<String>.broadcast();
  final _stopTypingController = StreamController<String>.broadcast();
  final _bookingController = StreamController<Map<String, dynamic>>.broadcast();
  final _noticeController = StreamController<Map<String, dynamic>>.broadcast();
  final _dashboardRefreshController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get messageEditedStream => _messageEditedController.stream;
  Stream<Map<String, dynamic>> get messageDeletedStream => _messageDeletedController.stream;
  Stream<String> get typingStream => _typingController.stream;
  Stream<String> get stopTypingStream => _stopTypingController.stream;
  Stream<Map<String, dynamic>> get bookingStream => _bookingController.stream;
  Stream<Map<String, dynamic>> get noticeStream => _noticeController.stream;
  Stream<Map<String, dynamic>> get dashboardRefreshStream =>
      _dashboardRefreshController.stream;

  String? _lastRoomId;
  String? _lastUserId;
  String? _lastRole;
  String? _currentToken;

  SocketService({required this.baseUrl});

  Future<void> connect() async {
    final token = await sl<TokenStorage>().getToken();

    if (_socket != null) {
      if (_currentToken == token && _socket!.connected) {
        AppLogger.debug(
          ' Socket: Already connected with active token. Skipping.',
        );
        return;
      }
      AppLogger.debug(
        ' Socket: Token changed or socket disconnected. Re-initializing socket.',
      );
      _socket!.disconnect();
      _socket = null;
    }

    _currentToken = token;
    AppLogger.debug(
      ' Socket: Attempting to connect to $baseUrl with token: ${token != null}',
    );

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .disableMultiplex()
          .setAuth({'token': token, 'appType': 'OWNER_APP'})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(20)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      AppLogger.info(' Socket: Connected to server');
      if (_lastRoomId != null && _lastUserId != null) {
        AppLogger.info(' Socket: Auto-rejoining room $_lastRoomId');
        joinCommunity(_lastRoomId!, _lastUserId!, role: _lastRole ?? 'OWNER');
      }
    });

    _socket!.onConnectError((err) {
      AppLogger.error(' Socket: Connection error: $err');
    });

    _socket!.onConnectTimeout((err) {
      AppLogger.error(' Socket: Connection timeout: $err');
    });

    _socket!.onError((err) {
      AppLogger.error(' Socket: Error: $err');
    });

    _socket!.on('joined_community', (data) {
      AppLogger.success(
        ' Socket: Successfully joined room ${data['hostelId']}',
      );
    });

    _socket!.on('error', (data) {
      AppLogger.error(' Socket: Server returned error: $data');
    });

    _socket!.on('new_message', (data) {
      AppLogger.debug(' Socket: New message received');
      _messageController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('message_edited', (data) {
      AppLogger.debug(' Socket: Message edited');
      _messageEditedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('message_deleted', (data) {
      AppLogger.debug(' Socket: Message deleted');
      _messageDeletedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('new_booking', (data) {
      AppLogger.info(' Received new_booking notification: $data');
      _bookingController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('new_notice', (data) {
      AppLogger.info(' Received new_notice notification: $data');
      _noticeController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('dashboard_refresh', (data) {
      AppLogger.info(' Received dashboard_refresh request: $data');
      _dashboardRefreshController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('user_typing', (data) {
      if (data['userName'] != null) {
        AppLogger.debug(' Socket: User typing: ${data['userName']}');
        _typingController.add(data['userName']);
      }
    });

    _socket!.on('user_stopped_typing', (data) {
      if (data['userName'] != null) {
        _stopTypingController.add(data['userName']);
      }
    });

    _socket!.onDisconnect(
      (_) => AppLogger.warning(' Socket: Disconnected from server'),
    );
  }

  void joinCommunity(String hostelId, String userId, {String role = 'OWNER'}) {
    if (hostelId.isEmpty) {
      AppLogger.warning(
        ' Socket: Attempted to join room with empty hostelId. Ignoring.',
      );
      return;
    }

    if (_lastRoomId != null && _lastRoomId != hostelId) {
      AppLogger.info(
        ' Socket: Leaving previous room $_lastRoomId before joining $hostelId',
      );
      leaveCommunity(_lastRoomId!);
    }

    _lastRoomId = hostelId;
    _lastUserId = userId;
    _lastRole = role;

    AppLogger.debug(
      ' Socket: Emitting join_community | Room: $hostelId, User: $userId, Role: $role',
    );
    _socket?.emit('join_community', {
      'hostelId': hostelId,
      'userId': userId,
      'role': role,
    });
  }

  void leaveCommunity(String hostelId) {
    _socket?.emit('leave_community', {'hostelId': hostelId});
  }

  void emitTyping(String hostelId, String userName) {
    _socket?.emit('typing', {'hostelId': hostelId, 'userName': userName});
  }

  void emitStopTyping(String hostelId, String userName) {
    _socket?.emit('stop_typing', {'hostelId': hostelId, 'userName': userName});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _lastRoomId = null;
    _lastUserId = null;
    _lastRole = null;
  }

  void dispose() {
    _messageController.close();
    _messageEditedController.close();
    _messageDeletedController.close();
    _typingController.close();
    _stopTypingController.close();
    _bookingController.close();
    _noticeController.close();
    _dashboardRefreshController.close();
    disconnect();
  }
}
