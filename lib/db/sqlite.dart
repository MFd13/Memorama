import 'package:flutter/cupertino.dart';
import 'package:memorama/db/data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Sqlite {
  static Database? db;

  static Future<Database> get database async {
    if (db != null) return db!;
    db = await bd();
    return db!;
  }

  static Future<Database> bd() async {
    debugPrint("Path: ${await getDatabasesPath()}");
    return openDatabase(
      join(await getDatabasesPath(), 'datos.db'),
      onCreate: (db, version) async {
        await db.execute("""
      CREATE TABLE datos(
        id INTEGER PRIMARY KEY, 
        fecha TEXT, 
        hora TEXT,
        victorias INTEGER, 
        derrotas INTEGER
      );
      """);
        await db.insert("datos", {
          "id": 1,
          "fecha": "2025-03-20",
          "hora": "00:00:00",
          "victorias": 0,
          "derrotas": 0
        });
      },
      version: 1,
    );
  }

  static Future<int> insert(Data data) async {
    final db = await database;
    return db.insert("datos", data.toMap());
  }

  static Future<int> delete(Data data) async {
    final db = await database;
    return db.delete("datos", where: "id = 1");
  }

  Future<int> update(Data data) async {
    final db = await database;
    return db.update("datos", data.toMap(), where: "id = 1");
  }

  static Future<Data?> find() async {
    final db = await database;
    final List<Map<String, dynamic>> datosMap = await db.query("datos", where: "id = 1");
    if (datosMap.isNotEmpty) {
      return Data(
          id: datosMap[0]['id'],
          fecha: datosMap[0]['fecha'],
          hora: datosMap[0]['hora'],
          wins: datosMap[0]['victorias'],
          loses: datosMap[0]['derrotas']
      );
    }
    return null;
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
