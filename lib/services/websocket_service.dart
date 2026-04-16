import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/constants/api_constants.dart';
import '../models/ws_order_event.dart';

enum WsConnectionStatus { connecting, connected, disconnected }

/// Manages the WebSocket connection to `/ws/orders`.
///
/// Exposes [onEvent] as a broadcast Stream and [connectionStatus] for
/// UI indicators. Reconnects automatically with exponential backoff.
class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  final _eventController = StreamController<WsOrderEvent>.broadcast();
  final _statusController = StreamController<WsConnectionStatus>.broadcast();

  bool _disposed = false;
  Duration _reconnectDelay = const Duration(seconds: 3);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  /// Stream of parsed order events from the WebSocket.
  Stream<WsOrderEvent> get onEvent => _eventController.stream;

  /// Stream of connection status changes.
  Stream<WsConnectionStatus> get statusStream => _statusController.stream;

  void connect() {
    if (_disposed) return;
    _setStatus(WsConnectionStatus.connecting);
    _doConnect();
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _setStatus(WsConnectionStatus.disconnected);
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _eventController.close();
    _statusController.close();
  }

  void _doConnect() {
    if (_disposed) return;

    try {
      final uri = Uri.parse(ApiConstants.wsUrl);
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // Mark connected after the stream starts (no handshake confirmation from server)
      _setStatus(WsConnectionStatus.connected);
      _reconnectDelay = const Duration(seconds: 3); // Reset backoff on success
    } catch (e) {
      debugPrint('[WS] Connection error: $e');
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = WsOrderEvent.fromJson(json);
      _eventController.add(event);
    } catch (e) {
      debugPrint('[WS] Parse error: $e | raw: $raw');
    }
  }

  void _onError(Object error) {
    debugPrint('[WS] Stream error: $error');
    _setStatus(WsConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('[WS] Connection closed.');
    _setStatus(WsConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    debugPrint('[WS] Reconnecting in ${_reconnectDelay.inSeconds}s...');

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_disposed) _doConnect();
    });

    // Exponential backoff capped at 30s
    _reconnectDelay = Duration(
      seconds: (_reconnectDelay.inSeconds * 2).clamp(3, _maxReconnectDelay.inSeconds),
    );
  }

  void _setStatus(WsConnectionStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}
