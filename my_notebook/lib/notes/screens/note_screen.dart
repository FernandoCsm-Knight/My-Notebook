import 'package:flutter/material.dart';
import 'package:my_notebook/notes/components/show_rename_dialog.dart';
import 'package:my_notebook/notes/services/note_local_service.dart';
import 'package:my_notebook/notes/services/note_service.dart';
import 'package:my_notebook/settings/service/SettingsProvider.dart';

import '../model/note.dart';

class NoteScreen extends StatefulWidget {
  final Note note;
  const NoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  @override
  Widget build(BuildContext context) {
    final NoteService noteService = NoteService();
    final NoteLocalService noteLocalService = NoteLocalService();
    final TextEditingController noteController =
        TextEditingController(text: widget.note.note);
    final String lastChange = widget.note.note;
    final SettingsProvider settingsProvider = SettingsProvider();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Note: ${(widget.note.title.length >= 15) ? '${widget.note.title.substring(0, 15)}...' : widget.note.title}',
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, noteController.text.trim());
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'rename',
                  child: Text('Rename'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ];
            },
            onSelected: (value) async {
              if (value == 'rename') {
                showRenameDialog(
                  context: context,
                  note: widget.note,
                  noteService: noteService,
                  noteLocalService: noteLocalService,
                  settings: settingsProvider.settings,
                ).then(
                  (value) {
                    if (value != null && value.isNotEmpty) {
                      setState(() {
                        widget.note.title = value;
                      });
                    }
                  },
                );
              } else if (value == 'delete') {
                if (settingsProvider.settings.onlySaveLocal) {
                  await noteLocalService.deleteNote(id: widget.note.id);
                } else {
                  await noteService.deleteNote(id: widget.note.id);
                  await noteLocalService.deleteNote(id: widget.note.id);
                }

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: noteController,
                keyboardType: TextInputType.multiline,
                minLines: null,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  label: Text('Note...'),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created at: ${widget.note.createdAt.day}/${widget.note.createdAt.month}/${widget.note.createdAt.year}',
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (settingsProvider.settings.onlySaveLocal) {
                            await noteLocalService.updateNote(
                                id: widget.note.id, note: lastChange);
                          } else {
                            await noteService.updateNote(
                                id: widget.note.id, note: lastChange);

                            await noteLocalService.updateNote(
                                id: widget.note.id, note: lastChange);
                          }

                          Navigator.pop(context, '');
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
