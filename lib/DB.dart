import 'dart:async';

import 'package:memoneday/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



class TaskDB {
  static Database? database;

  // Initialize database
  static Future<Database?>? initDatabase() async {
    database = await openDatabase(
      // Ensure the path is correctly for any platform
      join(await getDatabasesPath(), "task_database.db"),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE TASKS("
                "id INTEGER PRIMARY KEY,"
                "name TEXT"
                ")"
        );
      },

      // Version
      version: 1,
    );

    return database;
  }

  // Check database connected
  static Future<Database?>? getDatabaseConnect() async {
    if (database != null) {
      return database;
    }
    else {
      return await initDatabase();
    }
  }

  // Show all data
  static Future<List<Task>> showAllData() async {
    final Database? db = await getDatabaseConnect();
    final List<Map<String, dynamic>> maps = await db!.query("TASKS");

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]["id"],
        task: maps[i]["name"],
      );
    });
  }

  static Future<String> getonedata(int index) async {
    final Database? db = await getDatabaseConnect();
    final List<Map<String, dynamic>> maps = await db!.query("TASKS");

      return maps[index]["name"];
  }

  static Future<int> getCount()  async{
    var db =  await getDatabaseConnect();
    final List<Map<String, dynamic>> maps =  await db!.query("TASKS");
    return maps.length;
  }

  // Insert
  static Future<void> insertData(Task task) async {
    final Database? db = await getDatabaseConnect();
    await db!.insert(
      "TASKS",
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update
  static Future<void> updateData(Task task) async {
    final db = await getDatabaseConnect();
    await db!.update(
      "TASKS",
      task.toMap(),
      where: "id = ?",
      whereArgs: [task.id],
    );
  }

  // Delete
  static Future<void> deleteData(int id) async {
    final db = await getDatabaseConnect();
    await db!.delete(
      "TASKS",
      where: "id = ?",
      whereArgs: [id],
    );
  }

}