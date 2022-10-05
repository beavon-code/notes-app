import 'package:flutter/cupertino.dart';
import 'package:notesapp/utilities/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Log Out',
    content: 'Are you sure you want to logout?',
    optionBuilder: () => {
      'cancel': false,
      'log out': true,
    },
  ).then((value) => value ?? false);
}
