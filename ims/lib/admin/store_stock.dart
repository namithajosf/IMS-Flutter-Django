import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoreStocksPage extends StatefulWidget {
  const StoreStocksPage({Key? key}) : super(key: key);

  @override
  StoreStocksPageState createState() => StoreStocksPageState();
}

class StoreStocksPageState extends State<StoreStocksPage> {
  List data = [];

  Future<List> getData() async {
    try {
      var response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/stocks/'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        print('Success');
        return data;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    getData().then((value) {
      setState(() {
        data = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                data = [];
              });
              getData().then((value) {
                setState(() {
                  data = value;
                });
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Store Name')),
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Last Updated')),
            DataColumn(label: Text('Edit')),
          ],
          rows: data
              .map((item) => DataRow(cells: [
                    DataCell(Text(item['id'].toString())),
                    DataCell(Text(item['store'])),
                    DataCell(Text(item['product'])),
                    DataCell(Text(item['store_stock'].toString())),
                    DataCell(Text(item['date'].toString())),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditStockPage(
                                stock: item,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}

class EditStockPage extends StatefulWidget {
  final dynamic stock;

  const EditStockPage({Key? key, required this.stock}) : super(key: key);

  @override
  EditStockPageState createState() => EditStockPageState();
}

class EditStockPageState extends State<EditStockPage> {
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _stockController =
        TextEditingController(text: widget.stock['store_stock'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Store: ${widget.stock['store']}'),
            Text('Product: ${widget.stock['product']}'),
            const SizedBox(height: 16.0),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: 400,
              child: ElevatedButton(
                onPressed: () {
                  int newStock = int.tryParse(_stockController.text) ?? 0;
                  widget.stock['store_stock'] = newStock;
                  print(widget.stock);
                  updateStock(widget.stock).then((value) {
                    Navigator.pop(context);
                  });
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateStock(dynamic stock) async {
    try {
      var response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/api/stocks/${stock['id']}/'),
        body: jsonEncode(
          <String, dynamic>{
            'store_stock': stock['store_stock'],
          },
        ),
        headers: {'Content-Type': 'application/json'},
      );
      print(stock['date']);
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
          ),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print('Error updating stock: $e');
      rethrow;
    }
  }
}
