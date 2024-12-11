import 'package:flutter/material.dart';
import 'dart:io';
import 'customization_screen.dart';
import 'entrees.dart';
import 'sides.dart';
import 'salads.dart';
import 'drinks.dart';
import 'desserts.dart';
import 'orderscreen.dart';
import 'tables.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swift Serve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> currentOrder = [];
  int orderIdCounter = 0;
  int selectedTableNumber = 1; // Set default table number to 1

  void navigateToCategory(BuildContext context, String category) async {
    Widget screen;
    dynamic result;
    switch (category) {
      case 'Entrees':
        screen = const EntreesScreen();
        result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
        if (result != null) {
          setState(() {
            int orderId = orderIdCounter++;
            currentOrder.add({'id': orderId, 'name': '${result['entree']['name']}', 'price': result['entree']['price']});
            currentOrder.add({'id': orderId, 'name': '${result['side']['name']}', 'price': result['side']['price']});
            currentOrder.add({'id': orderId, 'name': '${result['drink']['name']}', 'price': result['drink']['price']});
          });
        }
        break;
      case 'Sides':
        screen = const SidesScreen();
        result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
        if (result != null) {
          setState(() {
            int orderId = orderIdCounter++;
            currentOrder.add({'id': orderId, 'name': '${result['name']}', 'price': result['price']});
          });
        }
        break;
      case 'Salads':
        screen = const SaladsScreen();
        result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
        if (result != null) {
          setState(() {
            int orderId = orderIdCounter++;
            currentOrder.add({'id': orderId, 'name': '${result['name']}', 'price': result['price']});
          });
        }
        break;
      case 'Drinks':
        screen = const DrinksScreen();
        result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
        if (result != null) {
          setState(() {
            int orderId = orderIdCounter++;
            currentOrder.add({'id': orderId, 'name': '${result['name']}', 'price': result['price']});
          });
        }
        break;
      case 'Desserts':
        screen = const DessertsScreen();
        result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
        if (result != null) {
          setState(() {
            int orderId = orderIdCounter++;
            currentOrder.add({'id': orderId, 'name': '${result['name']}', 'price': result['price']});
          });
        }
        break;
    }
  }

  void removeItem(int orderId) {
    setState(() {
      currentOrder.removeWhere((item) => item['id'] == orderId);
    });
  }

  double calculateSubtotal() {
    return currentOrder.fold(0.0, (sum, item) => sum + double.parse(item['price']));
  }

  void confirmOrder(BuildContext context) {
    if(currentOrder.isEmpty){
      _showSnackBar(context, 'Please add items to your order');
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: const Text('Are you sure you want to place your order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addOrderToTableInfo();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderScreen(order: currentOrder),
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _addOrderToTableInfo() async {
    final file = File('assets/tableinfo.txt');
    List<String> lines = await file.readAsLines();
    String tableHeader = '[Table $selectedTableNumber]';
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith(tableHeader)) {
        String orderInfo = currentOrder.map((item) => '${item['name']} (\$${item['price']})').join(', ');
        lines[i] = '$tableHeader $orderInfo';
        break;
      }
    }
    await file.writeAsString(lines.join('\n'));
  }

  Map<int, List<String>> tableRequests = {};

  void addRequestToTable(String request) {
    if (!tableRequests.containsKey(selectedTableNumber)) {
      tableRequests[selectedTableNumber] = [];
    }
    String currentTime = DateFormat('HH:mm').format(DateTime.now());
    tableRequests[selectedTableNumber]!.add('$request: $currentTime');
    _showSnackBar(context, 'Request added: $request at $currentTime');
  }

  void setTableNumber(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Table Number'),
          content: DropdownButton<int>(
            value: selectedTableNumber,
            items: List.generate(10, (index) => index + 1)
                .map((number) => DropdownMenuItem<int>(
                      value: number,
                      child: Text('Table $number'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedTableNumber = value!;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = calculateSubtotal();
    double tax = subtotal * 0.10;
    double total = subtotal + tax;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Menu'),
            const SizedBox(width: 8),
            Text(
              '(Table $selectedTableNumber)',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TablesScreen(tableRequests: tableRequests),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setTableNumber(context);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: currentOrder.map((item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['name']} (\$${item['price']})'),
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () => removeItem(item['id']),
                          ),
                        ],
                      )).toList(),
                    ),
                  ),
                ),
                Container(
                  color: Colors.amber[100],
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                      Text('Tax: \$${tax.toStringAsFixed(2)}'),
                      Text('Total: \$${total.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => navigateToCategory(context, 'Entrees'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 23),
                    ),
                    child: const Text(
                      'Entrees',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => navigateToCategory(context, 'Sides'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 23),
                    ),
                    child: const Text(
                      'Sides',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => navigateToCategory(context, 'Salads'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 23),
                    ),
                    child: const Text(
                      'Salads',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => navigateToCategory(context, 'Drinks'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 23),
                    ),
                    child: const Text(
                      'Drinks',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => navigateToCategory(context, 'Desserts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 23),
                    ),
                    child: const Text(
                      'Desserts',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.notifications),
                        onSelected: (String result) {
                          switch (result) {
                            case 'Call waiter':
                              addRequestToTable('Waiter Requested');
                              _showSnackBar(context, 'Waiter is on the way');
                              break;
                            case 'Call for Refills':
                              addRequestToTable('Refills Requested');
                              _showSnackBar(context, 'Refills requested');
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Call waiter',
                            child: Text('Call waiter'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Call for Refills',
                            child: Text('Call for Refills'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => confirmOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      padding: const EdgeInsets.symmetric(vertical: 23),
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}