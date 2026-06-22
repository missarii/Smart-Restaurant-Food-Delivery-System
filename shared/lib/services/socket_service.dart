import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;
  final String serverUrl;

  SocketService({this.serverUrl = 'http://localhost:3000'});

  IO.Socket? get socket => _socket;
  bool get isConnected => _isConnected;

  void connect() {
    if (_socket != null) return;

    _socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    _socket!.onConnect((_) {
      _isConnected = true;
      notifyListeners();
      if (kDebugMode) print('Connected to Socket.io Server');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
      if (kDebugMode) print('Disconnected from Socket.io Server');
    });

    _socket!.connect();
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }
}
