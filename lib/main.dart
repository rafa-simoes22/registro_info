import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class UserInformation {
  String name = "";
  DateTime birthDate;
  String situation = "";

  UserInformation({required this.name, required this.birthDate, required this.situation});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'situation': situation,
    };
  }

  factory UserInformation.fromJson(Map<String, dynamic> json) {
    return UserInformation(
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      situation: json['situation'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Information App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InformationInputPage(),
    );
  }
}

class InformationInputPage extends StatefulWidget {
  @override
  _InformationInputPageState createState() => _InformationInputPageState();
}

class _InformationInputPageState extends State<InformationInputPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserInformation _userInformation = UserInformation(name: "", birthDate: DateTime.now(), situation: "empreendedor");
  List<UserInformation> _userInformations = []; // Lista para armazenar todas as informações
  final List<String> _situationOptions = ["empreendedor", "empregado", "estagiário"];

  Future<void> _loadInformation() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/user_information.json';
    final file = File(filePath);

    if (await file.exists()) {
      final data = await file.readAsString();
      final List<dynamic> jsonList = json.decode(data);

      _userInformations = jsonList.map((json) => UserInformation.fromJson(json)).toList();
    }
  }

  Future<void> _saveInformation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/user_information.json';
      final file = File(filePath);

      _userInformations.add(_userInformation);

      final userInformationJsonList = _userInformations.map((info) => info.toJson()).toList();
      await file.writeAsString(json.encode(userInformationJsonList));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Informações salvas com sucesso!')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite um nome válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _userInformation.name = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Data de Nascimento (DD/MM/AAAA)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite uma data de nascimento válida';
                  }
                  // Implementar validação de data aqui
                  return null;
                },
                onSaved: (value) {
                  // Implementar conversão de texto para DateTime aqui
                  _userInformation.birthDate = DateTime.now();
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _userInformation.situation,
                onChanged: (value) {
                  setState(() {
                    _userInformation.situation = value!;
                  });
                },
                items: _situationOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Situação'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveInformation,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
