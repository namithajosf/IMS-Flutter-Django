import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewWholesalesPage extends StatefulWidget {
  const ViewWholesalesPage({Key? key}) : super(key: key);

  @override
  ViewWholesalesPageState createState() => ViewWholesalesPageState();
}

class ViewWholesalesPageState extends State<ViewWholesalesPage> {
  List data = [];

  Future<List> getSales() async {
    try {
      var response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/wholesales/'));
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
        title: const Text('Wholesales'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Wholesale ID')),
                  DataColumn(label: Text('DateTime')),
                  DataColumn(label: Text('Number of items purchased')),
                  DataColumn(label: Text('Total price')),
                ],
                rows: data
                    .map((item) => DataRow(cells: [
                          DataCell(Text(item['id'].toString())),
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
                    return const WholesaleItemsPage();
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

class WholesaleItemsPage extends StatefulWidget {
  const WholesaleItemsPage({Key? key}) : super(key: key);

  @override
  WholesaleItemsPageState createState() => WholesaleItemsPageState();
}

class WholesaleItemsPageState extends State<WholesaleItemsPage> {
  List data = [];

  Future<List> getData() async {
    try {
      var response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/wholesale_items/'));
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
            DataColumn(label: Text('Wholesale')),
            DataColumn(label: Text('Product Name')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Total')),
          ],
          rows: data
              .map((item) => DataRow(cells: [
                    DataCell(Text(item['wholesale'].toString())),
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
