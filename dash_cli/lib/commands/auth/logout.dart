part of 'auth.dart';

class LogoutCommand extends Command<Object> {
  @override
  String get description => 'Logout from dash_cli';

  @override
  String get name => 'logout';

  @override
  Future<void> run() async {
    AuthStatus isUserLoggedIn = await Auth.isAuthenticated;

    if (isUserLoggedIn == AuthStatus.notAuthenticated) {
      wtLog.info('You are not logged in');
      return;
    }
    
    wtLog.startSpinner('Logging out...', severity: MessageSeverity.info);
    bool loggedOut = Auth.logout();
    loggedOut
        ? wtLog.stopSpinner(
            message: '✅ Logged out successfully.',
            severity: MessageSeverity.success)
        : wtLog.stopSpinner(
            message: '❌ Error logging out.', severity: MessageSeverity.error);
  }
}
