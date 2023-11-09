import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';

class AppData with ChangeNotifier {
  String ip = "";
  String text = "";
  bool connected = false;
  List<String> messageList = ["Hola","Adios"];

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
    });
  }

  //Si es vol desconectar del server
  disconnectedFromServer() async {
    connected = false;
    notifyListeners();

    _server!.sink.close();
  }

  //Mandar missatge per a que ho print
  void showTextMessage() {
    final msn = {'type': 'show', 'value': text};
    _server?.sink.add(jsonEncode(msn));
  }
}
