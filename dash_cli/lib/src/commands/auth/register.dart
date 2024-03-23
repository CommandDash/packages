// part of 'auth.dart';

// class RegisterCommand extends Command {
//   @override
//   String get description => 'Register to welltested';

//   @override
//   String get name => 'register';

//   @override
//   Future<void> run() async {
//     var userName = await Auth.userName;
//     if (userName.isNotEmpty) {
//       wtLog.info("You are already logged in as ${userName.toUpperCase()}");
//       return;
//     }
//     var plan = Select(
//       prompt: "Choose a plan",
//       options: Plan.values.map((e) => e.toString().split('.').last).toList(),
//     ).interact();
//     var email = Input(
//         prompt: "Enter your email",
//         defaultValue: plan == 0 ? "Personal Mail ID" : "Organization Mail ID",
//         validator: (value) {
//           var mailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//           if (!mailRegExp.hasMatch(value)) {
//             throw ValidationError('Please enter a valid email');
//           } else {
//             return true;
//           }
//         }).interact();
//     var fName = Input(
//         prompt: "Enter your First Name",
//         defaultValue: "",
//         validator: (value) {
//           if (value.isEmpty) {
//             throw ValidationError('Please enter a valid name');
//           } else {
//             return true;
//           }
//         }).interact();
//     var lName = Input(
//         prompt: "Enter your Last Name",
//         defaultValue: "",
//         validator: (value) {
//           if (value.isEmpty) {
//             throw ValidationError('Please enter a valid name');
//           } else {
//             return true;
//           }
//         }).interact();
//     var company = Input(
//         prompt: "Enter your Company",
//         defaultValue: "",
//         validator: (value) {
//           if (value.isEmpty) {
//             throw ValidationError('Please enter a valid name');
//           } else {
//             return true;
//           }
//         }).interact();
//     var role = Select(
//       prompt: "Choose your Role",
//       options: Role.values.map((e) => e.name).toList(),
//     ).interact();
//     int tenure = 0;
//     if (plan != 0)
//       tenure = Select(
//         prompt: "Choose your Tenure",
//         options: Tenure.values.map((e) => e.name).toList(),
//       ).interact();
//     var form = RegisterForm(
//       firstName: fName,
//       lastName: lName,
//       email: email,
//       company: company,
//       role: Role.values[role],
//       accountPlan: Plan.values[plan],
//       tenure: Tenure.values[tenure],
//     );
//     wtLog.startSpinner("Registering...", severity: MessageSeverity.Info);
//     await Auth.register(form, onSuccess: () async {
//       try {
//         wtLog.stopSpinner(
//             message: '✅ API Key has been sent to your email.',
//             severity: MessageSeverity.Success);
//         var key = Password(
//           prompt: "Please enter your key received in email",
//           confirmation: false,
//           // defaultValue: "API Key",
//           // validator: (value) {
//           //   if (value.isEmpty || value == "API Key" || value.length < 84) {
//           //     throw ValidationError('API Key can\'t be empty');
//           //   } else {
//           //     return true;
//           //   }
//           // }
//         ).interact();
//         wtLog.startSpinner("Saving credentials...",
//             severity: MessageSeverity.Info);
//         var info = await UserRepository().getUserInfo(key);
//         var saved = Auth.saveCredentials(info, key);
//         saved
//             ? wtLog.stopSpinner(
//                 message: '✅ Credentials saved successfully.',
//                 severity: MessageSeverity.Success)
//             : wtLog.stopSpinner(
//                 message: '❌ Error saving credentials.',
//                 severity: MessageSeverity.Error);
//         exit(0);
//       } catch (e) {
//         wtLog.stopSpinner(
//             message: 'Error: ${e}', severity: MessageSeverity.Error);
//         exit(1);
//       }
//     }, onFailure: (error) {
//       wtLog.stopSpinner(
//           message: 'Error: ${error}', severity: MessageSeverity.Error);
//       exit(1);
//     });
//   }
// }
