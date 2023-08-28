import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class UserInfo {
  String nome;
  DateTime dataNascimento;
  String situacao;

  UserInfo({required this.nome, required this.dataNascimento, required this.situacao});

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'dataNascimento': dataNascimento.toIso8601String(),
      'situacao': situacao,
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Info App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserInfoPage(),
    );
  }
}

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _dataNascimentoController;
  String _situacao = "Empreendedor";

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _dataNascimentoController = TextEditingController();
  }

  Future<void> _saveUserInfo(UserInfo userInfo) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_info.json');
    final jsonStr = jsonEncode(userInfo.toJson());
    await file.writeAsString(jsonStr);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userInfo = UserInfo(
        nome: _nomeController.text,
        dataNascimento: DateTime.parse(_dataNascimentoController.text),
        situacao: _situacao,
      );
      _saveUserInfo(userInfo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informações salvas com sucesso!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dataNascimentoController,
                decoration: InputDecoration(labelText: 'Data de Nascimento (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma data de nascimento';
                  }
                  if (DateTime.tryParse(value) == null) {
                    return 'Insira uma data válida no formato YYYY-MM-DD';
                  }
                  return null;
                },
              ),
              DropdownButton<String>(
                value: _situacao,
                onChanged: (newValue) {
                  setState(() {
                    _situacao = newValue!;
                  });
                },
                items: <String>['Empreendedor', 'Empregado', 'Estagiário']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
