import 'package:run/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int _version = 2;
  static const String _dbName = "logging.db";

  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
    //creates a local database if there isn't one already
      onCreate: (db, version) async => 
      await db.execute("CREATE TABLE logging(id STRING PRIMARY KEY, runD STRING, walkD STRING, runTime DOUBLE, walkTime DOUBLE, runSpeed DOUBLE, walkSpeed DOUBLE, totalMinute INT, totalSecond INT)"),
        version: _version,
    );
  }

//adds a run log 
  static Future<int> addLog(logging log) async{
    final db = await _getDB();
    return await db.insert("logging", log.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

//for retrieving the stats for a certain logged run
  static Future<logging> getData(String id) async{
  final db = await _getDB();
  final map = await db.rawQuery("SELECT * FROM logging WHERE id = ? ", [id]);
  return logging.fromJson(map.first);
  }

  static Future<List<logging>?> getAllLog() async {
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("logging");

    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => logging.fromJson(maps[index]));
  }

    static Future<int> deleteLog(logging log) async{
    final db = await _getDB();
    return await db.delete("logging",
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }
}