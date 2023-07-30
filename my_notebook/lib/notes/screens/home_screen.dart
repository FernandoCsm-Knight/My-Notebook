import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/authentication/service/auth_service.dart';
import 'package:my_notebook/notes/components/show_create_dialog.dart';
import 'package:my_notebook/notes/model/note.dart';
import 'package:my_notebook/notes/services/fox_api.dart';
import 'package:my_notebook/notes/services/note_service.dart';

import '../components/note_tile.dart';
import '../components/show_delete_dialog.dart';
import 'note_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService noteService = NoteService();
  Future<String> imageUrl = FoxApi.getFoxImage();
  List<Note> noteList = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notebook'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                onTap: () {
                  setState(() {
                    imageUrl = FoxApi.getFoxImage();
                  });
                },
                child: FutureBuilder<String>(
                  future: imageUrl,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !(snapshot.connectionState == ConnectionState.waiting)) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!),
                        backgroundColor: Colors.black87,
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
              accountName: Text((widget.user.displayName != null)
                  ? widget.user.displayName!
                  : ''),
              accountEmail: Text(widget.user.email!),
              decoration: const BoxDecoration(
                color: Colors.black45,
              ),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                AuthService().signOut();
              },
            ),
            ListTile(
              title: const Text('Delete Account'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController passwordController =
                        TextEditingController();

                    return AlertDialog(
                      title: const Text('Delete Account'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Write your password to delete account.'),
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                AuthService()
                                    .deleteAccount(
                                        password: passwordController.text)
                                    .then((value) {
                                  if (value == null) {
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value),
                                      ),
                                    );
                                  }
                                });
                              },
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateDialog(
            context: context,
            refreshFunction: refresh,
            noteService: noteService,
          );
        },
        child: const Icon(Icons.create),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => refresh(),
              child: (noteList.isEmpty)
                  ? ListView(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          alignment: Alignment.topCenter,
                          child: const Text(
                            'There is no notes to be listed.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(200, 200, 200, 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        Note note = noteList[index];
                        return Dismissible(
                          key: ValueKey<Note>(note),
                          onDismissed: (direction) {
                            showDeleteDialog(
                              context: context,
                              note: note,
                              refreshFunction: refresh,
                              noteService: noteService,
                            );
                          },
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red[900],
                            padding: const EdgeInsets.only(right: 18.0),
                            child: const Icon(Icons.delete_outline),
                          ),
                          child: NoteTile(
                            note: note,
                            onTap: () {
                              Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteScreen(note: note),
                                ),
                              ).then(
                                (value) {
                                  if (value != null && value.isNotEmpty) {
                                    noteService.updateNote(
                                        id: note.id, note: value);
                                  }

                                  refresh();
                                },
                              );
                            },
                          ),
                        );
                      },
                      itemCount: noteList.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> refresh() async {
    List<Note> list = await noteService.readNotes();

    setState(() {
      noteList = list;
    });
  }
}
