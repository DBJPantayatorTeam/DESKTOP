import 'package:flutter/cupertino.dart';
import 'package:pantayator/appdata.dart';
import 'package:provider/provider.dart';
import 'package:pantayator/pages/lobby.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.light, // Establece el tema claro por defecto.
      ),
      debugShowCheckedModeBanner: false,
      title: 'Crazy Display',
      home: Lobby(),
    );
  }
}
