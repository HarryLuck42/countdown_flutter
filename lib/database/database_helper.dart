import 'package:countdown_app/model/count_down.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(
      documentDirectory.path,
      'countdown.db',
    );
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute(
        '''CREATE TABLE countdowns(id INTEGER PRIMARY KEY, seconds INTEGER, date TEXT)''');
  }

  Future<List<CountDown>> getCountDowns() async {
    Database db = await instance.database;
    var countdowns = await db.query(
      'countdowns',
      orderBy: 'id',
    );
    List<CountDown> data = countdowns.isNotEmpty
        ? countdowns.map((e) => CountDown.fromMap(e)).toList()
        : [];
    return data;
  }

  Future<int> addCountDowns(CountDown data) async {
    Database db = await instance.database;
    return await db.insert('countdowns', data.toMap());
  }
}
