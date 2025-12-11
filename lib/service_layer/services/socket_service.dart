import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../utils/constants.dart';
import '../../controller/session_controller.dart';

/// Socket.IO Service for real-time chat communication
class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  
  final SessionController _sessionController = Get.find<SessionController>();

  /// Callback for connection status changes
  Function(bool)? onConnectionStatusChanged;

  /// Get socket instance
  IO.Socket? get socket => _socket;
  
  /// Check if socket is connected
  bool get isConnected => _isConnected;

  /// Initialize and connect socket
  Future<bool> connect() async {
    if (_isConnected || _isConnecting) {
      return _isConnected;
    }

    final token = _sessionController.token.value;
    if (token == null || token.isEmpty) {
      print('❌ SocketService: No token available for connection');
      return false;
    }

    try {
      _isConnecting = true;
      print('🔄 SocketService: Connecting to Socket.IO server...');

      // Connect to chat namespace
      _socket = IO.io(
        '${ApiConstants.socketUrl}${ApiConstants.socketNamespace}',
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .setTimeout(20000)
            .build(),
      );

      _setupEventHandlers();

      // Wait for connection
      await Future.delayed(const Duration(milliseconds: 500));

      return _isConnected;
    } catch (e) {
      print('❌ SocketService: Connection error: $e');
      _isConnecting = false;
      return false;
    }
  }

  /// Setup event handlers
  void _setupEventHandlers() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      print('✅ SocketService: Connected to Socket.IO server');
      _isConnected = true;
      _isConnecting = false;
      // إشعار ChatController بالتغيير
      onConnectionStatusChanged?.call(true);
    });

    _socket!.onDisconnect((reason) {
      print('❌ SocketService: Disconnected: $reason');
      _isConnected = false;
      _isConnecting = false;
      // إشعار ChatController بالتغيير
      onConnectionStatusChanged?.call(false);
    });

    _socket!.onConnectError((error) {
      print('❌ SocketService: Connection error: $error');
      _isConnected = false;
      _isConnecting = false;
      // إشعار ChatController بالتغيير
      onConnectionStatusChanged?.call(false);
    });

    _socket!.onError((error) {
      print('❌ SocketService: Error: $error');
    });

    // Listen for reconnection events
    _socket!.onReconnect((attemptNumber) {
      print('🔄 SocketService: Reconnecting (attempt $attemptNumber)...');
    });

    _socket!.onReconnectAttempt((attemptNumber) {
      print('🔄 SocketService: Reconnection attempt $attemptNumber');
    });

    _socket!.onReconnectError((error) {
      print('❌ SocketService: Reconnection error: $error');
    });

    _socket!.onReconnectFailed((_) {
      print('❌ SocketService: Reconnection failed');
      _isConnected = false;
      _isConnecting = false;
      onConnectionStatusChanged?.call(false);
    });
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket != null) {
      print('🔌 SocketService: Disconnecting...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _isConnecting = false;
      // إشعار ChatController بالتغيير
      onConnectionStatusChanged?.call(false);
    }
  }

  /// Join a conversation room
  void joinConversation(String conversationId) {
    if (_socket == null || !_isConnected) {
      print('⚠️ SocketService: Socket not connected, cannot join conversation');
      return;
    }

    print('👤 SocketService: Joining conversation: $conversationId');
    _socket!.emit('join_conversation', {'conversationId': conversationId});
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    if (_socket == null || !_isConnected) {
      return;
    }

    print('👋 SocketService: Leaving conversation: $conversationId');
    _socket!.emit('leave_conversation', {'conversationId': conversationId});
  }

  /// Send a message
  void sendMessage({
    required String receiverId,
    String? content,
    String? imageUrl,
  }) {
    if (_socket == null || !_isConnected) {
      print('⚠️ SocketService: Socket not connected, cannot send message');
      return;
    }

    final data = {
      'receiverId': receiverId,
      if (content != null && content.isNotEmpty) 'content': content,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    };

    print('📨 SocketService: Sending message to $receiverId');
    _socket!.emit('send_message', data);
  }

  /// Send a message as secretary
  void sendMessageAsSecretary({
    required String receiverId,
    String? content,
    String? imageUrl,
  }) {
    if (_socket == null || !_isConnected) {
      print('⚠️ SocketService: Socket not connected, cannot send message');
      return;
    }

    final data = {
      'receiverId': receiverId,
      if (content != null && content.isNotEmpty) 'content': content,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    };

    print('📨 SocketService: Sending secretary message to $receiverId');
    _socket!.emit('send_message_as_secretary', data);
  }

  /// Mark messages as read
  void markAsRead(String conversationId) {
    if (_socket == null || !_isConnected) {
      return;
    }

    _socket!.emit('mark_read', {'conversationId': conversationId});
  }

  /// Listen to an event
  void on(String event, Function(dynamic) callback) {
    if (_socket == null) {
      print('⚠️ SocketService: Socket not initialized, cannot listen to event: $event');
      return;
    }

    _socket!.on(event, callback);
  }

  /// Remove listener for an event
  void off(String event, [Function(dynamic)? callback]) {
    if (_socket == null) {
      return;
    }

    if (callback != null) {
      _socket!.off(event, callback);
    } else {
      _socket!.off(event);
    }
  }

  /// Reconnect socket (useful after token refresh)
  Future<bool> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    return await connect();
  }
}

