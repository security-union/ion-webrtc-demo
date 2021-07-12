//Function which shows Alert Dialog
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

alertDialog(BuildContext context, String alert) {
  // This is the ok button
  Widget ok = TextButton(
    child: const Text("Okay"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  // show the alert dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(alert),
        actions: [ok],
        elevation: 5,
      );
    },
  );
}
