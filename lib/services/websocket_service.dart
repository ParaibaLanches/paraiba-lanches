import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/ws_order_event.dart';

enum WsConnectionStatus { connecting, connected, disconnected }

/// Manages the SSE connection to Next.js `/api/customer/stream/orders`.
///
/// Exposes [onEvent] as a broadcast Stream and [connectionStatus] for
/// UI indicators. Reconnects automatically on failure.
class WebSocketService {
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  final _eventController = StreamController<WsOrderEvent>.broadcast();
  final _statusController = StreamController<WsConnectionStatus>.broadcast();

  bool _disposed = false;
  Duration _reconnectDelay = const Duration(seconds: 3);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  /// Stream of parsed order events from SSE.
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
    SSEClient.unsubscribeFromSSE();
    _setStatus(WsConnectionStatus.disconnected);
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _eventController.close();
    _statusController.close();
  }

  Future<void> _doConnect() async {
    if (_disposed) return;

    try {
      final token = await TokenStorage.getAccessToken() ?? '';
      
      final url = '${ApiConstants.sseUrl}?token=$token';

      _subscription = SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: url,
        header: {
          "Accept": "text/event-stream",
          "Cache-Control": "no-cache",
        },
      ).listen(
        (event) {
          if (event.data != null && event.data!.isNotEmpty) {
            _onMessage(event.data!);
          }
        },
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _setStatus(WsConnectionStatus.connected);
      _reconnectDelay = const Duration(seconds: 3); // Reset backoff
    } catch (e) {
      debugPrint('[SSE] Connection error: $e');
      _scheduleReconnect();
    }
  }

  void _onMessage(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      
      if (json['type'] == 'connected') {
        debugPrint('[SSE] Server acknowledged connection.');
        return;
      }
      
      final event = WsOrderEvent.fromJson(json);
      _eventController.add(event);
    } catch (e) {
      debugPrint('[SSE] Parse error: $e | raw: $raw');
    }
  }

  void _onError(Object error) {
    debugPrint('[SSE] Stream error: $error');
    _setStatus(WsConnectionStatus.disconnected);
    SSEClient.unsubscribeFromSSE();
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('[SSE] Connection closed.');
    _setStatus(WsConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    debugPrint('[SSE] Reconnecting in ${_reconnectDelay.inSeconds}s...');

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_disposed) _doConnect();
    });

    // Exponential backoff capped at 30s
    _reconnectDelay = Duration(
      seconds: (_reconnectDelay.inSeconds * 2).clamp(
        3,
        _maxReconnectDelay.inSeconds,
      ),
    );
  }

  void _setStatus(WsConnectionStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}
