import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart'; // استيراد مكتبة الطباعة

import 'database_helper.dart'; // استيراد كلاس DatabaseHelper

class MonthlyReportPage extends StatefulWidget {
  @override
  _MonthlyReportPageState createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> usageList = []; // لتخزين البيانات المخزنة مسبقاً
  bool isLoading = true; // لإدارة حالة التحميل

  @override
  void initState() {
    super.initState();
    // استرجاع البيانات المخزنة مسبقاً عند بدء تشغيل الصفحة
    fetchUsageData();
  }

  Future<void> fetchUsageData() async {
    usageList = await dbHelper.getAllUsage();
    setState(() {
      isLoading = false; // تم تحميل البيانات، لذا ليس هناك حاجة لعرض رمز التحميل
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقرير الاستهلاك الشهري'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // عرض رمز التحميل أثناء جلب البيانات
          : usageList.isEmpty
          ? Center(
        child: Text('لا توجد بيانات'),
      )
          : ListView.builder(
        itemCount: usageList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> usage = usageList[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('رقم العداد: ${usage['meterNumber']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المياه المستهلكة: ${usage['waterAmount']}'),
                  Text('المياه السابقة: ${usage['previousWaterAmount']}'),
                  Text('الدفع: ${usage['payment']}'),
                  Text('التاريخ: ${usage['date']}'),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await generatePDFReport(usageList);
        },
        child: Icon(Icons.print), // استخدام أيقونة الطباعة بدلاً من أيقونة PDF
      ),
    );
  }

  Future<void> generatePDFReport(List<Map<String, dynamic>> usageList) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text('تقرير الاستهلاك الشهري', textDirection: pw.TextDirection.rtl)),
          pw.ListView.builder(
            itemCount: usageList.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> usage = usageList[index];
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('رقم العداد: ${usage['meterNumber']}'),
                  pw.Text('المياه المستهلكة: ${usage['waterAmount']}'),
                  pw.Text('المياه السابقة: ${usage['previousWaterAmount']}'),
                  pw.Text('الدفع: ${usage['payment']}'),
                  pw.Text('التاريخ: ${usage['date']}'),
                  pw.Divider(),
                ],
              );
            },
          ),
        ],
      ),
    );

    final pdfData = await pdf.save(); // حفظ البيانات كملف PDF

    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData, // إرجاع بيانات PDF
    );
  }
}

void main() => runApp(MaterialApp(
  home: MonthlyReportPage(),
));


