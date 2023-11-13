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
  bool connected = false;
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

  void connectServer() async {
    _server = IOWebSocketChannel.connect("ws://$ip:8888");

    //Mandar missatge de la versió de la app que es
    _server?.sink.add('{"type":"connection", "version": "desktop"}');

    //Quan rep un missatge
    _server!.stream.listen((message) {
      final data = jsonDecode(message);

      /*
       * Aqui que fer amb els missatges que rep
       */

      connected = true;
      notifyListeners();
    }, onError: (error) {
      //Si dona un error es reinicia tot
      connected = false;
      notifyListeners();
    }, onDone: () {
      //Quan el server es desconecta
      connected = false;
      notifyListeners();
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
