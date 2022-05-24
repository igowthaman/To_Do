import 'dart:async';
import 'package:sqflite/sqflite.dart';

class Task{
  int id;
  String name;

  Task({required this.id, required this.name});

  Map<String, dynamic> toJson(){
    return{"id":id,"name":name};
  }
}

class DbManager {
  late Database _database;

  Future openDb() async {
    _database = await openDatabase("globus_bd_v1.db",
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE task (id INTEGER PRIMARY KEY autoincrement, name TEXT);'
      );
    });
    return _database;
  }

  Future insertTask(String task) async {
    await openDb();
    return await _database.insert('task', {"name":task});
  }


  Future<List<Task>> getTask() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery("SELECT id, name FROM task");

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        name : maps[i]['name']
      );
    });
  }

  Future deleteTask(int id) async {
    await openDb();
    return await _database.delete("task",where: "id = "+id.toString());
  }

  Future updateTask(Task task) async {
    await openDb();
    return await _database.update("task",task.toJson(),where: "id = "+task.id.toString());
  }
}