import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_note_app/screens/note_editor.dart';
import 'package:my_note_app/widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDescending = false;
  String dateOrderMenu = "Date Descending";

  void changeOrder() {
    setState(() {
      isDescending = !isDescending;
      dateOrderMenu = "Date Ascending";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          title: Text('Fire Notes',
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              )),
          backgroundColor: Colors.white,
          actions: [
            PopupMenuButton(
                icon: const Icon(
                  Icons.menu_sharp,
                  color: Colors.black,
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Text(dateOrderMenu),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Text("Settings"),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Text("Logout"),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 0) {
                    changeOrder();
                  } else if (value == 1) {
                    print("Settings menu is selected.");
                  } else if (value == 2) {
                    print("Logout menu is selected.");
                  }
                }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5.0,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("Notes").orderBy("creation_date", descending: isDescending).snapshots(),
                  builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasData) {
                      return GridView(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        children: snapshot.data!.docs
                            .map(
                              (note) => noteCard(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) => NoteEditorScreen(note)),
                                    ));
                              }, note),
                            )
                            .toList(),
                      );
                    }
                    return Text(
                      "There is no Note",
                      style: GoogleFonts.nunito(color: Colors.white),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => const NoteEditorScreen(null)),
              ),
            );
          },
          label: const Text("Add Note"),
          icon: const Icon(Icons.add),
        ));
  }
}
