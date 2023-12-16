class ChatMessage {
  final String messageContent;
  final String groupId;
  final DateTime timestamp;
  final String ownerId;
  final bool isPrivate;

  ChatMessage({required this.messageContent, required this.groupId, required this.timestamp, required this.ownerId, this.isPrivate = false});
}
