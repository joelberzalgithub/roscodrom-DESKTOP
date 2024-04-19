import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto/printaDicc.dart';
import 'package:proyecto/utils_websockets.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // Aquí desactivas la etiqueta de debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: ' '),
      routes: {
        '/second': (context) => SecondPage(),
      },
    );
  }
}


class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Roscòdrom',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {


                Navigator.pushNamed(context, '/second');
              },
              child: Text('Iniciar'),
            ),
          ],
        ),
      ),
    );
  }
}
