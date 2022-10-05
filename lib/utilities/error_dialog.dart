import 'package:flutter/cupertino.dart';
import 'package:notesapp/utilities/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: text,
    content: 'An error occured',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
