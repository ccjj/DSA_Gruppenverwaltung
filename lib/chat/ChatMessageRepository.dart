import 'dart:async';

import 'ChatMessage.dart';

class ChatMessageRepository {
  final StreamController<ChatMessage> _messageController;
  final Map<String, List<ChatMessage>> _messages = {};

  ChatMessageRepository(this._messageController) {
    _messageController.stream.listen((ChatMessage newMessage) {
      addMessage(newMessage);
    });
  }

  void addMessage(ChatMessage message) {
    final result = _messages.putIfAbsent(message.groupId, () => []);
    result.add(message);
  }

  List<ChatMessage>? getMessages(String groupId) {
    return _messages[groupId];
  }
}
