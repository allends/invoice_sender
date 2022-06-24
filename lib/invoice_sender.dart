import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';

class Activity {
  String? description;
  Duration? duration;

  Activity(this.description, this.duration);
}

class InvoiceSender extends StatefulWidget {
  @override
  InvoiceSenderState createState() => InvoiceSenderState();
}

class InvoiceSenderState extends State<InvoiceSender> {
  List<Activity> list = [];
  Duration duration = Duration();
  Timer? timer;
  bool running = false;
  final TextEditingController myController = TextEditingController();

  // Executed when the widget is added to the widget tree
  @override
  void initState() {
    super.initState();
  }

  // Executed when the widget is removed from the widget tree
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  // Incrementing the counter by 1 second
  void addTime() {
    const addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  // Start the timer
  void startTimer() {
    setState(() {
      running = true;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  // Stop the timer (can be resumed)
  void stopTimer() {
    setState(() {
      running = false;
    });
    timer?.cancel();
  }

  // Wrapper around start and stop to toggle
  void toggleTimer() {
    if (running) {
      stopTimer();
    } else {
      startTimer();
    }
  }

  // Used to reset the timer
  void resetTimer() {
    stopTimer();
    setState(() {
      duration = Duration();
      running = false;
      myController.text = "";
    });
  }

  // End the current Activity
  void endActivity() {
    // Add the activity to the list of activites and use the duration
    if (duration.inSeconds > 0 && myController.text != "") {
      final activity = Activity(myController.text, duration);
      list.add(activity);
      resetTimer();
    }
  }

  // Generate a PDF
  Future<void> generatePDF() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Text('Invoice',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)));
        }));
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            cellAlignment: pw.Alignment.center,
            data: List<List<String>>.generate(
              list.length,
              (row) => List<String>.generate(
                2,
                (col) => col == 0
                    ? '${list[row].description}'
                    : '${list[row].duration}',
              ),
            ),
          );
        }));
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final file = File("${tempPath}/invoice.pdf");
    await file.writeAsBytes(await pdf.save());
    Share.shareFiles([file.path], text: 'Invoice');
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  Widget _buildUI() {
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 250,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: myController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'What did you work on?',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    toggleTimer();
                  },
                  child: Text(
                    running ? "Pause" : "Start",
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              endActivity();
            },
            child: const Text(
              "End Activity",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              generatePDF();
            },
            child: const Text(
              "Export PDF",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Invoice Demo")),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(child: _buildUI()),
            const Divider(),
            Expanded(
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, index) => ListTile(
                          title: Text('${list[index].description}'),
                          trailing: Text('${list[index].duration}'),
                        )))
          ],
        ));
  }
}
