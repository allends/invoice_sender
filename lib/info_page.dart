import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:invoice_sender/main.dart';

class InfoPage extends ConsumerStatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  InfoPageState createState() => InfoPageState();
}

class InfoPageState extends ConsumerState<InfoPage> {
  bool editing = false;

  Widget _editPersonalInfo() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Wrap(runSpacing: 5.0, children: [
            const Text(
              "Personal Info",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            TextField(
              enabled: editing,
              decoration: const InputDecoration(
                hintText: "First name",
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController()
                ..text = ref.read(personalInfoProvider).firstName,
              onChanged: (value) => ref
                  .read(personalInfoProvider.notifier)
                  .update((state) => PersonalInfo(
                      value, state.lastName, state.number, state.venmo)),
            ),
            TextField(
              enabled: editing,
              decoration: const InputDecoration(
                hintText: "Last name",
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController()
                ..text = ref.read(personalInfoProvider).lastName,
              onChanged: (value) => ref
                  .read(personalInfoProvider.notifier)
                  .update((state) => PersonalInfo(
                      state.firstName, value, state.number, state.venmo)),
            ),
            TextField(
              enabled: editing,
              decoration: const InputDecoration(
                hintText: "Venmo",
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController()
                ..text = ref.read(personalInfoProvider).number,
              onChanged: (value) => ref
                  .read(personalInfoProvider.notifier)
                  .update((state) => PersonalInfo(
                      state.firstName, state.lastName, value, state.venmo)),
            ),
            TextField(
              enabled: editing,
              decoration: const InputDecoration(
                hintText: "Number",
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController()
                ..text = ref.read(personalInfoProvider).venmo,
              onChanged: (value) => ref
                  .read(personalInfoProvider.notifier)
                  .update((state) => PersonalInfo(
                      state.firstName, state.lastName, state.number, value)),
            ),
          ]),
        ));
  }

  Widget _clientList() {
    final clients = ref.read(clientProvider);
    return Expanded(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Wrap(
              runSpacing: 5.0,
              direction: Axis.vertical,
              children: [
                const Text(
                  "Clients",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Wrap(
                  runSpacing: 5.0,
                  direction: Axis.vertical,
                  children:
                      clients.map((client) => Text(client.firstName)).toList(),
                )
              ],
            )));
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        _editPersonalInfo(),
        TextButton(
            onPressed: () {
              setState(() {
                editing = !editing;
              });
              Client client = Client("test", "test", "resr", "rest", []);
              ref.read(clientProvider).add(client);
            },
            child: editing ? const Text("Save info") : const Text("Edit")),
        _clientList(),
      ],
    );
  }
}
