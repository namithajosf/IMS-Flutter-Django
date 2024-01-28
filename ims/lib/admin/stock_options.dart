import 'package:flutter/material.dart';
import 'package:ims/admin/store_stock.dart';
import 'package:ims/admin/warehouse_stock.dart';

class StockOptionsPage extends StatelessWidget {
  const StockOptionsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildGridItem(
            context,
            title: 'Stores',
            icon: Icons.store,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const StoreStocksPage();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          buildGridItem(
            context,
            title: 'Warehouse',
            icon: Icons.warehouse,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const WarehouseStockPage();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150, // Set the desired height
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
              icon,
              size: 40,
              color: Colors.teal,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
