import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ConnectionDb {
  static final ConnectionDb instance = ConnectionDb._init();
  static Database? _database;

  ConnectionDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("task_db.db");
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id      INTEGER PRIMARY KEY AUTOINCREMENT,
        task    TEXT    NOT NULL,
        done    INTEGER NOT NULL, 
        created TEXT    NOT NULL  
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
