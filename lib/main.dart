import 'package:flutter/material.dart';
import './invoice_sender.dart';

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
