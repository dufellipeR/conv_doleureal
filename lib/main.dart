import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=bc3fd746";

void main() async {
  print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolController = TextEditingController();
  final eurController = TextEditingController();

  double dolar;
  double euro;

  void _realchanged(String text) {
    double real = double.parse(text);
    dolController.text = (real/dolar).toStringAsFixed(2);
    eurController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolchanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    eurController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _eurchanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro ).toStringAsFixed(2);
    dolController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text("\$ Conversor de Moedas \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                      'Carregando Dados',
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'Erro, verifique sua conexão! ',
                        style: TextStyle(color: Colors.amber, fontSize: 25),
                        textAlign: TextAlign.center
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.attach_money, size: 150.0,
                          color: Colors.amber,),
                        buildTextField("Reais", "R", realController, _realchanged),
                        Divider(),
                        buildTextField("Dólares", "US", dolController, _dolchanged),
                        Divider(),
                        buildTextField("Euros", "EUR", eurController, _eurchanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f) {
  return TextField(

    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix + "\$",
    ),
    style: TextStyle(
      color: Colors.amber, fontSize: 25,
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
