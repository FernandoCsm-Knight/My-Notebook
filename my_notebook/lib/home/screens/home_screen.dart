import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/common/application_bottom_app_bar.dart';
import 'package:my_notebook/common/application_drawer.dart';
import 'package:my_notebook/notes/components/show_create_dialog.dart';
import 'package:my_notebook/notes/model/note.dart';
import 'package:my_notebook/notes/services/note_list_provider.dart';
import 'package:my_notebook/notes/services/fox_api.dart';
import 'package:my_notebook/notes/services/note_local_service.dart';
import 'package:my_notebook/notes/services/note_service.dart';
import 'package:my_notebook/settings/service/SettingsProvider.dart';

import '../../notes/components/note_tile.dart';
import '../../notes/components/show_delete_dialog.dart';
import '../../notes/screens/note_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService noteService = NoteService();
  final NoteLocalService noteLocalService = NoteLocalService();
  SettingsProvider settingsProvider = SettingsProvider();
  Future<String> imageUrl = FoxApi.getFoxImage();
  NoteListProvider noteListProvider = NoteListProvider();

  @override
  void initState() {
    super.initState();
    settingsProvider.loadSettings().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notebook'),
      ),
      drawer: ApplicationDrawer(
        user: widget.user,
      ),
      bottomNavigationBar: ApplicationBottomAppBar(user: widget.user),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateDialog(
            context: context,
            refreshFunction: () async {
              await noteListProvider.refresh();
              setState(() {});
            },
            noteService: noteService,
            noteLocalService: noteLocalService,
            settings: settingsProvider.settings,
          );
        },
        child: const Icon(Icons.create),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await noteListProvider.refresh();
                setState(() {});
              },
              child: noteListView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget noteListView() {
    return FutureBuilder(
      future: noteListProvider.refresh(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error'),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (noteListProvider.notes.isEmpty) {
            return ListView(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  alignment: Alignment.topCenter,
                  child: Text(
                    'There is no notes to be listed.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: (settingsProvider.settings.darkThemeEnabled)
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              Note note = noteListProvider.notes[index];
              return Dismissible(
                key: ValueKey<Note>(note),
                onDismissed: (direction) {
                  showDeleteDialog(
                    context: context,
                    note: note,
                  ).then(
                    (value) async {
                      if (value != null && value) {
                        if (settingsProvider.settings.onlySaveLocal) {
                          await noteLocalService.deleteNote(id: note.id);
                        } else {
                          await noteLocalService.deleteNote(id: note.id);
                          await noteService.deleteNote(id: note.id);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Note deleted.',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      await noteListProvider.refresh();
                      setState(() {});
                    },
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
                      (value) async {
                        if (value != null && value.isNotEmpty) {
                          if (settingsProvider.settings.onlySaveLocal) {
                            await noteLocalService.updateNote(
                                id: note.id, note: value);
                          } else {
                            await noteService.updateNote(
                                id: note.id, note: value);
                            await noteLocalService.updateNote(
                                id: note.id, note: value);
                          }
                        }

                        await noteListProvider.refresh();
                        setState(() {});
                      },
                    );
                  },
                ),
              );
            },
            itemCount: noteListProvider.notes.length,
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
