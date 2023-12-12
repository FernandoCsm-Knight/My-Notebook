import 'package:flutter/material.dart';
import 'package:my_notebook/notes/services/note_local_service.dart';
import 'package:my_notebook/notes/services/note_service.dart';
import 'package:my_notebook/settings/model/AppSettings.dart';
import 'package:uuid/uuid.dart';

Future<T?> showCreateDialog<T>({
  required BuildContext context,
  required Future<void> Function() refreshFunction,
  required NoteService noteService,
  required NoteLocalService noteLocalService,
  required AppSettings settings,
}) {
  final formKey = GlobalKey<FormState>();
  return showDialog<T>(
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
                            onPressed: () async {
                              if(formKey.currentState!.validate()) {
                                String uuid = Uuid().v1();

                                if(settings.onlySaveLocal) {
                                  await noteLocalService.createNote(uuid: uuid, title: titleController.text);
                                } else {
                                  await noteService.createNote(uuid: uuid, title: titleController.text);
                                  await noteLocalService.createNote(uuid: uuid, title: titleController.text);
                                }

                                Navigator.pop(context);
                                await refreshFunction();
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
