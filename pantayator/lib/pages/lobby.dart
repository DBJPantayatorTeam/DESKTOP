import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Lobby extends StatefulWidget {
  const Lobby({super.key});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: 50,),
                _createTextField("Missatge", "Hola Mundo"),
                SizedBox(height: 32,),
                _createTextField("Conexió IP", "192.168.0.2x"),
                SizedBox(height: 56,),
                CupertinoButton(
                  child: Text('Connectar'), 
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  onPressed:() {
                  
                  },
                )
              ],
            ),
          ),
        ));
  }

  Column _createTextField(String titol, String defaultText) {
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
            padding: EdgeInsets.all(10),
            textAlign: TextAlign.left,
            placeholder: defaultText,
          ),
        ),
      ],
    );
  }
}
