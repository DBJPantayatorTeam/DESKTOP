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
  @override
  Widget build(BuildContext context) {
    //Per poder accedir-hi a la informació de la AppData
    AppData appData = Provider.of<AppData>(context);

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          //Botó per tornar a la pagina anterior
          leading: GestureDetector(
            child: Container(
              child: Icon(CupertinoIcons.back),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 55,),
              Text('Message'),
              Divider(),                                        //Per fer una linea que dividira el titol dels missatges
              Expanded(
                child: ListView.builder(                                 //Creara un container amb text per missatge
                  itemCount: appData.messageList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Text("${appData.messageList[index]}")
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
