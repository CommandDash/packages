abstract class Loader {
  const Loader();

  Map<String, dynamic> toJson();
}

class NoneLoader extends Loader {
  const NoneLoader() : super();
  @override
  Map<String, dynamic> toJson() => {'kind': 'none'};
}

class CircularLoader extends Loader {
  const CircularLoader() : super();
  @override
  Map<String, dynamic> toJson() => {'kind': 'circular'};
}

class MessageLoader extends Loader {
  final String message;

  const MessageLoader(this.message) : super();

  @override
  Map<String, dynamic> toJson() => {'kind': 'message', 'message': message};
}

class ProcessingFilesLoader extends Loader {
  final List<String> files;
  final String? message;

  const ProcessingFilesLoader(this.files, {this.message}) : super();

  @override
  Map<String, dynamic> toJson() => {
        'kind': 'processingFiles',
        'message': {if (message != null) 'value': message, 'files': files}
      };
}
