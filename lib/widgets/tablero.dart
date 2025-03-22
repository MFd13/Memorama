import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:memorama/config/config.dart';
import 'package:memorama/db/sqlite.dart';
import 'package:memorama/widgets/parrilla.dart';

import 'package:memorama/app/home.dart';
import 'package:memorama/db/data.dart';

class Tablero extends StatefulWidget {
  final Nivel? nivel;

  const Tablero(this.nivel, {super.key});

  @override
  TableroState createState() => TableroState();
}

class TableroState extends State<Tablero> {
  final GlobalKey<ParrillaState> pKey = GlobalKey();
  int segundos = 0;
  Data? info;
  Timer? timer;
  bool menuExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    movimientos = 0;
    startTimer();
    getData();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        segundos++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    _scrollController.dispose();
    super.dispose();
  }

  String formatTime(int segundos) {
    int minutes = segundos ~/ 60;
    int secs = segundos % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  void actMovimientos() {
    setState(() {});
  }

  void actPares() {
    setState(() {});
  }

  Future<void> getData() async {
    info = await Sqlite.find();
    setState(() {});
  }

  void showResult(context) async {
    Data? save = await Sqlite.find();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: ( context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Column(
            children: [
              Icon(Icons.verified_sharp, size: 50),
              SizedBox(height: 10),
              Text(
                "¡Lo lograste!",
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tienes todos los pares.\n"
                    "Movimientos: $movimientos\n"
                    "Tiempo: ${formatTime(segundos)}\n"
                    "Fecha: ${save?.fecha}\n"
                    "Hora: ${save?.hora}\n"
                    "Victorias: ${save?.wins}\n"
                    "Derrotas: ${save?.loses}",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
                child: Text("Salir", style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  void toggleSideMenu() {
    setState(() {
      menuExpanded = !menuExpanded;
    });
  }

  void reiniciar() async {
    bool confirmado = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Reiniciar partida"),
          content: Text("¿Estás seguro de reiniciar? Esto contará como una derrota."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      Data? save = await Sqlite.find();
      Data x = Data(
          id: 1,
          fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          hora: DateFormat('HH:mm:ss').format(DateTime.now()),
          wins: save!.wins,
          loses: save.loses! + 1
      );
      await Sqlite().update(x);
      debugPrint("Derrota contabilizada: ${x.toMap()}");

      segundos = 0;
      pKey.currentState?.reset();
      setState(() {});
    }
  }

  void newGame() async {
    reiniciar();
    Data? save = await Sqlite.find();
    Data x = Data(
        id: 1,
        fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        hora: DateFormat('HH:mm:ss').format(DateTime.now()),
        wins: save!.wins,
        loses: save.loses! + 1
    );
    await Sqlite().update(x);
    debugPrint("perdiste");
  }

  void salir() async {
    if (restantes < totales) {
      bool confirmado = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Salir de la partida"),
            content: Text("¿Estas seguro de salir? Esto contará como una derrota."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("Aceptar"),
              ),
            ],
          );
        },
      );

      if (confirmado == true) {
        Data? save = await Sqlite.find();
        Data x = Data(
            id: 1,
            fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            hora: DateFormat('HH:mm:ss').format(DateTime.now()),
            wins: save!.wins,
            loses: save.loses! + 1
        );
        await Sqlite().update(x);
        debugPrint("Derrota contabilizada: ${x.toMap()}");

        if (Platform.isAndroid || Platform.isIOS) {
          SystemNavigator.pop();
        }
        if (Platform.isLinux || Platform.isWindows) {
          exit(0);
        }
      }
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        SystemNavigator.pop();
      }
      if (Platform.isLinux || Platform.isWindows) {
        exit(0);
      }
    }
  }

  Future<void> confirm(BuildContext context, String message, Function onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Continuar'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_run),Text(" $movimientos "),
              Icon(Icons.hourglass_bottom),Text(" ${formatTime(segundos)} "),
              Icon(Icons.done),Text(" $totales/$restantes"),
            ],
          ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: toggleSideMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Parrilla(
                widget.nivel,
                actMovimientos,
                actPares,
                key: pKey,
                    () => showResult(context),
              ),
            ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            right: menuExpanded ? 0 : -175,
            top: 0,
            bottom: 0,
            child: Container(
              width: 175,
              color: Colors.grey,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text("Salir"),
                    onTap: () {
                      salir();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text("Reiniciar"),
                    onTap: () {
                      reiniciar();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.question_mark),
                    title: Text("Consultar"),
                    onTap: () {
                      confirm(context, "¿Seguro que deseas continuar?", () async {
                        await getData();
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              title: Text("Display de información"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.date_range_rounded),
                                    title: Text("Fecha"),
                                    subtitle: Text(info?.fecha.toString() ?? "Cargando"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.check_circle),
                                    title: Text("Victorias"),
                                    subtitle: Text(info?.wins.toString() ?? "Cargando"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.cancel),
                                    title: Text("Derrotas"),
                                    subtitle: Text(info?.loses.toString() ?? "Cargando"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.auto_awesome),
                    title: Text("Juego nuevo"),
                    onTap: () {
                      confirm(context, "¿Seguro que deseas continuar? Se marcará como juego perdido", newGame);
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.grey,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  salir();
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: reiniciar,
              ),
              IconButton(
                icon: Icon(Icons.auto_awesome),
                onPressed: newGame,
              ),
            ],
          )
      ),
    );
  }
}
