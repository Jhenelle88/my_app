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
    // Bumped version to 24 to clear all data and insert corrected cry history data
    return await openDatabase(path, version: 24, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
    await _insertMockData(db);
  }

  Future<void> _createCryHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE cry_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        time TEXT NOT NULL,
        date TEXT NOT NULL,
        output TEXT NOT NULL,
        accuracy TEXT NOT NULL,
        segments TEXT,
        confidence TEXT,
        raw_scores TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _insertMockData(Database db) async {
    final List<Map<String, dynamic>> users = await db.query('users', limit: 1);
    int targetUserId = 1;
    if (users.isNotEmpty) {
      targetUserId = users.first['id'];
    }

    // March 2, 2026 data
    final List<Map<String, dynamic>> mar2Data = [
      {'userId': targetUserId, 'time': '08:27 PM', 'date': 'Mar 2, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '08:28 PM', 'date': 'Mar 2, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '08:29 PM', 'date': 'Mar 2, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '11:02 PM', 'date': 'Mar 2, 2026', 'output': 'Discomfort', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '11:03 PM', 'date': 'Mar 2, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '11:04 PM', 'date': 'Mar 2, 2026', 'output': 'Hunger', 'accuracy': 'True'},
    ];

    // March 3, 2026 data
    final List<Map<String, dynamic>> mar3Data = [
      {'userId': targetUserId, 'time': '03:48 AM', 'date': 'Mar 3, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:49 AM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '03:50 AM', 'date': 'Mar 3, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '06:38 AM', 'date': 'Mar 3, 2026', 'output': 'Sleeping', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '06:39 AM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '10:23 AM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '10:24 AM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '11:58 AM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '01:26 PM', 'date': 'Mar 3, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '01:27 PM', 'date': 'Mar 3, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:05 PM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:06 PM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:48 PM', 'date': 'Mar 3, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '08:47 PM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '09:02 PM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '09:03 PM', 'date': 'Mar 3, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '09:55 PM', 'date': 'Mar 3, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '09:57 PM', 'date': 'Mar 3, 2026', 'output': 'Sleeping', 'accuracy': 'False'},
    ];

    // March 4, 2026 data
    final List<Map<String, dynamic>> mar4Data = [
      {'userId': targetUserId, 'time': '07:25 AM', 'date': 'Mar 4, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '07:26 AM', 'date': 'Mar 4, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '09:32 AM', 'date': 'Mar 4, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '10:41 AM', 'date': 'Mar 4, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '10:46 AM', 'date': 'Mar 4, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '12:55 PM', 'date': 'Mar 4, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '01:12 PM', 'date': 'Mar 4, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '03:34 PM', 'date': 'Mar 4, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '06:04 PM', 'date': 'Mar 4, 2026', 'output': 'Pain', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '10:28 PM', 'date': 'Mar 4, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '02:53 AM', 'date': 'Mar 4, 2026', 'output': 'Hunger', 'accuracy': 'True'},
    ];

    // March 5, 2026 data
    final List<Map<String, dynamic>> mar5Data = [
      {'userId': targetUserId, 'time': '03:15 AM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '03:16 AM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '04:06 AM', 'date': 'Mar 5, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '05:02 AM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '07:05 AM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '08:14 AM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      // Cry 5 records (Updated to Mar 5)
      {'userId': targetUserId, 'time': '09:11 AM', 'date': 'Mar 5, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '09:11 AM', 'date': 'Mar 5, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '09:12 AM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '09:12 AM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '10:20 AM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '10:20 AM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '10:21 AM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '10:21 AM', 'date': 'Mar 5, 2026', 'output': 'Discomfort', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '12:14 PM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '12:15 PM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '12:15 PM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '12:16 PM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '02:46 PM', 'date': 'Mar 5, 2026', 'output': 'Discomfort', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '02:46 PM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '02:47 PM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '02:47 PM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:31 PM', 'date': 'Mar 5, 2026', 'output': 'Pain', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:31 PM', 'date': 'Mar 5, 2026', 'output': 'Pain', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:32 PM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '03:32 PM', 'date': 'Mar 5, 2026', 'output': 'Pain', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '05:25 PM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '05:26 PM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '05:26 PM', 'date': 'Mar 5, 2026', 'output': 'Sleeping', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '05:26 PM', 'date': 'Mar 5, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '08:48 PM', 'date': 'Mar 5, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '08:48 PM', 'date': 'Mar 5, 2026', 'output': 'Pain', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '08:49 PM', 'date': 'Mar 5, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '08:49 PM', 'date': 'Mar 5, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
    ];

    // March 6, 2026 data
    final List<Map<String, dynamic>> mar6Data = [
      {'userId': targetUserId, 'time': '09:38 AM', 'date': 'Mar 6, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '09:39 AM', 'date': 'Mar 6, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '10:53 AM', 'date': 'Mar 6, 2026', 'output': 'Pain', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '10:54 AM', 'date': 'Mar 6, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '10:55 AM', 'date': 'Mar 6, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '11:47 AM', 'date': 'Mar 6, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '11:49 AM', 'date': 'Mar 6, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '12:47 PM', 'date': 'Mar 6, 2026', 'output': 'Pain', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '12:48 PM', 'date': 'Mar 6, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '01:12 PM', 'date': 'Mar 6, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '01:14 PM', 'date': 'Mar 6, 2026', 'output': 'Sleeping', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '01:14 PM', 'date': 'Mar 6, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '03:05 PM', 'date': 'Mar 6, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:06 PM', 'date': 'Mar 6, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '03:47 PM', 'date': 'Mar 6, 2026', 'output': 'Pain', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '03:48 PM', 'date': 'Mar 6, 2026', 'output': 'Hunger', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '04:58 PM', 'date': 'Mar 6, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '04:59 PM', 'date': 'Mar 6, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '05:43 PM', 'date': 'Mar 6, 2026', 'output': 'Hunger', 'accuracy': 'False'},
      {'userId': targetUserId, 'time': '05:44 PM', 'date': 'Mar 6, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
      {'userId': targetUserId, 'time': '05:45 PM', 'date': 'Mar 6, 2026', 'output': 'Discomfort', 'accuracy': 'True'},
    ];

    // Insert all data
    final allMockData = [...mar2Data, ...mar3Data, ...mar4Data, ...mar5Data, ...mar6Data];
    for (var row in allMockData) {
      await db.insert('cry_history', row);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN imagePath TEXT');
    }
    if (oldVersion < 3) {
      await _createCryHistoryTable(db).catchError((e) { });
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE cry_history ADD COLUMN date TEXT NOT NULL DEFAULT \'\'');
      } catch (e) {}
    }
    if (oldVersion < 5) {
       try {
        await db.execute('ALTER TABLE cry_history ADD COLUMN segments TEXT');
      } catch (e) {}
    }
    if (oldVersion < 9) {
      try {
        await db.execute('ALTER TABLE cry_history ADD COLUMN confidence TEXT');
        await db.execute('ALTER TABLE cry_history ADD COLUMN raw_scores TEXT');
      } catch (e) {}
    }
    if (oldVersion < 24) {
      // Version 24: Clear all history and re-insert requested data
      await db.delete('cry_history');
      await _insertMockData(db);
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

  Future<int> updatePasswordByEmail(String email, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> insertCryRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('cry_history', row);
  }

  Future<List<Map<String, dynamic>>> getCryHistoryByDate(int userId, String date) async {
    final db = await instance.database;
    return await db.query('cry_history', where: 'userId = ? AND date = ?', whereArgs: [userId, date], orderBy: 'id DESC');
  }

  Future<Map<String, int>> getCryReasonCountsByDate(int userId, String date) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'cry_history',
      columns: ['output', 'COUNT(*) as count'],
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date],
      groupBy: 'output',
    );

    final Map<String, int> counts = {};
    for (var row in result) {
      counts[row['output']] = row['count'] as int;
    }
    return counts;
  }

  Future<void> deleteCryHistory(int userId) async {
    final db = await instance.database;
    await db.delete('cry_history', where: 'userId = ?', whereArgs: [userId]);
  }
}
