import 'package:flutter/material.dart';
import 'package:aw/uesr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _username = "اسم المستخدم"; // Placeholder for the username
  String _address = "العنوان"; // Placeholder for the address

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.storage.request();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
      _username = prefs.getString('loggedInUser') ?? "اسم المستخدم";
      String? loggedInUserData = prefs.getString('loggedInUserData');
      if (loggedInUserData != null) {
        Map<String, dynamic> userData = jsonDecode(loggedInUserData);
        _username = userData['username'];
        _address = userData['address'];
      }
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('darkModeEnabled', _darkModeEnabled);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser');
    await prefs.remove('loggedInUserData');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage1(),
      ),
    );
  }

  Future<void> _deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    List<dynamic> usersList = usersJson != null ? jsonDecode(usersJson) : [];

    usersList.removeWhere((user) => user['username'] == _username);

    await prefs.setString('users', jsonEncode(usersList));
    await prefs.remove('loggedInUser');
    await prefs.remove('loggedInUserData');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  void _goToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage1(),
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, 'usage_database.db'));
      if (await dbFile.exists()) {
        final backupDir = await getExternalStorageDirectory();
        final backupPath = p.join(backupDir!.path, 'usage_database_backup.db');
        await dbFile.copy(backupPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء النسخة الاحتياطية بنجاح!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('قاعدة البيانات غير موجودة.'),
          ),
        );
      }
    } catch (e) {
      print('Error creating backup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إنشاء النسخة الاحتياطية.'),
        ),
      );
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, 'usage_database.db'));
      final backupDir = await getExternalStorageDirectory();
      final backupPath = p.join(backupDir!.path, 'usage_database_backup.db');
      final backupFile = File(backupPath);

      if (await backupFile.exists()) {
        await backupFile.copy(dbFile.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم استعادة قاعدة البيانات بنجاح!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('النسخة الاحتياطية غير موجودة.'),
          ),
        );
      }
    } catch (e) {
      print('Error restoring backup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في استعادة قاعدة البيانات.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تخصيص الإعدادات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text('تفعيل الإشعارات'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('تفعيل الوضع الداكن'),
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حفظ الإعدادات بنجاح!'),
                    ),
                  );
                },
                child: Text('حفظ الإعدادات'),
              ),
              SizedBox(height: 20),
              Divider(),
              ListTile(
                title: Text('معلومات المستخدم'),
                subtitle: Text('اسم المستخدم: $_username\nالعنوان: $_address'),
              ),
              Divider(),
              ElevatedButton(
                onPressed: _logout,
                child: Text('تسجيل الخروج'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              ElevatedButton(
                onPressed: _deleteUser,
                child: Text('حذف المستخدم'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goToHomePage,
                child: Text('الرجوع إلى القائمة الرئيسية'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createBackup,
                child: Text('إنشاء نسخة احتياطية من قاعدة البيانات'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              ElevatedButton(
                onPressed: _restoreBackup,
                child: Text('استعادة قاعدة البيانات من النسخة الاحتياطية'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






