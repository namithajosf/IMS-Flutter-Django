import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SalesForm extends StatefulWidget {
  const SalesForm({Key? key}) : super(key: key);

  @override
  SalesFormState createState() => SalesFormState();
}

class SalesFormState extends State<SalesForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> productNames = [''];
  List<int> productQuantities = [0];
  List<Map<String, dynamic>> productsData = [];
  String productItems = "";
  int numItems = 0;
  String customerID = "";

  late DateTime currentDateTime = DateTime.now();

  Future<void> submitSalesData() async {
    try {
      print(numItems);
      List<Map<String, dynamic>> products = [];
      double totalPrice = 0;

      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/add_sales/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'date': currentDateTime.toString(),
          'customer_id': customerID,
          'no_of_items': numItems,
          'products': List.generate(
            productNames.length,
            (index) => {
              'name': productNames[index],
              'quantity': productQuantities[index],
            },
          ),
        }),
      );
      final responseData = json.decode(response.body);
      final responseMessage = responseData['message'];

      if (responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseMessage),
          ),
        );
      } else if (!responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseMessage),
        ));
      } else {
        throw Exception('Failed to submit sales data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting sales data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sales'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'DateTime: $currentDateTime',
              style: const TextStyle(fontSize: 20),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Customer ID',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a customer ID';
                }
                return null;
              },
              onSaved: (value) {
                customerID = value!;
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: productNames.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Product',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a product';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          productNames[index] = value!;
                          numItems = index + 1;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: productQuantities[index].toString(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a quantity';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) == 0) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          productQuantities[index] = int.parse(value!);
                        },
                      ),
                    ),
                    if (numItems > 0)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            productNames.removeAt(index);
                            productQuantities.removeAt(index);
                            numItems--;
                          });
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  productNames.add('');
                  productQuantities.add(0);
                });
              },
              child: const Text('Add Product'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  submitSalesData();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
