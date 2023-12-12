import 'package:flutter/material.dart';

import '../model/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final void Function()? onTap;

  const NoteTile({
    Key? key,
    required this.note,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.book),
        title: Text(note.title),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 20.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minVerticalPadding: 25,
      ),
    );
  }
}
