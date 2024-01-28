import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ims/admin/admin_home.dart';
import 'dart:convert';

import 'package:ims/user/user_home.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {
  List data = [];

  Future<List> getData() async {
    try {
      var response =
          await http.get(Uri.parse('http://10.0.2.2:8000/api/users/'));
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
        title: const Text('Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const AdminHomePage();
                },
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('First Name')),
            DataColumn(label: Text('Last Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Delete')),
          ],
          rows: data.map(
            (item) {
              return DataRow(
                cells: [
                  DataCell(Text(item['id'].toString())),
                  DataCell(Text(item['username'])),
                  DataCell(Text(item['first_name'])),
                  DataCell(Text(item['last_name'].toString())),
                  DataCell(Text(item['email'].toString())),
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
                                    'Are you sure you want to delete this user?'),
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
                                    'http://10.0.2.2:8000/api/users/${item['id']}/'));
                                print(item);
                                print(response.statusCode);

                                if (response.statusCode == 204) {
                                  setState(() {
                                    data.remove(item);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('User deleted successfully')),
                                  );
                                } else {
                                  throw Exception(
                                      'Failed to delete User: ${response.statusCode}');
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Error deleting User')),
                                );
                                print('Error deleting User: $e');
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
                return const AddUserForm();
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

class AddUserForm extends StatefulWidget {
  const AddUserForm({Key? key}) : super(key: key);

  @override
  AddUserFormState createState() => AddUserFormState();
}

class AddUserFormState extends State<AddUserForm> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  String _userName = "";
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _password = "";

  Future addUsers() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        var response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/add_users/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'username': _userName,
            'first_name': _firstName,
            'last_name': _lastName,
            'email': _email,
            'password': _password,
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
                content: const Text("User added successfully"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UsersPage()),
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
        print('Error adding User: $e');
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
          title: const Text('Add Users'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const UsersPage();
                  },
                ),
              );
            },
          ),
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
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    onSaved: (value) => _userName = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                    onSaved: (value) => _firstName = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                    onSaved: (value) => _lastName = value!,
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
                    decoration: const InputDecoration(labelText: 'Password'),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: addUsers,
                      child: const Text('Add User'),
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
