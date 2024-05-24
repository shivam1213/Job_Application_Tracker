import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class EmailScanner extends StatefulWidget {
  @override
  _EmailScannerState createState() => _EmailScannerState();
}

class _EmailScannerState extends State<EmailScanner> {
  final String emailSubject = 'Your Subject Here';
  int emailCount = 0;
  DateTime selectedDate = DateTime.now(); // Default to today's date
  TextEditingController sentenceController = TextEditingController();

  Future<void> _openGmail() async {
    final Uri uri = Uri.parse('mailto:?subject=$emailSubject');
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Future<void> _scanEmails() async {
    final Email email = Email(
      subject: emailSubject,
      body: sentenceController.text,
    );
    await FlutterEmailSender.send(email);
    setState(() {
      emailCount++;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 33));
    setState(() {
      // Perform the refresh action here.
      emailCount = 0; // Example action: Reset email count
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _openGmail,
              child: const Text('Open Gmail'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Date: ${selectedDate.toString().substring(0, 10)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: sentenceController,
                decoration: const InputDecoration(
                  labelText: 'Enter the sentence to scan for',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanEmails,
              child: const Text('Scan Emails'),
            ),
            const SizedBox(height: 20),
            Text(
              'Emails with the specific sentence after selected date: $emailCount',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
