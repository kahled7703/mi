
import 'package:flutter/material.dart';
import 'database_helper.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _selectedGovernorate;

  // قائمة المحافظات اليمنية
  final List<String> _governorates = [
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'حضرموت',
    'ذمار',
    'البيضاء',
    'الجوف',
    'لحج',
    'المحويت',
    'المهرة',
    'ريمة',
    'شبوة',
    'صعدة',
    'عمران',
    'الضالع',
    'أبين',
    'حجة',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء حساب جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'أنشئ حسابًا جديدًا',
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
            TextFormField(
              controller: confirmPasswordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'إعادة كلمة المرور',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'العنوان',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              value: _selectedGovernorate,
              items: _governorates.map((String governorate) {
                return DropdownMenuItem<String>(
                  value: governorate,
                  child: Text(governorate),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGovernorate = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String username = usernameController.text;
                final String password = passwordController.text;
                final String confirmPassword = confirmPasswordController.text;
                final String? address = _selectedGovernorate;

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('كلمتا المرور غير متطابقتين'),
                    ),
                  );
                  return;
                }

                if (address == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('يرجى اختيار العنوان'),
                    ),
                  );
                  return;
                }

                DatabaseHelper dbHelper = DatabaseHelper();
                try {
                  await dbHelper.insertUser({
                    'username': username,
                    'password': password,
                    'address': address,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم إضافة المستخدم الجديد بنجاح!'),
                    ),
                  );

                  // العودة إلى شاشة تسجيل الدخول بعد إنشاء الحساب
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ أثناء إضافة المستخدم: $e'),
                    ),
                  );
                }
              },
              child: Text('إنشاء حساب'),
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
