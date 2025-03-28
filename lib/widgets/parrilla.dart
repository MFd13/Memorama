import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memorama/db/sqlite.dart';
import 'package:memorama/config/config.dart';
import 'package:flip_card/flip_card.dart';

import 'package:memorama/db/data.dart';

class Parrilla extends StatefulWidget {
  final Nivel? nivel;
  final VoidCallback actMovimientos, actPares, showResult;

  const Parrilla(this.nivel, this.actMovimientos(), this.actPares(), this.showResult, {super.key});

  @override
  ParrillaState createState() => ParrillaState();
}

class ParrillaState extends State<Parrilla> {
  int? prevclicked;

  bool? flag, habilitado;

  @override
  void initState() {
    super.initState();
    controls = [];
    card = [];
    state = [];
    barajar(widget.nivel!);
    prevclicked = -1;
    flag = false;
    habilitado = false;
    switch (widget.nivel!) {
      case Nivel.facil:
        totales = 8;
        break;
      case Nivel.medio:
        totales = 12;
        break;
      case Nivel.dificil:
        totales = 16;
        break;
      case Nivel.imposible:
        totales = 18;
        break;
    }
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        for (int i = 0; i < card.length; i++) {
          controls[i].toggleCard();
        }
        habilitado = true;
      });
    });
  }

  Future<bool> checkWin() async {
    bool tmp = false;
    if (totales == restantes) {
      Data? save = await Sqlite.find();
      tmp = !tmp;
      Data x = Data(
          id: 1,
          fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          hora: DateFormat('HH:mm:ss').format(DateTime.now()),
          wins: save!.wins! + 1,
          loses: save.loses
      );
      await Sqlite().update(x);
      debugPrint("Hora guardada: ${x.hora}");
    }
    return tmp;
  }

  void reset() {
    setState(() {
      for (int i = 0; i < card.length; i++) {
        if (!state[i]) {
          controls[i].toggleCard();
          state[i] = true;
        }
      }
      prevclicked = -1;
      flag = false;
      habilitado = false;
      movimientos = 0;
      restantes = 0;
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        habilitado = true;
      });
    });
  }

  void handleLastPair() async {
    if (widget.nivel == Nivel.facil) {
      await Future.delayed(Duration(seconds: 1), () {
        for (int i = 0; i < card.length; i++) {
          if (state[i]) {
            controls[i].toggleCard();
            state[i] = false;
          }
        }
        widget.showResult();
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Último par"),
            content: Text("¿Deseas voltear el último par?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  for (int i = 0; i < card.length; i++) {
                    if (state[i]) {
                      controls[i].toggleCard();
                      state[i] = false;
                    }
                  }
                  widget.showResult();
                },
                child: Text("Sí"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: card.length,
      shrinkWrap: true,
      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (context, index) {
        return FlipCard(
            onFlip: () async {
              if (!habilitado!) return;
              setState(() {
                habilitado = false;
              });
              if (!flag!) {
                prevclicked = index;
                state[index] = false;
                ++movimientos;
                widget.actMovimientos();
                debugPrint("movimientos: $movimientos");
              } else {
                setState(() {
                  habilitado = false;
                });
              }
              flag = !flag!;
              state[index] = false;

              if (prevclicked != index && !flag!) {
                if (card.elementAt(index) == card.elementAt(prevclicked!)) {
                  debugPrint("clicked:Son iguales");
                  ++movimientos;
                  ++restantes;
                  if (await checkWin()) {
                    widget.showResult();
                    restantes = 0;
                  }
                  widget.actMovimientos();
                  widget.actPares();
                  debugPrint("movimientos: $movimientos");
                  setState(() {
                    habilitado = true;
                  });

                  if (totales - restantes == 1) {
                    handleLastPair();
                  }
                } else {
                  Future.delayed(
                    Duration(seconds: 1),
                        () {
                      controls.elementAt(prevclicked!).toggleCard();
                      state[prevclicked!] = true;
                      prevclicked = index;
                      controls.elementAt(index).toggleCard();
                      state[index] = true;
                      setState(() {
                        habilitado = true;
                      });
                    },
                  );
                }
              } else {
                setState(() {
                  habilitado = true;
                });
              }
            },
            fill: Fill.fillBack,
            controller: controls[index],
            flipOnTouch: habilitado! ? state.elementAt(index) : false,
            back: Image.asset("images/quest.png"),
            front: Image.asset(card[index]));
      },
    );
  }
}