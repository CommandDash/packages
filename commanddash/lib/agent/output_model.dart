abstract class Output {
  String id;
  String type;
  Output(this.id, this.type);

  factory Output.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'default_output') {
      return DefaultOutput(json['id'], type, json['value']);
    } else {
      throw UnimplementedError();
    }
  }
}

class DefaultOutput extends Output {
  String value;
  DefaultOutput(String id, String type, this.value) : super(id, type);

  factory DefaultOutput.fromJson(Map<String, dynamic> json) {
    return DefaultOutput(
      json['id'],
      json['type'],
      json['value'],
    );
  }
}
