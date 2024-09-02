import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart';
import 'package:aw/HomePage.dart';



class WaterUsageManagementScreen extends StatefulWidget {
  @override
  _WaterUsageManagementScreenState createState() => _WaterUsageManagementScreenState();
}

class _WaterUsageManagementScreenState extends State<WaterUsageManagementScreen> {
  final TextEditingController _meterNumberController = TextEditingController();
  final TextEditingController _waterAmountController = TextEditingController();
  final TextEditingController _previousWaterAmountController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();

  bool _isInLiters = true;
  double _unitPrice = 200;
  List<Map<String, dynamic>> _usageData = [];
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  void _loadUsageData() async {
    try {
      List<Map<String, dynamic>> loadedData = await DatabaseHelper().getAllUsage();
      setState(() {
        _usageData = loadedData;
      });
    } catch (e) {
      _showErrorMessage('حدث خطأ في قاعدة البيانات: $e');
    }
  }

  void _saveUsageData() async {
    String meterNumber = _meterNumberController.text;
    String waterAmount = _waterAmountController.text;
    String previousWaterAmount = _previousWaterAmountController.text;
    double payment = double.parse(_paymentController.text);

    Map<String, dynamic> data = {
      'meterNumber': meterNumber,
      'waterAmount': waterAmount,
      'previousWaterAmount': previousWaterAmount,
      'payment': payment,
    };

    try {
      if (_selectedIndex == -1) {
        await DatabaseHelper().insertUsage(data);
        _showSuccessMessage('تمت إضافة البيانات بنجاح');
      } else {
        await DatabaseHelper().updateUsage(data, _usageData[_selectedIndex]['id']);
        _showSuccessMessage('تم تحديث البيانات بنجاح');
        _selectedIndex = -1;
      }
      _clearFields();
      _loadUsageData();
    } catch (e) {
      _showErrorMessage('حدث خطأ في قاعدة البيانات: $e');
    }
  }

  void _deleteUsage(int id) async {
    try {
      await DatabaseHelper().deleteUsage(id);
      _showSuccessMessage('تم حذف البيانات بنجاح');
      _loadUsageData();
    } catch (e) {
      _showErrorMessage('حدث خطأ في قاعدة البيانات: $e');
    }
  }

  void _clearFields() {
    _meterNumberController.clear();
    _waterAmountController.clear();
    _previousWaterAmountController.clear();
    _paymentController.clear();
    setState(() {
      _selectedIndex = -1;
    });
  }

  void _showDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('البيانات المسجلة'),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('رقم المشترك')),
                DataColumn(label: Text('استهلاك المياه (كجم)')),
                DataColumn(label: Text('الكمية المستهلكة السابقة (كجم)')),
                DataColumn(label: Text('السعر الإجمالي (ريال)')),
                DataColumn(label: Text('المدفوع (ريال)')),
                DataColumn(label: Text('المتبقي (ريال)')),
                DataColumn(label: Text('الوقت')),
                DataColumn(label: Text('')),
              ],
              rows: _usageData.map((data) {
                String meterNumber = data['meterNumber'];
                String waterAmount = data['waterAmount'];
                String previousWaterAmount = data['previousWaterAmount'] ?? '';
                double payment = data['payment'] ?? 0.0;
                double totalPrice = double.parse(waterAmount) * _unitPrice;
                double remainingAmount = totalPrice - payment;
                String timestamp = data['timestamp'] ?? '';
                return DataRow(cells: [
                  DataCell(Text(meterNumber)),
                  DataCell(Text(waterAmount)),
                  DataCell(Text(previousWaterAmount)),
                  DataCell(Text(totalPrice.toStringAsFixed(2))),
                  DataCell(Text(payment.toStringAsFixed(2))),
                  DataCell(Text(remainingAmount.toStringAsFixed(2))),
                  DataCell(Text(timestamp)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = _usageData.indexWhere((element) => element['id'] == data['id']);
                            _meterNumberController.text = meterNumber;
                            _waterAmountController.text = waterAmount;
                            _previousWaterAmountController.text = previousWaterAmount;
                            _paymentController.text = payment.toString();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showAlertDialog(
                            'حذف البيانات',
                            'هل أنت متأكد أنك تريد حذف هذا السجل؟',
                                () => _deleteUsage(data['id']),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.print),
                        onPressed: () {
                          _printData(data);
                        },
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _printData(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'مشروع المياه',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[
                    'رقم المشترك',
                    'استهلاك المياه (كجم)',
                    'الكمية المستهلكة السابقة (كجم)',
                    'السعر الإجمالي (ريال)',
                    'المدفوع (ريال)',
                    'المتبقي (ريال)',
                  ],
                  [
                    data['meterNumber'].toString(),
                    data['waterAmount'].toString(),
                    data['previousWaterAmount'] != null ? data['previousWaterAmount'].toString() : '',
                    (double.parse(data['waterAmount']) * _unitPrice).toStringAsFixed(2),
                    data['payment'].toStringAsFixed(2),
                    ((double.parse(data['waterAmount']) * _unitPrice) - data['payment']).toStringAsFixed(2),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _showUnitPriceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إدخال التسعير للوحدة المياه'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'السعر بالريال اليمني للكيلوجرام',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _unitPrice = double.parse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddSubscriberPage() async {
    final phoneNumber = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSubscriberPage()),
    );

    if (phoneNumber != null) {
      setState(() {
        _meterNumberController.text = phoneNumber;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة استهلاك المياه'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsageData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _meterNumberController,
              decoration: InputDecoration(
                labelText: 'رقم المشترك',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8.0),
            TextField(
controller: _waterAmountController,
decoration: InputDecoration(
labelText: 'استهلاك المياه (كجم)',
border: OutlineInputBorder(),
),
keyboardType: TextInputType.number,
),
SizedBox(height: 8.0),
TextField(
controller: _previousWaterAmountController,
decoration: InputDecoration(
labelText: 'الكمية المستهلكة السابقة (كجم)',
border: OutlineInputBorder(),
),
keyboardType: TextInputType.number,
),
SizedBox(height: 8.0),
TextField(
controller: _paymentController,
decoration: InputDecoration(
labelText: 'المبلغ المدفوع (ريال)',
border: OutlineInputBorder(),
),
keyboardType: TextInputType.number,
),
SizedBox(height: 16.0),
ElevatedButton(
onPressed: _saveUsageData,
child: Text('حفظ البيانات'),
),
SizedBox(height: 8.0),
ElevatedButton(
onPressed: _showDataDialog,
child: Text('عرض البيانات المسجلة'),
),
SizedBox(height: 8.0),
ElevatedButton(
onPressed: () => _showUnitPriceDialog(context),
child: Text('إدخال تسعير الوحدة'),
),
SizedBox(height: 8.0),
ElevatedButton(
onPressed: _navigateToAddSubscriberPage,
child: Text('إضافة مشترك جديد'),
),
],
),
),
);
}
}

class AddSubscriberPage extends StatelessWidget {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة مشترك جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _phoneNumberController.text);
              },
              child: Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}





