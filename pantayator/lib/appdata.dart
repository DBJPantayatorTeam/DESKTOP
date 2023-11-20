import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';

class AppData with ChangeNotifier {
  Random r = new Random();
  String ip = "";
  String text = "";
  String imageIn64Bytes = "";
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
  List<String> sortedMessageList = [];
  List<String> imageList = [];
  List<String> sortedImageList = [];

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
              _showLoginDialog(context);
              break;
            case 'login':
              data['value']
              ? _showSuccessLogin(context)
              : _showErrorLogin(context);
              break;
          }

          
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
    connected = true;
    notifyListeners();
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
                    disconnectedFromServer();
                  },
                  child: Text("No"),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showLoginDialog(context);
                  },
                  child: Text("Sí")
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
              SizedBox(height: 15,),
              CupertinoTextField(
                controller: userController,
                placeholder: "Usuari",
              ),
              SizedBox(height: 5,),
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
                disconnectedFromServer();
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

  //Mandar imatge per a que ho print
  void _sendImage() {
    if (!imageList.contains(imageIn64Bytes)) {
      imageList.add(imageIn64Bytes);
      notifyListeners(); 
    }

    final msn = {'type': 'image', 'value': imageIn64Bytes};
    _server?.sink.add(jsonEncode(msn));
    print("img ok");
    print(imageIn64Bytes);
    imageIn64Bytes = "";
  }

  // Seleccionar imatge
  Future<String?> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg'],
    );

    if (result != null) {
      return result.files.single.path;
    } else {
      return null;
    }
  }

  void getImageInBytes() async {
    String? imagePath = await pickImage();

    if (imagePath != null) {
      File imageFile = File(imagePath);

      List<int> imageBytesList = await imageFile.readAsBytes(); // Lee el contenido de la imagen como bytes
      String base64String = base64Encode(imageBytesList); // Convierte la lista de bytes a una cadena Base64
      imageIn64Bytes = base64String;

      _sendImage();

    } else {
      print('Selección de imagen cancelada');
    }

  }

  List<String> sortListByDate(List<String> ogList) {
    List<String> res = [];
    //Ordenara a la forma inversa (l'ultim de la llista paá a ser el primer)
    for (int i = ogList.length - 1; i > -1; i--) {
      res.add(ogList[i]);
    }
    return res;
  }


  Future<dynamic> showResendConfirmation(BuildContext context, String msg, bool isMessage) {
    return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text(isMessage ? "Reenviar missatge" : "Reenviar Imatge?"),
              content: isMessage 
                ? Text("Vols tornar a enviar el misatge:\n $msg")
                : decodeImage(msg),
              actions: [
                CupertinoDialogAction(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text("Sí"),
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

  decodeImage(String base64Image) {
    // Decodificar la imagen desde la cadena base64
    List<int> bytes = base64.decode(base64Image);
    Uint8List imageBytes = Uint8List.fromList(bytes);

    // Mostrar la imagen
    return Image.memory(imageBytes);
  }
}
