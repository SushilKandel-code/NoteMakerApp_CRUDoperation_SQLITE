import 'dart:io';
import 'package:notemakerapp/model/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; //Singleton DatabaseHelper
  static Database? _database; //Singleton Database

  String noteMakerTable = 'note_table';
  String columnID = 'id';
  String columnTitle = 'title';
  String columnDescription = 'description';
  String columnPriority = 'priority';
  String columnDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper!;
  }

  Future<Database> initializeDatabase() async {
    Directory? directory = await getApplicationDocumentsDirectory();
    String? path = directory.path + 'notes.db';
    print(path);
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDatabase);
    return notesDatabase;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  void _createDatabase(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteMakerTable($columnID INTEGER PRIMARY KEY AUTOINCREMENT, $columnTitle TEXT, '
        ' $columnDescription TEXT, $columnPriority INTEGER, $columnDate TEXT)');
  }

  //fetch Operation: Getting note info from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    // var result = await db
    //     .rawQuery('SELECT * FROM $noteMakerTable order by $columnPriority ASC');

    var result = await db.query(noteMakerTable, orderBy: '$columnPriority ASC');
    return result;
  }

  //Insert operation:
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteMakerTable, note.toMap());
    return result;
  }

  //Update Operaiton:
  Future<int>? updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteMakerTable, note.toMap(),
        where: '$columnID=?', whereArgs: [note.id]);
    return result;
  }

  //Delete Operation

  Future<int>? deleteNote(int id) async {
    var db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $noteMakerTable WHERE $columnID=$id');
    return result;
  }

  //Getting numbers of Note objects in database
  Future<int>? getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteMakerTable');

    int? result = Sqflite.firstIntValue(x);
    return result!;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int? count = noteMapList.length;
    // ignore: deprecated_member_use
    List<Note> noteList = <Note>[];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
