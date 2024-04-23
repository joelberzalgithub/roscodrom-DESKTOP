import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/utils_websockets.dart';
import 'package:http/http.dart' as http;

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String selectedText = 'Seleccionar idioma';
  String rutaArchivo = 'data/dicc.txt';
  List<String> Idiomas=["catalan", "español"];
  List<String> listaDePalabras = [];
  late ScrollController _scrollController;
  int paginaActual = 1;
  String url ='https://roscodrom5.ieti.site/';
  @override
  void initState() {
    super.initState();
    // Inicializa el ScrollController antes de utilizarlo
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              _showTextSelectionDialog(context);
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  selectedText,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 200,
                // Asocia el ScrollController solo al ListView
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: listaDePalabras.length, // Número de elementos en la lista
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(latin1.decode(listaDePalabras[index].runes.toList())),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _handlePrevious,
                child: Text('Anterior'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _handleNext,
                child: Text('Siguiente'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    paginaActual+=1;
    String url="https://roscodrom5.ieti.site/api/words/$selectedText?page=$paginaActual&size=20";
    String Dicc_recibido_bruto=await CURL(url);
    List<String> nuevaLista=[];
    var jsonList = json.decode(Dicc_recibido_bruto);
    for (Map<String, dynamic> ele in jsonList){
      nuevaLista.add(ele["word"]);
    }
    //print(nuevaLista.toString());

    setState(() {
      listaDePalabras = nuevaLista;
    });
  }

  Future<void> _handlePrevious() async {
    if (paginaActual!=1){
      paginaActual-=1;
      String url="https://roscodrom5.ieti.site/api/words/$selectedText?page=$paginaActual&size=20";
      String Dicc_recibido_bruto=await CURL(url);
      List<String> nuevaLista=[];
      var jsonList = json.decode(Dicc_recibido_bruto);
      for (Map<String, dynamic> ele in jsonList){
        nuevaLista.add(ele["word"]);
      }
      //print(nuevaLista.toString());

      setState(() {
        listaDePalabras = nuevaLista;
      });
    }

  }

  Future<void> _showTextSelectionDialog(BuildContext context) async {
    String? newText = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleccionar idioma"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildTextOptions(Idiomas),
          ),
        );
      },
    );

    if (newText != null) {
      var servidorIP='192.168.0.103';
      var puerto='3000';

      String url="https://roscodrom5.ieti.site/api/words/$newText?page=1&size=20";
      String Dicc_recibido_bruto=await CURL(url);
      var jsonList = json.decode(Dicc_recibido_bruto);
      for (Map<String, dynamic> ele in jsonList){
          listaDePalabras.add(ele["word"]);
      }
      //print(listaDePalabras.toString());

      setState(() {
        selectedText = newText;
      });
    }
  }

  List<Widget> _buildTextOptions(List<String> idiomas) {
    List<Widget> options = [];
    for (var idioma in idiomas) {
      options.add(_buildTextOption(idioma));
    }
    return options;
  }

  Widget _buildTextOption(String idioma) {
    return ListTile(
      title: Text(idioma),
      onTap: () {
        Navigator.of(context).pop(idioma);
      },
    );
  }

  Future<List<String>> leerArchivo(String ruta) async {
    try {
      // Lee el archivo
      File archivo = File(ruta);
      String contenido = await archivo.readAsString();

      // Divide el contenido del archivo por líneas y elimina las líneas vacías
      List<String> lineas = contenido.split('\n').where((linea) => linea.isNotEmpty).toList();

      return lineas;
    } catch (e) {
      print("Error al leer el archivo: $e");
      return [];
    }
  }

  @override
  void dispose() {
    // Dispose el ScrollController cuando el widget se elimine
    _scrollController.dispose();
    super.dispose();
  }


  Future<String> HTTPenviarTexto(String url, String text) async {
    try {
      // Crear la solicitud POST
      var request = http.Request('POST', Uri.parse(url));

      // Configurar el encabezado y el cuerpo de la solicitud
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'data': text});

      // Enviar la solicitud y esperar la respuesta
      var response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        // La solicitud ha sido exitosa
        var responseData = await response.stream.toBytes();
        var responseString = utf8.decode(responseData);
        return responseString;
      } else {
        // La solicitud ha fallado
        throw Exception("Error del servidor: ${response.reasonPhrase}");
      }
    } catch (error) {
      // Manejar errores en la solicitud
      throw Exception("Error al enviar la solicitud: $error");
    }
  }

  Future<String> CURL(String url) async {
    try {
      // Realizar la solicitud GET utilizando la librería http
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Si la solicitud es exitosa, devolver el cuerpo de la respuesta
        return response.body;
      } else {
        // Si la solicitud falla, lanzar una excepción con el mensaje de error
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar errores generales
      throw Exception('Error al hacer la solicitud: $e');
    }
  }

}
