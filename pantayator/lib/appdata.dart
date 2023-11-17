import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';

class AppData with ChangeNotifier {
  Random r = new Random();
  String ip = "";
  String text = "";
  bool connected = true;
  bool savingFile = false;
  String savePath = "";
  List<String> defaultMsnList = [
    "Hello World",
    "Ploure, prou plou, pero plou poc",
    "Bon dia",
    "Bona Tarda",
    "A cap cap hi cap lo que aquet cap hi cap",
    "Lo tapó té Tap, Tap i tapó, lo tapó té.",
  ];
  List<String> messageList = [];
  List<String> sortedList = [];

  //WebSocket
  IOWebSocketChannel? _server;

  void connectServer(BuildContext context) async {
    if (!connected) {
      _server = IOWebSocketChannel.connect("ws://$ip:8888");

      //Mandar missatge de la versió de la app que es
      _server?.sink.add('{"type":"connection", "version": "desktop"}');

      //Quan rep un missatge
      _server!.stream.listen(
        (message) {
          final data = jsonDecode(message);

          switch (data['type']) {
            case 'conexion':
              _showSuccessConnectionDialog(context);
              _showLoginDialog(context);
              break;
            case 'login':
              data['value']
              ? _showSuccessLogin(context)
              : _showLoginDialog(context);
              break;
          }

          connected = true;
          notifyListeners();
        },
        onError: (error) {
          //Si dona un error es reinicia tot
          connected = false;
          _showConnectionErrorDialog(context);
          notifyListeners();
        },
        onDone: () {
          //Quan el server es desconecta
          connected = false;
          notifyListeners();
        },
      );
    }
  }

  Future<dynamic> _showSuccessConnectionDialog(BuildContext context) {
    return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text("Success"),
              content: Text("S'ha conectat correctament"),
              actions: [
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  Future<dynamic> _showConnectionErrorDialog(BuildContext context) {
    return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text("Error"),
              content: Text("No s'ha pogut conectar correctament"),
              actions: [
                CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"))
              ],
            ),
        barrierDismissible: true);
  }

  Future<dynamic> _showSuccessLogin(BuildContext context) {
    return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text("Login correct"),
              content: Text("Usuari i contrasenya corrects"),
              actions: [
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  Future<dynamic> _showErrorLogin(BuildContext context) {
    return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text("Login incorrect"),
              content: Text("Usuari i contrasenya incorrects.\nVols tornar a intentar-ho"),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("NO"),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    _showLoginDialog(context);
                    Navigator.of(context).pop();
                  },
                  child: Text("SI")
                  ),
              ],
            ));
  }

  Future<dynamic> _showLoginDialog(BuildContext context) async {
    TextEditingController userController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return showCupertinoDialog(
      context: context, 
      builder: (BuildContext context){
        return CupertinoAlertDialog(
          title: Text("LogIn"),
          content: Column(
            children: [
              CupertinoTextField(
                controller: userController,
                placeholder: "Usuari",
              ),
              CupertinoTextField(
                controller: passwordController,
                placeholder: "Contrasenya",
                obscureText: true,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar")
            ),
            CupertinoDialogAction(
              onPressed: () {
                String user = userController.text;
                String psswd = passwordController.text;
                _server?.sink.add('{"type":"login", "user": "$user", "password":"$psswd"}');

                Navigator.of(context).pop();
              },
              child: Text("Acceptar")
            ),
          ],
        );
      },
    );
  }

  //Si es vol desconectar del server
  disconnectedFromServer() async {
    connected = false;
    notifyListeners();
    _server!.sink.close();
  }

  //Mandar missatge per a que ho print
  void showTextMessage() {
    //Si la llista no conté el missatge o afegirá
    if (!messageList.contains(text)) {
      messageList.add(text);
    }
    final msn = {'type': 'show', 'value': text};
    _server?.sink.add(jsonEncode(msn));
  }

  List<String> sortListByDate(List<String> ogList) {
    List<String> res = [];
    //Ordenara a la forma inversa (l'ultim de la llista paá a ser el primer)
    for (int i = ogList.length - 1; i > -1; i--) {
      res.add(ogList[i]);
    }
    return res;
  }


  Future<dynamic> showResendConfirmation(BuildContext context, String msg) {
    return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text("Reenviar missatge"),
              content: Text("Vols tornar a enviar el misatge:\n $msg"),
              actions: [
                CupertinoDialogAction(
                  child: Text("NO"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text("SÍ"),
                  onPressed: () {
                    _server?.sink.add('{"type":"show", "value":"$msg"}');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  //Funcions per guardar/llegir fitxers
  //Guardar Fitxer
  Future<void> saveFile() async {
    savingFile = true;
    String fileName = "msnSent.json";
    notifyListeners();

    final data = {'type': 'messageList', 'value': messageList};

    try {
      final dir = await getApplicationDocumentsDirectory();
      savePath = dir.path;
      final file = File('${dir.path}/$fileName');
      final jsonData = jsonEncode(data);
      await file.writeAsString(jsonData);
    } catch (e) {
      print("Error saving file: $e");
    } finally {
      savingFile = false;
      notifyListeners();
    }
  }
}
