import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
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
        title: const Text('Products'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Product Name')),
            DataColumn(label: Text('Supplier')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Delete')),
          ],
          rows: data.map(
            (item) {
              return DataRow(
                cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['product_name'])),
                  DataCell(Text(item['supplier'])),
                  DataCell(Text(item['warehouse_stock'].toString())),
                  DataCell(Text(item['unit_price'].toString())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final confirmDelete = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                    'Are you sure you want to delete this product?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmDelete == true) {
                              try {
                                final response = await http.delete(Uri.parse(
                                    'http://10.0.2.2:8000/api/products/${item['id']}/'));
                                print(item);
                                print(response.statusCode);

                                if (response.statusCode == 204) {
                                  setState(() {
                                    data.remove(item);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Product deleted successfully')),
                                  );
                                } else {
                                  throw Exception(
                                      'Failed to delete product: ${response.statusCode}');
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Error deleting product')),
                                );
                                print('Error deleting product: $e');
                              }
                            }
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const AddProductForm();
              },
            ),
          );
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddProductForm extends StatefulWidget {
  const AddProductForm({Key? key}) : super(key: key);

  @override
  AddProductFormState createState() => AddProductFormState();
}

class AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  String _productName = "";
  String _supplierName = "";
  int _warehouseStock = 0;
  double _unitPrice = 0.0;

  Future addProducts() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        var response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/add_products/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'product_name': _productName,
            'supplier': _supplierName,
            'warehouse_stock': _warehouseStock,
            'unit_price': _unitPrice,
          }),
        );
        var data = jsonDecode(response.body);

        if (data['success']) {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Saved"),
                content: const Text("Product added successfully"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProductsPage()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text(data['message']),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print('Error adding product: $e');
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Add Products'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const ProductsPage();
                    },
                  ),
                );
              },
            )),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Product Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                    onSaved: (value) => _productName = value!,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Supplier Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter supplier name';
                      }
                      return null;
                    },
                    onSaved: (value) => _supplierName = value!,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Warehouse Stock'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter warehouse stock';
                      }
                      return null;
                    },
                    onSaved: (value) => _warehouseStock =
                        value!.isNotEmpty ? int.parse(value) : 0,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Unit Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter unit price';
                      }
                      return null;
                    },
                    onSaved: (value) => _unitPrice = double.parse(value!),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: addProducts,
                      child: const Text('Add Product'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
