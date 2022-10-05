import 'package:flutter/cupertino.dart';

import 'generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete the item?',
    optionBuilder: () => {
      'cancel': false,
      'yes': true,
    },
  ).then((value) => value ?? false);
}
