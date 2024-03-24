part of 'auth.dart';

class LoginCommand extends Command<Object> {
  @override
  String get description => 'Login with welltested account';

  @override
  String get name => 'login';

  LoginCommand();

  @override
  Future<void> run() async {
    await Auth.login(
        onSuccess: () {},
        onFailure: (_) {
          wtLog.error('Login failedL ${_.toString()}');
        });
  }
}
