// part of 'auth.dart';



// class LogoutCommand extends Command {
//   @override
//   String get description => 'Logout from welltested';

//   @override
//   String get name => 'logout';

//   @override
//   Future<void> run() async {
//     var userName = await Auth.userName;
//     if (userName.isEmpty) {
//       wtLog.info("You are not logged in");
//       return;
//     }
//     wtLog.startSpinner("Logging out...", severity: MessageSeverity.Info);
//     var loggedOut = Auth.logout();
//     loggedOut
//         ? wtLog.stopSpinner(
//             message: '✅ Logged out successfully.',
//             severity: MessageSeverity.Success)
//         : wtLog.stopSpinner(
//             message: '❌ Error logging out.', severity: MessageSeverity.Error);
//   }
// }
