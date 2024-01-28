import 'package:flutter/material.dart';
import 'package:ims/admin/admin_sales.dart';
import 'package:ims/admin/stock_options.dart';
import 'package:ims/admin/users_details.dart';
import 'package:ims/admin/wholesales.dart';
import 'package:ims/login_form.dart';
import 'package:ims/admin/products.dart';
import 'package:ims/admin/stores.dart';
import 'package:ims/admin/suppliers.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: ListTile(
                  title: Text(
                    'IMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const UsersPage();
                      },
                    ),
                  );
                },
                leading: const Icon(Icons.people),
                title: const Text(
                  'Users',
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const LoginPage();
                      },
                    ),
                  );
                },
                leading: const Icon(Icons.logout),
                title: const Text(
                  'Logout',
                ),
              ),
            ],
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: 6, // Number of items in your grid
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // Use a switch statement or if-else to navigate based on the index
              switch (index) {
                case 0:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ProductsPage();
                      },
                    ),
                  );
                  break;
                case 1:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const AdminSalesPage();
                      },
                    ),
                  );
                  break;
                case 2:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const StoresPage();
                      },
                    ),
                  );
                  break;
                case 3:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const SuppliersPage();
                      },
                    ),
                  );
                  break;
                case 4:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const StockOptionsPage();
                      },
                    ),
                  );
                  break;
                case 5:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const WholesalesPage();
                      },
                    ),
                  );
                  break;
                default:
              }
            },
            child: Container(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    getIcon(index),
                    size: 50.0, // Adjust the icon size as needed
                    color: Colors.teal, // Adjust the icon color as needed
                  ),
                  const SizedBox(height: 10.0),
                  ListTile(
                    title: Center(
                      child: index == 0
                          ? const Text(
                              'Products',
                              style: TextStyle(fontSize: 20.0),
                            )
                          : index == 1
                              ? const Text(
                                  'Sales',
                                  style: TextStyle(fontSize: 20.0),
                                )
                              : index == 2
                                  ? const Text(
                                      'Stores',
                                      style: TextStyle(fontSize: 20.0),
                                    )
                                  : index == 3
                                      ? const Text(
                                          'Suppliers',
                                          style: TextStyle(fontSize: 20.0),
                                        )
                                      : index == 4
                                          ? const Text(
                                              'Stock',
                                              style: TextStyle(fontSize: 20.0),
                                            )
                                          : const Text(
                                              'Wholesales',
                                              style: TextStyle(fontSize: 20.0),
                                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.shopping_bag;
      case 1:
        return Icons.shopping_cart_checkout;
      case 2:
        return Icons.store;
      case 3:
        return Icons.people;
      case 4:
        return Icons.inventory;
      case 5:
        return Icons.local_shipping;
      default:
        return Icons.category;
    }
  }
}
