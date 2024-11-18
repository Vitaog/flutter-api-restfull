import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD API',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CrudApiPage(),
    );
  }
}

class CrudApiPage extends StatefulWidget {
  const CrudApiPage({Key? key}) : super(key: key);

  @override
  State<CrudApiPage> createState() => _CrudApiPageState();
}

class _CrudApiPageState extends State<CrudApiPage> {
  final _idController = TextEditingController(text: '0');
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();

  List<Map<String, dynamic>> _tableData = [];

  final String apiUrl = "http://localhost/api/testeApi.php/cliente";

  Future<void> _get() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/list"));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is List) {
          setState(() {
            _tableData = body.cast<Map<String, dynamic>>();
          });
        } else {
          setState(() {
            _tableData = [];
          });
        }
      } else {
        throw Exception("Erro ao carregar dados.");
      }
    } catch (error) {
      print("Erro ao executar GET: $error");
    }
  }

  Future<void> _post() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nome": _nomeController.text,
          "categoria": _categoriaController.text,
        }),
      );
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Erro ao cadastrar.")),
      );
      _get();
    } catch (error) {
      print("Erro ao executar POST: $error");
    }
  }

  Future<void> _put() async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/${_idController.text}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nome": _nomeController.text,
          "categoria": _categoriaController.text,
        }),
      );
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Erro ao alterar.")),
      );
      _get();
    } catch (error) {
      print("Erro ao executar PUT: $error");
    }
  }

  Future<void> _delete() async {
    try {
      final response =
          await http.delete(Uri.parse("$apiUrl/${_idController.text}"));
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Erro ao excluir.")),
      );
      _idController.clear();
      _nomeController.clear();
      _categoriaController.clear();
      await _get();
    } catch (error) {
      print("Erro ao executar DELETE: $error");
    }
  }

  void _selectRow(Map<String, dynamic> row) {
    setState(() {
      _idController.text = row["id"].toString();
      _nomeController.text = row["nome"];
      _categoriaController.text = row["categoria"];
    });
  }

  @override
  void initState() {
    super.initState();
    _get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CRUD API")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Id"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoriaController,
              decoration: const InputDecoration(labelText: "Categoria"),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _get, child: const Text("GET")),
                ElevatedButton(onPressed: _post, child: const Text("POST")),
                ElevatedButton(onPressed: _put, child: const Text("PUT")),
                ElevatedButton(onPressed: _delete, child: const Text("DELETE")),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tableData.isEmpty
                  ? const Center(child: Text("Nenhum dado encontrado."))
                  : ListView(
                      children: _tableData.map((row) {
                        return ListTile(
                          title: Text(row["nome"]),
                          subtitle: Text("Categoria: ${row["categoria"]}"),
                          onTap: () => _selectRow(row),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
