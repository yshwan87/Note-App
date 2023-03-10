// ignore_for_file: unused_import

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
  String searchWord = "";

  void changeOrder() {
    setState(() {
      isDescending = !isDescending;
      dateOrderMenu = "Date Ascending";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            centerTitle: false,
            title: Text(
              'Note Apps',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
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
                },
              ),
            ],
            bottom: AppBar(
              title: Container(
                width: double.infinity,
                height: 40,
                color: Colors.white,
                child: Center(
                  child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search for something',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchWord = value.toLowerCase();
                        });
                      }),
                ),
              ),
            ),
          ),
          // Other Sliver Widgets
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("Notes").orderBy("creation_date", descending: isDescending).snapshots(),
                    builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        final filteredDoc = snapshot.data!.docs.where((doc) => doc.data().toString().toLowerCase().contains(searchWord));
                        return GridView.builder(
                          itemCount: filteredDoc.length,
                          itemBuilder: (context, index) {
                            final note = filteredDoc.elementAt(index);
                            //if (searchWord == "") {
                            return noteCard(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => NoteEditorScreen(note)),
                                ),
                              );
                            }, note);
                          },
                          padding: const EdgeInsets.only(top: 0.0),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                        );
                      }
                      return Text(
                        "There is no Note",
                        style: GoogleFonts.nunito(color: Colors.white),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      ),
    );
  }
}
