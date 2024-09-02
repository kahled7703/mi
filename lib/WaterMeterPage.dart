
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'dart:async';

class SentMessagesPage extends StatefulWidget {
  @override
  _SentMessagesPageState createState() => _SentMessagesPageState();
}

class _SentMessagesPageState extends State<SentMessagesPage> {
  List<SmsMessage> sentMessages = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start fetching messages immediately
    fetchSentMessages();

    // Schedule periodic fetching every 30 seconds (adjust as needed)
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchSentMessages();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  Future<void> fetchSentMessages() async {
    try {
      final SmsQuery query = SmsQuery();
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.sent],
      );
      setState(() {
        sentMessages = messages;
      });
    } catch (e) {
      print('Error fetching sent messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الرسائل الصادرة'),
      ),
      body: ListView.builder(
        itemCount: sentMessages.length,
        itemBuilder: (context, index) {
          SmsMessage message = sentMessages[index];
          return ListTile(
            title: Text('رقم الهاتف: ${message.address}'),
            subtitle: Text('النص: ${message.body}'),
            trailing: Text('تاريخ: ${message.date}'),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SentMessagesPage(),
  ));
}



