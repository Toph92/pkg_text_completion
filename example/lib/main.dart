import 'package:flutter/material.dart';

import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:pkg_text_completion/controler.dart';
import 'package:pkg_text_completion/text_completion.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController prenomCtrl = TextEditingController();
  late TextCompletionControler<User> txtCompletionCtrl;

  @override
  void initState() {
    txtCompletionCtrl = TextCompletionControler<User>(
      dataSource: users,
      onUpdate: <Object>(user) {
        user = user as User;
        print(user.firstName);
        txtCompletionCtrl.value = user.lastName;
        prenomCtrl.text = user.firstName ?? "";
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 120,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 200,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextCompletion(
                            labelText: "Employé",
                            hintText: "Nom ou prénom",
                            controler: txtCompletionCtrl,
                            minCharacterNeeded: 2,
                            listWidth: 300,
                            listHeight: 200,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SizedBox(
                            width: 200,
                            child: TextField(
                              controller: prenomCtrl,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          txtCompletionCtrl.dataSource.addAll(
                              List<User>.generate(
                                  1000,
                                  (index) => User(
                                      firstName: lorem(paragraphs: 1, words: 1),
                                      lastName: lorem(paragraphs: 1, words: 1)
                                          .toUpperCase())));
                        },
                        child: const Text("Add 1000 users")),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}

List<User> users = [
  User(lastName: 'Père', firstName: 'Noël'),
  User(lastName: 'Père', firstName: 'Noel'),
  User(lastName: 'Père', firstName: 'NOEL'),
  User(lastName: 'Père', firstName: 'NOËL'),
  User(lastName: 'DESBOIS', firstName: 'Christophe'),
  User(lastName: 'DESBOIS', firstName: 'Maxime'),
  User(lastName: 'DAUTREMAY', firstName: 'Christelle'),
  User(lastName: 'LE DUC', firstName: 'Xenus'),
  User(lastName: 'DUPONT', firstName: 'Albert'),
  User(lastName: 'DURAND', firstName: 'Pierre-Henri'),
  User(lastName: 'DEBUS', firstName: 'Fabrice'),
  User(lastName: 'GIBOULOT', firstName: 'Xavier'),
  User(lastName: 'VEYRET', firstName: 'Pascal'),
  User(lastName: 'VEYRET', firstName: 'Maxime'),
  User(lastName: 'LEGLAND sans prénom'),
  User(lastName: 'Desbois', firstName: 'élodie'),
];

class User extends SearchEntry {
  final String? firstName;
  final String lastName;

  final String? firstNameF;
  String? lastNameF; // F comme filtred :) En majuscule sans accent en fait

  User({
    required this.lastName,
    this.firstName,
  })  : firstNameF = firstName?.removeAccents().toUpperCase(),
        lastNameF = lastName.removeAccents().toUpperCase(),
        super(
          sText: lastName + (firstName ?? ''),
        );

  String coucou() => "coucou";

  @override
  String toString() {
    return "$lastName $firstName";
  }

  @override
  Widget title(TextCompletionControler controler) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
              children: controler.hightLightText(
            lastName,
          )),
        ),
        Expanded(
          flex: 1,
          child: Row(children: controler.hightLightText(firstName ?? '')),
        ),
      ],
    );
  }
}

class Titi {
  String firstName = "";
}