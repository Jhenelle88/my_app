import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'app_database.db');
    return await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        contactNumber TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        address TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        imagePath TEXT
      )
    ''');
    await _createCryHistoryTable(db);
  }

  Future<void> _createCryHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE cry_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        time TEXT NOT NULL,
        output TEXT NOT NULL,
        accuracy TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN imagePath TEXT');
    }
    if (oldVersion < 3) {
      await _createCryHistoryTable(db);
    }
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('users', row);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update('users', row, where: 'id = ?', whereArgs: [id]);
  }

  // Methods for cry_history table
  Future<int> insertCryRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('cry_history', row);
  }

  Future<List<Map<String, dynamic>>> getCryHistory(int userId) async {
    final db = await instance.database;
    return await db.query('cry_history', where: 'userId = ?', whereArgs: [userId], orderBy: 'id DESC');
  }

  Future<Map<String, int>> getCryReasonCounts(int userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'cry_history',
      columns: ['output', 'COUNT(*) as count'],
      where: 'userId = ?',
      whereArgs: [userId],
      groupBy: 'output',
    );

    final Map<String, int> counts = {};
    for (var row in result) {
      counts[row['output']] = row['count'] as int;
    }
    return counts;
  }
}
