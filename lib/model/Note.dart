class Note {
  String uuid;
  String content;

  Note({required this.uuid, required this.content});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      uuid: json['id'],
      content: json['content'],
    );
  }
}