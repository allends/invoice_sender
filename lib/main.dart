import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import './invoice_sender.dart';
import './pages.dart';

final runningProvider = StateProvider((_) => false);
final personalInfoProvider = StateProvider((_) => PersonalInfo("", "", "", ""));
final clientProvider = StateNotifierProvider<ClientStateNotifier, List<Client>>(
    (ref) => ClientStateNotifier());

class PersonalInfo {
  String firstName;
  String lastName;
  String number;
  String venmo;

  PersonalInfo(this.firstName, this.lastName, this.number, this.venmo);
}

class Client extends PersonalInfo {
  List<Activity> invoiceList = [];

  Client(super.firstName, super.lastName, super.number, super.venmo,
      this.invoiceList);
}

class Activity {
  String description;
  String duration;

  Activity(this.description, this.duration);
}

class ClientStateNotifier extends StateNotifier<List<Client>> {
  ClientStateNotifier()
      : super([Client("firstName", "lastName", "number", "venmo", [])]);

  void add(Client client) {
    state = [...state, client];
  }

  void add_activity(Client client, Activity activity) {
    state = [
      for (final current in state)
        if (client != current)
          current
        else
          Client(client.firstName, client.lastName, client.number, client.venmo,
              [...client.invoiceList, activity]),
    ];
  }

  List<Activity> getActivities(Client client) {
    for (final current in state) {
      if (current == client) return current.invoiceList;
    }
    return [];
  }

  void remove(Client client) {
    state = [
      for (final current in state)
        if (client != current) current,
    ];
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Invoice Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const Pages(),
    );
  }
}
