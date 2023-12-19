import 'ChatMessage.dart';

class ChatMessageRepository  {
  final List<ChatMessage> _messages = [];

  Future<void> sendMessage(ChatMessage message) async {
    _messages.add(message);
  }

  Future<void> displayLocalMessage(ChatMessage message) async {
    _messages.add(message);
  }

  Stream<List<ChatMessage>> messagesStream() {
    return Stream.periodic(Duration(seconds: 1), (_) => _messages).asBroadcastStream();
  }

  Future<List<ChatMessage>> getMessages() async {
    return _messages;
  }
}
