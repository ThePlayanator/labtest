import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLDB {
  static const String _dbName = "bitp3453_bmi";
  static const String _tblName = "bmi";
  static const String _colUsername = "username";
  static const String _colWeight = "weight";
  static const String _colHeight = "height";
  static const String _colGender = "gender";
  static const String _colStatus = "bmi_status";

  Database? _sqldb;

  SQLDB._();

  static final SQLDB _instance = SQLDB._();

  factory SQLDB() {
    return _instance;
  }

  Future<Database> get database async {
    if (_sqldb != null) {
      return _sqldb!;
    }
    String path = join(await getDatabasesPath(), _dbName,);
    _sqldb = await openDatabase(
      path,
      version: 1,
      onCreate: (createDb, version) async {
        for (String tableSql in SQLDB.tableSQLStrings) {
          await createDb.execute(tableSql);
        }
      },
    );
    return _sqldb!;
  }

  static List<String> tableSQLStrings = [
    '''
      CREATE TABLE IF NOT EXISTS $_tblName (id INTEGER PRIMARY KEY AUTOINCREMENT,
          $_colUsername TEXT,
          $_colWeight DOUBLE,
          $_colHeight DOUBLE,
          $_colGender TEXT,
          $_colStatus TEXT)
          ''',
  ];

  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    Database db = await _instance.database;
    return await db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    Database db = await _instance.database;
    return await db.query(tableName);
  }
}
