import 'package:flutter/material.dart';

import '../model/note.dart';

Future<bool?> showDeleteDialog({
  required BuildContext context,
  required Note note,
}) {
  return showDialog<bool>(
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
      });
}
