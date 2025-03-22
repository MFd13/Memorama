import 'package:flutter/material.dart';
import 'package:memorama/config/config.dart';

class Botonera extends StatefulWidget {
  const Botonera({Key? key}) : super(key: key);

  @override
  _BotoneraState createState() => _BotoneraState();
}

class _BotoneraState extends State<Botonera> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: botones.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                      child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: botones[index].secondary!,
                        borderRadius:BorderRadius.circular(15),
                        boxShadow:<BoxShadow>[
                        BoxShadow(
                            blurRadius: 8,
                            color: Colors.black45,
                            offset: Offset(3, 4)
                        )
                    ]  ),
                    child: Center(
                      child: Text(botones[index].name!,
                          style: TextStyle(
                              color: botones[index].primary!,
                              fontFamily: "outfit thin",
                              fontStyle: FontStyle.italic,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                    color: botones[index].secondary!,
                                    offset: Offset(1, 1)),
                                Shadow(
                                    color: Colors.black26, offset: Offset(1, 1))
                              ])),
                    ),
                  ))),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => botones[index].goto!));
            },
          );
        },
      ),
    );
  }
}
