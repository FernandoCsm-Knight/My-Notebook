import 'package:flutter/material.dart';

import '../model/note.dart';
import '../services/note_service.dart';

Future<String?> showRenameDialog({
  required BuildContext context,
  required NoteService noteService,
  required Note note,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      final TextEditingController titleController =
          TextEditingController(text: note.title);
      final formKey = GlobalKey<FormState>();

      return Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rename Note',
                style: TextStyle(fontSize: 20.0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'The note title can\'t be empty.';
                      }

                      return null;
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        noteService.updateTitle(
                          id: note.id,
                          title: titleController.text.trim(),
                        );

                        Navigator.pop(context, titleController.text.trim());
                      }
                    },
                    child: const Text('Rename'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
