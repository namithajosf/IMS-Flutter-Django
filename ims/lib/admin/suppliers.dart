import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({Key? key}) : super(key: key);

  @override
  SuppliersPageState createState() => SuppliersPageState();
}

class SuppliersPageState extends State<SuppliersPage> {
  List data = [];

  Future<List> getData() async {
    try {
      var response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/suppliers/'));
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
        title: const Text('Suppliers'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Delete')),
          ],
          rows: data.map(
            (item) {
              return DataRow(
                cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['full_name'])),
                  DataCell(Text(item['address'])),
                  DataCell(Text(item['email'])),
                  DataCell(Text(item['phone'])),
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
                                    'Are you sure you want to delete this supplier?'),
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
                                    'http://10.0.2.2:8000/api/suppliers/${item['id']}/'));
                                print(item);
                                print(response.statusCode);

                                if (response.statusCode == 204) {
                                  setState(() {
                                    data.remove(item);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Supplier deleted successfully')),
                                  );
                                } else {
                                  throw Exception(
                                      'Failed to delete supplier: ${response.statusCode}');
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Error deleting supplier')),
                                );
                                print('Error deleting supplier: $e');
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
                return const AddSupplierForm();
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

class AddSupplierForm extends StatefulWidget {
  const AddSupplierForm({Key? key}) : super(key: key);

  @override
  AddSupplierFormState createState() => AddSupplierFormState();
}

class AddSupplierFormState extends State<AddSupplierForm> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  String _Name = "";
  String _address = "";
  String _email = "";
  String _phoneNo = "";

  Future addSuppliers() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        var response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/add_suppliers/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'full_name': _Name,
            'address': _address,
            'email': _email,
            'phone': _phoneNo,
          }),
        );
        var data = jsonDecode(response.body);
        print(data);

        if (data['success']) {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Saved"),
                content: const Text("Supplier added successfully"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SuppliersPage()),
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
        print('Error adding supplier: $e');
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
          title: const Text('Add Suppliers'),
        ),
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
                        const InputDecoration(labelText: 'Supplier Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter supplier name';
                      }
                      return null;
                    },
                    onSaved: (value) => _Name = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                    onSaved: (value) => _address = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter email address';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                    onSaved: (value) => _phoneNo = value!,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: addSuppliers,
                      child: const Text('Add Supplier'),
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
