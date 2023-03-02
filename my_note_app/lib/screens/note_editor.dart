// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_note_app/style/app_style.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen(this.doc, {super.key});

  final QueryDocumentSnapshot? doc;
  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  // ignore: non_constant_identifier_names
  int randomColor_id = Random().nextInt(AppStyle.cardsColor.length);
  String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mainController = TextEditingController();
  late int color;
  late String date;

  @override
  void initState() {
    if (widget.doc != null) {
      // if it is edit then page shows with data from FireBase
      _titleController.text = widget.doc!["note_title"];
      _mainController.text = widget.doc!["note_content"];
      color = widget.doc!["color_id"];
      date = widget.doc!["creation_date"];
    } else {
      color = randomColor_id;
      date = formattedDate;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[color],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[color],
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.doc == null ? "Add a new Note" : "Edit",
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Note Title'),
              style: AppStyle.mainTitle,
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              date,
              style: AppStyle.dateTitle,
            ),
            const SizedBox(
              height: 28.0,
            ),
            TextField(
              controller: _mainController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Note Content'),
              style: AppStyle.mainContent,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.doc == null) {
            // Add the new note
            FirebaseFirestore.instance.collection("Notes").add({
              "note_title": _titleController.text,
              "creation_date": date,
              "note_content": _mainController.text,
              "color_id": color
            }).then((value) {
              // ignore: avoid_print
              print(value.id);
              Navigator.pop(context);
              // ignore: avoid_print
            }).catchError((error) => print("Failed to add new Note due to $error"));
          } else {
            // Update the note
            FirebaseFirestore.instance.collection("Notes").doc(widget.doc!.id).update({
              "note_title": _titleController.text,
              "creation_date": date,
              "note_content": _mainController.text,
              "color_id": color
            }).then((value) {
              Navigator.pop(context);
              // ignore: avoid_print
            }).catchError((error) => print("Failed to edit the Note due to $error"));
          }
        },
        backgroundColor: AppStyle.accentColor,
        child: const Icon(Icons.save),
      ),
    );
  }
}
