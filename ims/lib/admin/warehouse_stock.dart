import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WarehouseStockPage extends StatefulWidget {
  const WarehouseStockPage({Key? key}) : super(key: key);

  @override
  WarehouseStockPageState createState() => WarehouseStockPageState();
}

class WarehouseStockPageState extends State<WarehouseStockPage> {
  List data = [];

  Future<List> getData() async {
    try {
      var response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/products/'));
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
        title: const Text('Warehouse'),
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
            DataColumn(label: Text('Product Name')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Edit')),
          ],
          rows: data
              .map((item) => DataRow(cells: [
                    DataCell(Text(item['id'].toString())),
                    DataCell(Text(item['product_name'])),
                    DataCell(Text(item['warehouse_stock'].toString())),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateStockPage(
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

class UpdateStockPage extends StatefulWidget {
  final dynamic stock;

  const UpdateStockPage({Key? key, required this.stock}) : super(key: key);

  @override
  UpdateStockPageState createState() => UpdateStockPageState();
}

class UpdateStockPageState extends State<UpdateStockPage> {
  late TextEditingController _warehouseStock;

  @override
  void initState() {
    super.initState();
    _warehouseStock =
        TextEditingController(text: widget.stock['warehouse_stock'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Warehouse Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${widget.stock['product_name']}'),
            const SizedBox(height: 16.0),
            TextField(
              controller: _warehouseStock,
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
                  int newStock = int.tryParse(_warehouseStock.text) ?? 0;
                  widget.stock['warehouse_stock'] = newStock;
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

  Future<void> updateStock(dynamic warehouseStock) async {
    try {
      print(warehouseStock['id']);
      var url =
          'http://10.0.2.2:8000/api/update_stock/${warehouseStock['id']}/';
      var response = await http.patch(
        Uri.parse(url),
        body: jsonEncode(
          <String, dynamic>{
            'warehouse_stock': warehouseStock['warehouse_stock'],
          },
        ),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      print(data);

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
