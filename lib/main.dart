import 'package:flutter/material.dart';
import 'customization_screen.dart';
import 'entrees.dart';
import 'sides.dart';
import 'salads.dart';
import 'drinks.dart';
import 'desserts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swift Serve',
      debugShowCheckedModeBanner: false, // Disable the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // Function to navigate to the appropriate screen based on the category
  void navigateToCategory(BuildContext context, String category) {
    Widget screen;
    switch (category) {
      case 'Entrees':
        screen = const EntreesScreen();
        break;
      /*case 'Sides':
        screen = const SidesScreen();
        break;
      case 'Salads':
        screen = const SaladsScreen();
        break;
      case 'Drinks':
        screen = const DrinksScreen();
        break;
      case 'Desserts':
        screen = const DessertsScreen();
        break;*/
      default:
        screen = const MenuScreen(); // Fallback to menu if the category is unknown
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.lightGreen,
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
                const Text('None'),
                const Spacer(),
                Container(
                  color: Colors.amber[100],
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Subtotal: 0'),
                      Text('Tax: 0'),
                      Text('Total: 0'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Food category buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

