import 'package:flutter/material.dart';
import 'package:my_notebook/notes/services/note_service.dart';

import '../model/note.dart';

void showDeleteDialog({
  required BuildContext context,
  required Note note,
  required Future<void> Function() refreshFunction,
  required NoteService noteService,
}) {
  showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 32.0),
                child: Text(
                  'Realy want to delete ${(note.title.length > 30) ? '${note.title.substring(0, 30)}...' : note.title}?',
                  style: const TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              )
            ],
          ),
        );
      }).then(
    (value) async {
      if (value != null && value) {
        noteService.deleteNote(id: note.id).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            'Note deleted.',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          )));
        });
      }

      refreshFunction();
    },
  );
}
