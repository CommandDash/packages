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
}

class StringInput extends Input {
  String value;
  StringInput(String id, String type, this.value) : super(id, type);

  factory StringInput.fromJson(Map<String, dynamic> json) {
    return StringInput(
      json['id'],
      json['type'],
      json['value'],
    );
  }
}

// class CodeInput extends Input {}
