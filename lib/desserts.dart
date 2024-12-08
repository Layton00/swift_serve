import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class DessertsScreen extends StatefulWidget {
  const DessertsScreen({super.key});

  @override
  _DessertsScreenState createState() => _DessertsScreenState();
}

class _DessertsScreenState extends State<DessertsScreen> {
  final List<Map<String, String>> desserts = [];
  final List<String> selectedDesserts = [];
  String? selectedDessert; // Stores the confirmed dessert
  String? selectedDessertPrice; // Stores the price of the confirmed dessert

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load the text file
      final String data = await rootBundle.loadString('assets/desserts.txt');
      // Parse the data
      _parseData(data);
    } catch (e) {
      print('Error loading desserts data: $e');
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
      // Parse dessert details
      if (line.isNotEmpty) {
        List<String> parts = line.split(':::');
        if (parts.length == 2) {
          desserts.add({
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
        title: const Text('Desserts'),
        backgroundColor: Colors.lightGreen,
      ),
      body: desserts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: desserts.length,
                      itemBuilder: (context, index) {
                        final dessert = desserts[index];
                        final isSelected = selectedDesserts.contains(dessert['name']);
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedDesserts.clear();
                              selectedDesserts.add(dessert['name'] ?? '');
                              selectedDessert = dessert['name']; // Update selected dessert
                              selectedDessertPrice = dessert['price']; // Update selected dessert price
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
                                '${dessert['name'] ?? 'Unknown'} (\$${dessert['price'] ?? '0.00'})',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline),
                                color: isSelected ? Colors.white : Colors.black,
                                onPressed: () {
                                  // Show additional info about the dessert
                                  _showDessertInfo(
                                    context,
                                    dessert['name'] ?? 'Unknown',
                                    dessert['price'] ?? '0.00',
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
                      if (selectedDessert == null) {
                        _showError(context, 'No dessert selected', 'Please select a dessert to confirm.');
                      } else {
                        // Save selected dessert and navigate back
                        Navigator.of(context).pop({'name': selectedDessert, 'price': selectedDessertPrice});
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

  void _showDessertInfo(BuildContext context, String name, String price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Text(
            'Price: \$${price}\nMore information about this dessert will be available here.',
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