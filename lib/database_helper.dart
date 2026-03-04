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

    return await openDatabase(path, version: 9, onCreate: _onCreate, onUpgrade: _onUpgrade);
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

    final List<String> dates = ['Mar 2, 2026', 'Mar 3, 2026', 'Mar 4, 2026', 'Mar 5, 2026', 'Mar 6, 2026'];
    
    for (String date in dates) {

      final List<Map<String, dynamic>> existing = await db.query('cry_history', where: 'date = ?', whereArgs: [date]);
      if (existing.isNotEmpty) continue;

      List<Map<String, dynamic>> dataForDate = [];

      if (date == 'Mar 2, 2026') {
        dataForDate = [
          {'userId': targetUserId, 'time': '01:48 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.4%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '02:32 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '91.2%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '05:26 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.1%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '07:10 AM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '88.7%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '09:03 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '93.5%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '11:41 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '96.2%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '01:18 PM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '89.4%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '03:47 PM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.8%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '06:22 PM', 'date': date, 'output': 'Pain', 'accuracy': 'False', 'segments': '[]', 'confidence': '75.2%', 'raw_scores': 'Pain: 0.7\nDiscomfort: 0.2\nHungry: 0.1\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '08:55 PM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.5%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '09:28 PM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '92.9%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
        ];
      } else if (date == 'Mar 3, 2026') {
        dataForDate = [
          {'userId': targetUserId, 'time': '12:58 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.1%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '01:40 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '91.5%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '04:15 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.3%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '06:50 AM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '88.9%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '09:27 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.6%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '09:59 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '93.2%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '12:33 PM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '89.1%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '04:05 PM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.0%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '07:42 PM', 'date': date, 'output': 'Pain', 'accuracy': 'True', 'segments': '[]', 'confidence': '85.4%', 'raw_scores': 'Pain: 0.8\nDiscomfort: 0.1\nHungry: 0.1\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '10:16 PM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '92.7%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
        ];
      } else if (date == 'Mar 4, 2026') {
        dataForDate = [
          {'userId': targetUserId, 'time': '02:07 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.5%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '02:46 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '91.8%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '05:12 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.6%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '07:38 AM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '89.2%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '08:05 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.9%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '08:44 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '93.4%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '11:29 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '96.5%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '01:02 PM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '92.1%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '03:18 PM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '89.7%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '05:41 PM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.2%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '06:03 PM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '88.5%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '08:36 PM', 'date': date, 'output': 'Pain', 'accuracy': 'False', 'segments': '[]', 'confidence': '76.8%', 'raw_scores': 'Pain: 0.7\nDiscomfort: 0.2\nHungry: 0.1\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '10:57 PM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '93.1%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
        ];
      } else if (date == 'Mar 5, 2026') {
        dataForDate = [
          {'userId': targetUserId, 'time': '01:25 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.3%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '03:59 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '91.7%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '06:14 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.4%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '08:33 AM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '89.0%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '11:05 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '96.3%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '01:48 PM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '92.4%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '04:22 PM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.7%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '07:15 PM', 'date': date, 'output': 'Pain', 'accuracy': 'True', 'segments': '[]', 'confidence': '86.1%', 'raw_scores': 'Pain: 0.8\nDiscomfort: 0.1\nHungry: 0.1\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '09:52 PM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '92.8%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
        ];
      } else if (date == 'Mar 6, 2026') {
        dataForDate = [
          {'userId': targetUserId, 'time': '12:44 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.2%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '01:21 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '91.6%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '04:37 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.5%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '07:02 AM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '89.1%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '09:16 AM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '94.8%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '09:40 AM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '93.3%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '12:11 PM', 'date': date, 'output': 'Discomfort', 'accuracy': 'True', 'segments': '[]', 'confidence': '89.3%', 'raw_scores': 'Discomfort: 0.8\nPain: 0.1\nHungry: 0.0\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '02:54 PM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '95.1%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '05:33 PM', 'date': date, 'output': 'Hunger', 'accuracy': 'True', 'segments': '[]', 'confidence': '96.4%', 'raw_scores': 'Hungry: 0.9\nPain: 0.0\nSleepiness: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '06:08 PM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '92.5%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
          {'userId': targetUserId, 'time': '08:49 PM', 'date': date, 'output': 'Pain', 'accuracy': 'True', 'segments': '[]', 'confidence': '86.3%', 'raw_scores': 'Pain: 0.8\nDiscomfort: 0.1\nHungry: 0.1\nSleepiness: 0.0'},
          {'userId': targetUserId, 'time': '11:14 PM', 'date': date, 'output': 'Sleeping', 'accuracy': 'True', 'segments': '[]', 'confidence': '92.9%', 'raw_scores': 'Sleepiness: 0.9\nPain: 0.0\nHungry: 0.0\nDiscomfort: 0.0'},
        ];
      }

      for (var row in dataForDate) {
        await db.insert('cry_history', row);
      }
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN imagePath TEXT');
    }
    if (oldVersion < 3) {
      await _createCryHistoryTable(db).catchError((e) { /* table probably already exists */ });
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
