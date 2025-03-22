import 'package:flutter/material.dart';

import 'home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Memorama",
      theme: ThemeData(
          fontFamily: "outfit",
          primarySwatch: Colors.grey,
          useMaterial3: true),
      initialRoute: "home",
      routes: {
        "home": (BuildContext context) => Home(),
        },
    );
  }
}
