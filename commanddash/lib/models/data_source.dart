class DataSource {
  String content;
  String id;
  String? publisher;

  DataSource({required this.id, required this.content, this.publisher});

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      content: json['content'],
      // publisher: json['publisher'],
      id: json['pebble_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'publisher': publisher,
      'pk': id,
    };
  }
}
