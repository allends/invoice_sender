import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import './invoice_sender.dart';
import './pages.dart';

final runningProvider = StateProvider((_) => false);
final personalInfoProvider =
    StateProvider((_) => PersonalInfo("Allen", "", "", ""));

class PersonalInfo {
  String firstName = "";
  String lastName = "";
  String number = "";
  String venmo = "";

  PersonalInfo(this.firstName, this.lastName, this.number, this.venmo);
}

class Activity {
  String description;
  String duration;

  Activity(this.description, this.duration);
}

class Client {
  String firstName;
  String lastName;
  String number;

  Client(this.firstName, this.lastName, this.number);
}

class ClientStateNotifier extends StateNotifier<List<Client>> {
  ClientStateNotifier() : super([]);

  void add(Client client) {
    state = [...state, client];
  }

  void remove(Client client) {
    state = [
      for (final current in state)
        if (client != current) current,
    ];
  }
}

final ClientProvider = StateNotifierProvider((ref) => ClientStateNotifier());

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Invoice Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const Pages(),
    );
  }
}
