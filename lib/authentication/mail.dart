import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';


class Mail extends StatefulWidget {
  const Mail({super.key});


  @override
  State<Mail> createState() => _MailState();
}


class _MailState extends State<Mail> {
  final outlookStmp =
      hotmail(dotenv.env["OUTLOOJ_EMAIL"]!, dotenv.env["OUTLOOJ_PASSWORD"]!);


  sendMailFromOutlook() async {
    final message = Message()
      ..from = Address(dotenv.env["OUTLOOJ_EMAIL"]!, 'Confirmation')
      ..recipients.add('ozaatreh10@gmail.com')
      ..subject = 'Test Dart Mailer library }'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.';
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";


    try {
      final sendReport = await send(message, outlookStmp);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("send email"),
      ),
      body: ElevatedButton(
        child: Text("send mail"),
        onPressed: () {
          sendMailFromOutlook();
        },
      ),
    );
  }
}
