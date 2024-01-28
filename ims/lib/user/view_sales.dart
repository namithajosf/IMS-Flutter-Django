import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewSalesPage extends StatefulWidget {
  const ViewSalesPage({Key? key}) : super(key: key);

  @override
  ViewSalesPageState createState() => ViewSalesPageState();
}

class ViewSalesPageState extends State<ViewSalesPage> {
  List data = [];

  Future<List> getSales() async {
    try {
      var response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/sales/'));
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
    getSales().then((value) {
      setState(() {
        data = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Customer ID')),
                  DataColumn(label: Text('DateTime')),
                  DataColumn(label: Text('Number of items purchased')),
                  DataColumn(label: Text('Total price')),
                ],
                rows: data
                    .map((item) => DataRow(cells: [
                          DataCell(Text(item['customer_id'].toString())),
                          DataCell(Text(item['date'])),
                          DataCell(Text(item['no_of_items'].toString())),
                          DataCell(Text(item['total_price'].toString())),
                        ]))
                    .toList(),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const SaleItemsPage();
                  },
                ),
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: const ListTile(
                title: Text('Items'),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaleItemsPage extends StatefulWidget {
  const SaleItemsPage({Key? key}) : super(key: key);

  @override
  SaleItemsPageState createState() => SaleItemsPageState();
}

class SaleItemsPageState extends State<SaleItemsPage> {
  List data = [];

  Future<List> getData() async {
    try {
      var response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/sale_items/'));
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
        title: const Text('Items'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Sale')),
            DataColumn(label: Text('Product Name')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Total')),
          ],
          rows: data
              .map((item) => DataRow(cells: [
                    DataCell(Text(item['sale'].toString())),
                    DataCell(Text(item['product'])),
                    DataCell(Text(item['quantity'].toString())),
                    DataCell(Text(item['unit_price'].toString())),
                    DataCell(Text(item['product_total_price'].toString())),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}
