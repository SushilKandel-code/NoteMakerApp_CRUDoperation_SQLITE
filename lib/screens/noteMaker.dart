import 'package:flutter/material.dart';
import 'package:notemakerapp/Utils/Database_Helper.dart';
import 'package:notemakerapp/model/note.dart';
import 'package:notemakerapp/screens/noteDetails.dart';
import 'package:sqflite/sqflite.dart';

// ignore: must_be_immutable
class NoteMaker extends StatefulWidget {
  @override
  _NoteMakerState createState() => _NoteMakerState();
}

class _NoteMakerState extends State<NoteMaker> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note>? noteList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      // ignore: deprecated_member_use
      noteList = <Note>[];
      updateListView();
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Notes',
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FloatingActionButton(
            onPressed: () {
              navigationToDetails(Note('', '', 2, ''), 'Add Notes');
            },
            tooltip: 'Add Note',
            child: Center(
              child: Icon(
                Icons.add,
              ),
            ),
          ),
        ),
        body: noteView(),
      ),
    );
  }

  ListView noteView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (context, int? position) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      getPriorityColor(this.noteList![position!].priority!),
                  child: getPriorityIcon(this.noteList![position].priority!),
                ),
                trailing: InkWell(
                  child: Icon(Icons.delete),
                  onTap: () {
                    _deletNote(context, noteList![position]);
                  },
                ),
                title: Text(this.noteList![position].title!),
                subtitle: Text(this.noteList![position].description!),
                onTap: () {
                  navigationToDetails(this.noteList![position], 'Edit Notes');
                },
              ),
            ),
          );
        });
  }

  //Returns Priority Color

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        // ignore: dead_code
        break;
      case 2:
        return Colors.yellow;
        // ignore: dead_code
        break;

      default:
        return Colors.yellow;
    }
  }

  // Return Priority Icons

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        // ignore: dead_code
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        // ignore: dead_code
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _deletNote(BuildContext context, Note note) async {
    int? result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String? message) {
    final snackBar = SnackBar(
      content: Text(message!),
    );
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigationToDetails(Note? note, String? title) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return NoteDetails(
            appDetails: title!,
            note: note!,
          );
        },
      ),
    );
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
