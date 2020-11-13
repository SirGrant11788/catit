import 'dart:io';
import 'package:cat_it/logic/globalDbSelect.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static final _databaseName = "MyDatabase.db";//use loacal preff to store multiple names for dbs
  static final _databaseVersion = 1;

  static final table = 'my_table';//main table
  static final tableFav = 'fav_table';//fav table

  //main table
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnCat = 'cat';
  static final columnDesc = 'desc';
  static final columnPic = 'pic';

  //fav table
  static final columnIdFav = '_id_fav';
  static final columnFav = 'fav';
  static final columnFavName = 'fav_name';

  // only have a single app-wide reference to the database
  Database _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDatabase();
      return _database;
    }
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    List <String> dbs = [];
    final localCache = await SharedPreferences.getInstance();
    if (localCache.getStringList('databases') == null) {
    dbs.add("Wardrobe");
    dbs.add("Office");
    dbs.add("Pantry");
    localCache.setStringList('databases', dbs);
    }else{
      dbs = (localCache.getStringList('databases'));
    }

    GlobalDbSelect dbSelect = GlobalDbSelect();
    if(dbSelect.dbNumber == null){
      dbSelect.dbNumber = 0;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbs[dbSelect.dbNumber]);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table todo check auto NOT NULL AUTO_INCREMENT
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnCat TEXT NOT NULL,
            
            $columnDesc TEXT,
            $columnPic TEXT
          );''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS $tableFav (
            $columnId INTEGER NOT NULL,
            $columnIdFav INTEGER PRIMARY KEY,
            $columnFavName TEXT NOT NULL,
            $columnFav TEXT NOT NULL,
            FOREIGN KEY ($columnId) REFERENCES $table($columnId)
          );''');
  }
  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(table, row);
  }
  Future<int> insertFav(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableFav, row);
  }
  Future insertColumn(name) async {
    Database db = await database;
    return await db.rawQuery('''ALTER TABLE $table ADD $name TEXT''');
  }
  Future insertQuery(col,name,item) async {
    Database db = await database;
    return await db.rawQuery('''UPDATE $table SET $col = '$name' WHERE $columnName = '$item' ''');//need to change from name to id
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await database;
    return await db.query(table);
  }
  Future<List<Map<String, dynamic>>> queryAllRowsFav() async {
    Database db = await database;
    return await db.query(tableFav);
  }
  Future<List<Map<String, dynamic>>> queryColumns() async {//get all column names
    Database db = await database;
    return await db.rawQuery("PRAGMA table_info(" + table + ")", null);
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }
  Future updateQueryFavName(id,name) async {
    Database db = await database;
    return await db.rawQuery('''UPDATE $tableFav SET $columnFavName = '$name' WHERE $columnId = $id''');
  }
  Future<int> updateFav(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[columnIdFav];
    return await db.update(tableFav, row, where: '$columnIdFav = ?', whereArgs: [id]);
  }
  //edit item page
  Future updateItemQuery(id,col,name) async {
    Database db = await database;
    return await db.rawQuery('''UPDATE $table SET $col = '$name' WHERE $columnId = $id''');
  }
  Future updateItemQueryFav(id,col,name) async {
    Database db = await database;
    return await db.rawQuery('''UPDATE $tableFav SET $columnFavName = '$name' WHERE $columnId = $id''');
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  Future<int> deleteFav(int id) async {
    Database db = await database;
    return await db.delete(tableFav, where: '$columnIdFav = ?', whereArgs: [id]);
  }
  Future<int> deleteFavName(String name) async {
    Database db = await database;
    return await db.delete(tableFav, where: '$columnFavName = ?', whereArgs: [name]);
  }
}