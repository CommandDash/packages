abstract class Input {
  String id;
  String type;
  Input(this.id, this.type);

  factory Input.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == "string_input") {
      return StringInput.fromJson(json);
    } else {
      throw UnimplementedError();
    }
  }

  @override
  String toString();
}

class StringInput extends Input {
  String value;
  StringInput(String id, this.value) : super(id, 'string_input');

  factory StringInput.fromJson(Map<String, dynamic> json) {
    return StringInput(
      json['id'],
      json['value'],
    );
  }

  @override
  String toString() {
    return value;
  }
}

// class CodeInput extends Input {}
