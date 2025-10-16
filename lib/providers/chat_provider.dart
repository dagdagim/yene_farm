import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatProvider with ChangeNotifier {
  IO.Socket? _socket;
  final List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isConnected => _isConnected;

  void connect(String userId) {
    _socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.on('connect', (_) {
      _isConnected = true;
      _socket!.emit('join_chat', userId);
      notifyListeners();
    });

    _socket!.on('receive_message', (data) {
      _messages.add(data);
      notifyListeners();
    });

    _socket!.on('disconnect', (_) {
      _isConnected = false;
      notifyListeners();
    });
  }

  void sendMessage(String receiverId, String message) {
    final messageData = {
      'senderId': 'current_user_id', // Replace with actual user ID
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socket!.emit('send_message', messageData);
    _messages.add(messageData);
    notifyListeners();
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
    notifyListeners();
  }
}