import 'package:flutter/material.dart';

class Note {
  String id;
  DateTime createdAt;
  String title;
  String note;

  Note({Key? key, required this.id, required this.title, required this.note, required this.createdAt});

  Note.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        note = map['note'],
        createdAt = DateTime.parse(map['createdAt']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
