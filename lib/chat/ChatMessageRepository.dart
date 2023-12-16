import 'ChatMessage.dart';

class ChatMessageRepository  {
  final List<ChatMessage> _messages = [];

  @override
  Future<void> sendMessage(ChatMessage message) async {
    // Here, you would integrate your backend logic to send the message
    _messages.add(message);
  }

  @override
  Future<void> displayLocalMessage(ChatMessage message) async {
    // Dont send, only display locally
    _messages.add(message);
  }

  @override
  Stream<List<ChatMessage>> messagesStream() {
    // This should be connected to a real-time database or messaging service
    return Stream.periodic(Duration(seconds: 1), (_) => _messages).asBroadcastStream();
  }

  @override
  Future<List<ChatMessage>> getMessages() async {
    // This should fetch the messages from your database or backend
    return _messages;
  }
}
