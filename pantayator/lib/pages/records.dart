import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pantayator/appdata.dart';
import 'package:provider/provider.dart';

class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  bool misatges = true;
  @override
  Widget build(BuildContext context) {
    //Per poder accedir-hi a la informació de la AppData
    AppData appData = Provider.of<AppData>(context);

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          //Botó per tornar a la pagina anterior
          middle: Text('Records'),
          leading: GestureDetector(
            child: Container(
              child: Icon(CupertinoIcons.back),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          trailing: GestureDetector(
            child: Container(
              child: Icon(CupertinoIcons.arrow_down_doc),
            ),
            onTap: () {
              appData.saveFile();
              showCupertinoDialog(
                context: context,
                builder: (_) => _saveAlertDialoge(appData),
                barrierDismissible: true,
              );
            },
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        misatges = !misatges;
                      });
                    },
                    child: Icon(misatges ? CupertinoIcons.photo : CupertinoIcons.captions_bubble),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                misatges ? 'Últims Missatges' : 'Últimes Imatges',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                child: Divider(
                  thickness: 2,
                ), //Per fer una linea que dividira el titol dels missatges
                width: 400,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2.5,
                height: MediaQuery.of(context).size.height - 200,
                child: ListView.builder(
                  //Creara un container amb text per missatge
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  scrollDirection: Axis.vertical,
                  itemCount: appData.sortedList.length,
                  itemBuilder: (context, index) {
                    bool isEven = index % 2 == 0;
                    return GestureDetector(
                      child: Container(
                        color: isEven
                            ? Color.fromARGB(255, 218, 218, 218)
                            : Colors.transparent,
                        constraints: BoxConstraints(minHeight: 30),
                        alignment: Alignment.center,
                        child: misatges
                            ? Text("${appData.sortedList[index]}")
                            : string64ToImage(appData.imageList[0]),
                      ),
                      onTap: () {
                          appData.showResendConfirmation(context, appData.sortedList[index]);
                        },
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget string64ToImage(String base64String) {
    // Decodificar el String base64 a bytes
    Uint8List bytes = base64.decode(base64String);

    // Crear un objeto Image.memory con los bytes decodificados
    Image image = Image.memory(bytes);

    return image;
  }

  CupertinoAlertDialog _saveAlertDialoge(AppData appData) {
    return CupertinoAlertDialog(
      title: Text('Missatges guardats!'),
      content: Text('Fitxer guardat en ${appData.savePath}'),
      actions: [CupertinoDialogAction(child: Text('Ok'), onPressed: () => Navigator.of(context).pop(),)],
    );
  }
}
