import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../widgets/botonera.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Memorama"),
        actions: <Widget>[
          IconButton(onPressed: () {
            if (Platform.isAndroid || Platform.isIOS){
              SystemNavigator.pop();
            }
            if (Platform.isLinux || Platform.isWindows){
              exit(0);
            }
          }, icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: const Botonera(),
    );
  }
}
