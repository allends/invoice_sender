import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: InvoiceSender(),
    );
  }
}

class InvoiceSender extends StatefulWidget {
  @override
  InvoiceSenderState createState() => InvoiceSenderState();
}

class InvoiceSenderState extends State<InvoiceSender> {
  Duration duration = Duration();
  Timer? timer;
  var running = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    running = true;
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer() {
    running = false;
    timer?.cancel();
  }

  Widget _buildUI() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return ListTile(
      title: Text(
        '$minutes:$seconds',
        style: TextStyle(fontSize: 24),
      ),
      trailing: Icon(running ? Icons.pause : Icons.play_arrow),
      onTap: () {
        if (running) {
          stopTimer();
        } else {
          startTimer();
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Invoice Demo")),
      body: Center(child: _buildUI()),
    );
  }
}
