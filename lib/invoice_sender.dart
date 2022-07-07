import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_sender/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class InvoiceSender extends ConsumerStatefulWidget {
  const InvoiceSender({Key? key}) : super(key: key);

  @override
  InvoiceSenderState createState() => InvoiceSenderState();
}

class InvoiceSenderState extends ConsumerState<InvoiceSender> {
  List<Activity> list = [];
  final TextEditingController myController = TextEditingController();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(); // Create instance.

  // Executed when the widget is added to the widget tree
  @override
  void initState() {
    super.initState();
  }

  // Executed when the widget is removed from the widget tree
  @override
  void dispose() async {
    super.dispose();
    ref.read(runningProvider);
    await _stopWatchTimer.dispose();
  }

  // Start the timer
  void startTimer() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    ref.read(runningProvider.notifier).update((state) => true);
  }

  // Stop the timer (can be resumed)
  void stopTimer() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    ref.read(runningProvider.notifier).update((state) => false);
  }

  // End the current Activity
  void endActivity() {
    final value = _stopWatchTimer.rawTime.value;
    final displayTime = StopWatchTimer.getDisplayTime(value, hours: true);
    final newActivity = Activity(myController.text, displayTime);
    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
    ref.read(runningProvider.notifier).update((state) => false);
    setState(() {
      list.add(newActivity);
      myController.text = "";
    });
  }

  // Generate a PDF
  // Get the current selected user's info
  // name
  // number
  // venmo
  // list of billable activities
  // Generate the PDF based on those values https://www.youtube.com/watch?v=z_5xkhEkc5Y
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

  Widget _buildUI() {
    final running = ref.watch(runningProvider);
    final clients = ref.watch(clientProvider);
    String selected = clients.first.firstName;
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
                StreamBuilder<int>(
                  stream: _stopWatchTimer.rawTime,
                  initialData: _stopWatchTimer.rawTime.value,
                  builder: (context, snap) {
                    final value = snap.data!;
                    final displayTime =
                        StopWatchTimer.getDisplayTime(value, hours: true);

                    return Column(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    displayTime.toString(),
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    );
                  },
                ),
                OutlinedButton(
                  onPressed: () {
                    running ? stopTimer() : startTimer();
                  },
                  child: Text(
                    running ? "Pause" : "Start",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  endActivity();
                },
                child: const Text(
                  "End Activity",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  generatePDF();
                },
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
          DropdownButton<String>(
              value: selected,
              items: ref
                  .watch(clientProvider)
                  .map((e) => DropdownMenuItem<String>(
                        value: e.firstName,
                        child: Text(e.firstName),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  selected = newValue!;
                });
              }),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(child: _buildUI()),
        const Divider(),
        Expanded(
            child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, index) => ListTile(
                      title: Text(list[index].description),
                      trailing: Text(list[index].duration),
                    )))
      ],
    );
  }
}
