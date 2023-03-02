import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String docId) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Continue"),
    onPressed: () async {
      Navigator.of(context).popUntil((route) => route.isFirst);
      await FirebaseFirestore.instance.collection('Notes').doc(docId).delete();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Delete"),
    content: const Text("Delete this Note?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
