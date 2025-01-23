import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'users.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            location TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
  final db = await database;

  // Check if the user already exists by name and email
  final existingUser = await db.query(
    'users',
    where: 'name = ? AND email = ?',
    whereArgs: [user['name'], user['email']],
  );

  if (existingUser.isNotEmpty) {
    return 0; // Return 0 to indicate no new insertion
  }

  return await db.insert('users', user);
}


  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<void> updateSyncedUser(int id) async {
    final db = await database;
    await db.update(
      'users',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
    final db = await database;
    return await db.query('users', where: 'synced = ?', whereArgs: [0]);
  }
}
