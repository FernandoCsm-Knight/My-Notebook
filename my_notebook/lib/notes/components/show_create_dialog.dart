import 'package:flutter/material.dart';
import 'package:my_notebook/notes/services/note_service.dart';

void showCreateDialog({
  required BuildContext context,
  required Future<void> Function() refreshFunction,
  required NoteService noteService,
}) {
  final formKey = GlobalKey<FormState>();
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController titleController = TextEditingController();

      return Dialog(
        alignment: Alignment.center,
        insetPadding: const EdgeInsets.all(18.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Create new note',
                  style: TextStyle(fontSize: 22.0),
                  textAlign: TextAlign.left,
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        label: Text('Note\'s title'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty) {
                          return 'The note title can\'t be empty.';
                        }
              
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              if(formKey.currentState!.validate()) {
                                noteService.createNote(title: titleController.text);
                                Navigator.pop(context);
                                refreshFunction();
                              }
                            },
                            child: const Text('Create'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
