

class PersonalChatMessageRepository  {
  final List<String> _messages = [];

  void add(String message) {
    _messages.add(message);
  }

  String? getMessageAt(int index) {
    return _messages[index];
  }

  void reset(){
    _messages.clear();
  }

  List<String> getMessages(){
    return _messages;
  }

}
