import 'package:aw/uesr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aw/database_helper.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
class kha extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class PreferencesManager {
  static const _keySubscriberName = 'subscriberName';
  static const _keySubscriberPhone = 'subscriberPhone';
  static const _keyPaymentDate = 'paymentDate';
  static const _keyRemainingAmount = 'remainingAmount';

  static Future<void> saveSubscriber({
    required String name,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubscriberName, name);
    await prefs.setString(_keySubscriberPhone, phone);
  }

  static Future<Map<String, String>> getSubscriber() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keySubscriberName) ?? '';
    final phone = prefs.getString(_keySubscriberPhone) ?? '';
    return {'name': name, 'phone': phone};
  }

  static Future<void> savePayment({
    required String paymentDate,
    required double remainingAmount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPaymentDate, paymentDate);
    await prefs.setDouble(_keyRemainingAmount, remainingAmount);
  }

  static Future<Map<String, dynamic>> getPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentDate = prefs.getString(_keyPaymentDate) ?? '';
    final remainingAmount = prefs.getDouble(_keyRemainingAmount) ?? 0.0;
    return {'paymentDate': paymentDate, 'remainingAmount': remainingAmount};
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة المشتركين'),
          actions: [
      IconButton(
      icon: Icon(Icons.home),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>HomePage1 ()),
        );
      },
    ),
    ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddSubscriberPage()),
                );
              },
              child: Text('إضافة مشترك جديد'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriberSearchPage()),
                );
              },
              child: Text('البحث عن مشترك'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentDetailsFormPage()),
                );
              },
              child: Text('بيانات الدفع'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddSubscriberPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة مشترك جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اسم المشترك',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'رقم المشترك',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showConfirmationDialog(context);
              },
              child: Text('حفظ المشترك'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تأكيد الحفظ'),
          content: Text('هل أنت متأكد أنك تريد حفظ المشترك؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                String name = nameController.text;
                String phone = phoneController.text;
                _saveSubscriber(name, phone);
                Navigator.of(context).pop();
                _showSuccessMessage(context, 'تم حفظ المشترك بنجاح');
              },
              child: Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _saveSubscriber(String name, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> subscribers = prefs.getStringList('subscribers') ?? [];
    subscribers.add(jsonEncode({'name': name, 'phone': phone}));
    await prefs.setStringList('subscribers', subscribers);
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}






class SubscriberSearchPage extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('البحث عن مشترك'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'ابحث عن مشترك',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String meterNumber = searchController.text;
                final usage = await dbHelper.getUsageByMeterNumber(meterNumber);
                if (usage != null) {
                  String waterAmount = usage['waterAmount'] ?? 'N/A';
                  String previousWaterAmount = usage['previousWaterAmount'] ?? 'N/A';
                  String payment = usage['payment'].toString();
                  String time = usage['time'] ?? 'N/A';

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('بيانات الاستخدام'),
                          IconButton(
                            icon: Icon(Icons.print),
                            onPressed: () async {
                              // تحميل الخط العربي
                              final font = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
                              final ttf = pw.Font.ttf(font);

                              // وظيفة الطباعة باستخدام مكتبة printing
                              await Printing.layoutPdf(
                                onLayout: (PdfPageFormat format) {
                                  final pdf = pw.Document();
                                  pdf.addPage(
                                    pw.Page(
                                      build: (context) {
                                        return pw.Table.fromTextArray(
                                          context: context,
                                          cellStyle: pw.TextStyle(font: ttf, fontSize: 12),
                                          headerStyle: pw.TextStyle(font: ttf, fontSize: 14),
                                          data: <List<String>>[
                                            <String>['المعلومة', 'القيمة'],
                                            <String>['كمية الماء', waterAmount],
                                            <String>['الكمية السابقة', previousWaterAmount],
                                            <String>['الدفع', payment],
                                            <String>['الوقت', time],
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                  return pdf.save();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DataTable(
                            columns: [
                              DataColumn(label: Text('المعلومة')),
                              DataColumn(label: Text('القيمة')),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Text('كمية الماء')),
                                DataCell(Text(waterAmount)),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('الكمية السابقة')),
                                DataCell(Text(previousWaterAmount)),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('الدفع')),
                                DataCell(Text(payment)),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('الوقت')),
                                DataCell(Text(time)),
                              ]),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('موافق'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('خطأ'),
                      content: Text('لا يوجد بيانات استخدام بهذا الرقم'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('موافق'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('بحث'),
            ),
          ],
        ),
      ),
    );
  }
}




class PaymentDetailsFormPage extends StatefulWidget {
  @override
  _PaymentDetailsFormPageState createState() => _PaymentDetailsFormPageState();
}

class _PaymentDetailsFormPageState extends State<PaymentDetailsFormPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  double remainingAmount = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final paymentData = await PreferencesManager.getPayment();
      setState(() {
        remainingAmount = paymentData['remainingAmount'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('بيانات الدفع'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'تاريخ الدفع',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'المبلغ المدفوع',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'الرصيد المتبقي: $remainingAmount',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await PreferencesManager.savePayment(
                  paymentDate: dateController.text,
                  remainingAmount: remainingAmount,
                );

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('تم حفظ بيانات الدفع'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('تاريخ الدفع: ${dateController.text}'),
                        Text('المبلغ المدفوع: ${amountController.text}'),
                        Text('الرصيد المتبقي: $remainingAmount'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('موافق'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('حفظ بيانات الدفع'),
            ),
          ],
        ),
      ),
    );
  }
}

