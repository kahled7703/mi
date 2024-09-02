import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:aw/HomePage.dart';
import 'package:aw/RegisterScreen.dart';
import 'WaterMeterPage.dart';
import 'database_helper.dart';
import 'DashboardScreen.dart';
import 'SettingsScreen.dart';
import 'WaterUsageManagementScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الدخول'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'مرحبًا بك في تطبيقنا!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'اسم المستخدم',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String username = usernameController.text;
                final String password = passwordController.text;

                DatabaseHelper dbHelper = DatabaseHelper();
                List<Map<String, dynamic>> usersList = await dbHelper.getUsers();

                bool isAuthenticated = usersList.any((user) =>
                user['username'] == username && user['password'] == password);

                if (isAuthenticated) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('اسم المستخدم أو كلمة المرور غير صحيحة'),
                    ),
                  );
                }
              },
              child: Text('تسجيل الدخول'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class HomePage1  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 50,
              ),
              SizedBox(height: 20),
              Icon(
                Icons.home,
                size: 50,
              ),
              SizedBox(height: 20),
              Icon(
                Icons.person,
                size: 50,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>WaterUsageManagementScreen (),
            ),
          );
        },

        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                    builder: (context) => SettingsScreen (),
      ),
      );
              },
              icon: Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () {

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthlyReportPage(),
                  ),
                );
              },
              icon: Icon(Icons.description),
            ),
            SizedBox(),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => kha(),
                  ),
                );
              },
              icon: Icon(Icons.person),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SentMessagesPage (),
                  ),
                );

              },
              icon: Icon(Icons.notifications),

            ),
          ],
        ),
      ),
    );
  }
}







