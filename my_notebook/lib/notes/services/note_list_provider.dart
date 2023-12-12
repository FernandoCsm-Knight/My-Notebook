import 'package:my_notebook/notes/model/note.dart';
import 'package:my_notebook/notes/services/note_local_service.dart';
import 'package:my_notebook/notes/services/note_service.dart';
import 'package:my_notebook/settings/service/SettingsProvider.dart';

class NoteListProvider {
  List<Note> _notes = [];
  NoteService _noteService = NoteService();
  NoteLocalService _noteLocalService = NoteLocalService();
  SettingsProvider settingsProvider = SettingsProvider();

  List<Note> get notes => _notes;

  void add(Note note) {
    _notes.add(note);
  }

  void remove(Note note) {
    _notes.remove(note);
  }

  void update(Note note) {
    int index = _notes.indexWhere((element) => element.id == note.id);
    _notes[index] = note;
  }

  void clear() {
    _notes.clear();
  }

  void sort() {
    _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> refresh() async {
    List<Note> localList = await _noteLocalService.readNotes();

    if (settingsProvider.settings.onlySaveLocal) {
      _notes = localList;
    } else {
      List<Note> cloudList = await _noteService.readNotes();
      for (Note note in cloudList) {
        if (!localList.contains(note)) {
          await _noteLocalService.createFromNote(note: note);
          localList.add(note);
        }
      }

      for (Note note in localList) {
        if (!cloudList.contains(note)) {
          await _noteService.createFromNote(note: note);
        }
      }

      _notes = localList;
    }
  }
}
