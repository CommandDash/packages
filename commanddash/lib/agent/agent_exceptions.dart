class AgentException implements Exception {
  final String? message;
  AgentException([this.message]);
  @override
  String toString() {
    return message ??
        'AgentException: Unknow error occurred while executing agent';
  }
}

class InvalidInputException implements AgentException {
  // TODO: Improve this error message
  @override
  String? get message =>
      "InvalidInputException: This means either expected inputs were not provided. ";
}
