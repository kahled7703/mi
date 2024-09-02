import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'usage_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE usage(id INTEGER PRIMARY KEY AUTOINCREMENT, meterNumber TEXT, waterAmount TEXT, previousWaterAmount TEXT, payment REAL, time TEXT)",
        );
        await db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, address TEXT, meterNumber TEXT)",
        );
        await db.execute(
          "CREATE TABLE subscriptions(id INTEGER PRIMARY KEY AUTOINCREMENT, meterNumber TEXT, subscriberName TEXT, FOREIGN KEY (meterNumber) REFERENCES users(meterNumber))",
        );
        await db.execute(
          "CREATE TABLE subscribers(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, meterNumber TEXT)",
        );
      },
    );
  }

  Future<void> insertUsage(Map<String, dynamic> data) async {
    final db = await database;
    try {
      await db.insert('usage', data);
    } catch (e) {
      print('Error inserting usage: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsage() async {
    final db = await database;
    try {
      return await db.query('usage');
    } catch (e) {
      print('Error retrieving usage: $e');
      return [];
    }
  }

  Future<void> updateUsage(Map<String, dynamic> data, int id) async {
    final db = await database;
    try {
      await db.update('usage', data, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error updating usage: $e');
    }
  }

  Future<void> deleteUsage(int id) async {
    final db = await database;
    try {
      await db.delete('usage', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting usage: $e');
    }
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      await db.insert('users', user);
    } catch (e) {
      print('Error inserting user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    try {
      return await db.query('users');
    } catch (e) {
      print('Error retrieving users: $e');
      return [];
    }
  }

  Future<void> insertSubscription(Map<String, dynamic> subscription) async {
    final db = await database;
    try {
      await db.insert('subscriptions', subscription);
    } catch (e) {
      print('Error inserting subscription: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllSubscriptions() async {
    final db = await database;
    try {
      return await db.query('subscriptions');
    } catch (e) {
      print('Error retrieving subscriptions: $e');
      return [];
    }
  }

  Future<void> insertSubscriber(String name, String phone, String meterNumber) async {
    final db = await database;
    try {
      await db.insert('subscribers', {'name': name, 'phone': phone, 'meterNumber': meterNumber});
    } catch (e) {
      print('Error inserting subscriber: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllSubscribers() async {
    final db = await database;
    try {
      return await db.query('subscribers');
    } catch (e) {
      print('Error retrieving subscribers: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUsageByMeterNumber(String meterNumber) async {
    final db = await database;
    try {
      final result = await db.query(
        'usage',
        where: 'meterNumber = ?',
        whereArgs: [meterNumber],
      );
      if (result.isNotEmpty) {
        return result.first;
      }
    } catch (e) {
      print('Error retrieving usage: $e');
    }
    return null;
  }
}



