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
    return Center(
      child: Column(children: [
        const Text(
          "Personal Info",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(
          height: 50.0,
          child: TextField(
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
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: "Last name",
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController()
            ..text = ref.read(personalInfoProvider).lastName,
          onChanged: (value) => ref.read(personalInfoProvider.notifier).update(
              (state) => PersonalInfo(
                  state.firstName, value, state.number, state.venmo)),
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: "Number",
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController()
            ..text = ref.read(personalInfoProvider).number,
          onChanged: (value) => ref.read(personalInfoProvider.notifier).update(
              (state) => PersonalInfo(
                  state.firstName, state.lastName, value, state.venmo)),
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: "Venmo",
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController()
            ..text = ref.read(personalInfoProvider).venmo,
          onChanged: (value) => ref.read(personalInfoProvider.notifier).update(
              (state) => PersonalInfo(
                  state.firstName, state.lastName, state.venmo, value)),
        ),
      ]),
    );
  }

  Widget _personalInfo() {
    final user = ref.watch(personalInfoProvider);
    return Column(children: [
      const Text(
        "Personal Info",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      SizedBox(height: 50.0, child: Text(user.firstName)),
      SizedBox(height: 50.0, child: Text(user.lastName)),
      SizedBox(height: 50.0, child: Text(user.number)),
      SizedBox(height: 50.0, child: Text(user.venmo)),
    ]);
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
        child: Column(
      children: [
        editing ? _editPersonalInfo() : _personalInfo(),
        TextButton(
            onPressed: () {
              setState(() {
                editing = !editing;
              });
            },
            child: editing ? Text("Save info") : Text("Edit"))
      ],
    ));
  }
}
