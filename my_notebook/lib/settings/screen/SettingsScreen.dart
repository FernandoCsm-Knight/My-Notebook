import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/common/application_drawer.dart';
import 'package:my_notebook/common/storage/services/file_service.dart';
import 'package:my_notebook/notes/services/note_service.dart';
import 'package:my_notebook/settings/service/SettingsProvider.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsProvider _service = SettingsProvider();

  @override
  void initState() {
    super.initState();
    _service.loadSettings().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      drawer: ApplicationDrawer(user: widget.user),
      body: ListView(
        children: [
          ListTile(
            title: Text('Dark Theme', style: TextStyle(fontSize: 20)),
            trailing: Switch(
              value: _service.settings.darkThemeEnabled,
              onChanged: (value) {
                _service.updateSettings(darkThemeEnabled: value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title:
                Text('Only save notes local', style: TextStyle(fontSize: 20)),
            trailing: Switch(
              value: _service.settings.onlySaveLocal,
              onChanged: (value) {
                _service.updateSettings(onlySaveLocal: value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('Random profile picture',
                style: TextStyle(fontSize: 20)),
            trailing: Switch(
              value: _service.settings.randomProfilePicture,
              onChanged: (value) {
                _service.updateSettings(randomProfilePicture: value);
                setState(() {});
              },
            ),
          ),
          Divider(thickness: 3),
          ListTile(
            title: const Text('Delete all notes', style: TextStyle(fontSize: 20)),
            leading: Icon(Icons.bookmark_remove_rounded, size: 30),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outlined,
                color: Colors.red[400],
              ),
              onPressed: () {
                NoteService noteService = NoteService();
                noteService.deleteDoc();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All notes deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Delete all pdf files', style: TextStyle(fontSize: 20)),
            leading: const Icon(Icons.picture_as_pdf, size: 30),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outlined,
                color: Colors.red,
              ),
              onPressed: () async {
                FileService fileService = FileService();
                await fileService.deleteAllPdf(uid: widget.user.uid);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All pdf files deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
