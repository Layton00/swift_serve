import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class DrinksScreen extends StatefulWidget {
  const DrinksScreen({super.key});

  @override
  _DrinksScreenState createState() => _DrinksScreenState();
}

class _DrinksScreenState extends State<DrinksScreen> {
  final List<Map<String, String>> drinks = [];
  final List<String> selectedDrinks = [];
  String? selectedDrink; // Stores the confirmed drink
  String? selectedDrinkPrice; // Stores the price of the confirmed drink

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load the text file
      final String data = await rootBundle.loadString('assets/drinks.txt');
      // Parse the data
      _parseData(data);
    } catch (e) {
      print('Error loading drinks data: $e');
    }
  }

  void _parseData(String data) {
    List<String> lines = LineSplitter.split(data).toList();
    // Parse lines
    for (String line in lines) {
      line = line.trim();
      // Skip the category header
      if (line.startsWith('[') && line.endsWith(']')) {
        continue;
      }
      // Parse drink details
      if (line.isNotEmpty) {
        List<String> parts = line.split(':::');
        if (parts.length == 2) {
          drinks.add({
            'name': parts[0].trim(),
            'price': parts[1].trim(),
          });
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drinks'),
        backgroundColor: Colors.lightGreen,
      ),
      body: drinks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: drinks.length,
                      itemBuilder: (context, index) {
                        final drink = drinks[index];
                        final isSelected = selectedDrinks.contains(drink['name']);
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedDrinks.clear();
                              selectedDrinks.add(drink['name'] ?? '');
                              selectedDrink = drink['name']; // Update selected drink
                              selectedDrinkPrice = drink['price']; // Update selected drink price
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected ? Colors.lightGreen : Colors.grey[200],
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${drink['name'] ?? 'Unknown'} (\$${drink['price'] ?? '0.00'})',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline),
                                color: isSelected ? Colors.white : Colors.black,
                                onPressed: () {
                                  // Show additional info about the drink
                                  _showDrinkInfo(
                                    context,
                                    drink['name'] ?? 'Unknown',
                                    drink['price'] ?? '0.00',
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Confirm Button
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedDrink == null) {
                        _showError(context, 'No drink selected', 'Please select a drink to confirm.');
                      } else {
                        // Save selected drink and navigate back
                        Navigator.of(context).pop({'name': selectedDrink, 'price': selectedDrinkPrice});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showDrinkInfo(BuildContext context, String name, String price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Text(
            'Price: \$${price}\nMore information about this drink will be available here.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showError(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}