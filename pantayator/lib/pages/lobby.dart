import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pantayator/appdata.dart';
import 'package:provider/provider.dart';

class Lobby extends StatefulWidget {
  const Lobby({super.key});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  @override
  Widget build(BuildContext context) {
    //Per poder accedir-hi a la informació de la AppData
    AppData appData = Provider.of<AppData>(context);

    //Per poder controlar els TextFields
    final _ipTextController = TextEditingController();
    final _textController = TextEditingController();

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'Main Page',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                _createTextField("Missatge", "Hola Mundo", _textController),
                SizedBox(
                  height: 32,
                ),
                _createTextField(
                    "Conexió IP", "192.168.0.2x", _ipTextController),
                SizedBox(
                  height: 76,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Botó per connectar
                    Container(
                      width: 225,
                      child: CupertinoButton(
                        padding: EdgeInsets.all(5),
                        child: Text('Connectar'),
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        onPressed: () {
                          setState(() {
                            appData.ip = _ipTextController.text;
                            appData.connectServer();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    //Botó de enviar missatge, si esta connectat estará verd, si no vermell
                    Container(
                      width: 225,
                      child: CupertinoButton(
                          padding: EdgeInsets.all(5),
                          child: Text('Enviar Missatge'),
                          color: appData.connected
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.destructiveRed,
                          onPressed: () {
                            if (appData.connected == true) {
                              setState(() {
                                appData.text = _textController.text;
                                appData.showTextMessage();
                              });
                            }
                          }),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  //Amb aquesta funció creem un TextField i el seu titol
  Column _createTextField(
      String titol, String defaultText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          titol,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        SizedBox(
          height: 16,
        ),
        Container(
          width: 225,
          child: CupertinoTextField(
            decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 105, 105, 105)),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            padding: EdgeInsets.all(10),
            textAlign: TextAlign.left,
            placeholder: defaultText,
            controller: controller,
          ),
        ),
      ],
    );
  }
}
