import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoresPage extends StatefulWidget {
  const StoresPage({Key? key}) : super(key: key);

  @override
  StoresPageState createState() => StoresPageState();
}

class StoresPageState extends State<StoresPage> {
  List data = [];

  Future<List> getData() async {
    try {
      var response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/stores/'));
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
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Store Name')),
            DataColumn(label: Text('Store Owner')),
          ],
          rows: data
              .map((item) => DataRow(cells: [
                    DataCell(Text(item['id'].toString())),
                    DataCell(Text(item['store_name'])),
                    DataCell(Text(item['user'])),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}
