import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'customization_screen.dart'; // Import the new customization screen file

class EntreesScreen extends StatefulWidget {
  const EntreesScreen({super.key});

  @override
  _EntreesScreenState createState() => _EntreesScreenState();
}

class _EntreesScreenState extends State<EntreesScreen> {
  final List<String> categories = [];
  final Map<String, List<Map<String, dynamic>>> entrees = {};
  final List<String> sides = [];
  final List<String> drinks = [];

  String selectedCategory = '';
  String? selectedEntree; // Only one entree can be selected
  String? selectedPrice; // Store price of selected entree

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load the text file
      final String data = await rootBundle.loadString('assets/entrees_data.txt');

      // Parse the data
      Map<String, dynamic> parsedData = _parseData(data);

      setState(() {
        categories.addAll(parsedData['categories'].cast<String>());
        entrees.addAll(parsedData['entrees']);
        sides.addAll(parsedData['sides'].cast<String>());
        drinks.addAll(parsedData['drinks'].cast<String>());
        selectedCategory = categories.isNotEmpty ? categories.first : '';
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Map<String, dynamic> _parseData(String data) {
    Map<String, dynamic> result = {
      'categories': <String>[],
      'entrees': <String, List<Map<String, dynamic>>>{},
      'sides': <String>[],
      'drinks': <String>[],
    };

    List<String> lines = LineSplitter.split(data).toList();
    String currentCategory = '';

    for (String line in lines) {
      line = line.trim();

      if (line.startsWith('[') && line.endsWith(']')) {
        // New category
        currentCategory = line.substring(1, line.length - 1);
        if (currentCategory == 'Sides' || currentCategory == 'Drinks') {
          result[currentCategory.toLowerCase()] = <String>[];
        } else {
          result['categories'].add(currentCategory);
          result['entrees'][currentCategory] = <Map<String, dynamic>>[];
        }
      } else if (line.isNotEmpty) {
        // Entree or side/drink
        if (currentCategory == 'Sides' || currentCategory == 'Drinks') {
          result[currentCategory.toLowerCase()].add(line);
        } else {
          List<String> parts = line.split(':');
          String name = parts.isNotEmpty ? parts[0] : '';
          List<String> customizations = (parts.length > 1 && parts[1].isNotEmpty)
              ? parts[1].split(',')
              : [];
          String sizeOrDescription = (parts.length > 2 && parts[2].isNotEmpty)
              ? parts[2]
              : '';
          String price = (parts.length > 3 && parts[3].isNotEmpty)
              ? parts[3].trim()
              : '0.00';

          // Ensure price is formatted correctly
          try {
            price = double.parse(price).toStringAsFixed(2);
          } catch (e) {
            price = '0.00';
          }

          if (name.isNotEmpty) {
            result['entrees'][currentCategory].add({
              'name': name,
              'customizations': customizations,
              'size': sizeOrDescription,
              'price': price,
            });
          }
        }
      }
    }

    return result;
  }

  void _confirmSelection() async {
    if (selectedEntree == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No entree selected!')),
      );
      return;
    }

    // Navigate to the customization screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomizationScreen(
          entreeName: selectedEntree!,
          price: selectedPrice ?? '0.00',
        ),
      ),
    );

    // Handle customizations returned from the customization screen
    if (result != null) {
      print('Customizations: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customization saved: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrees'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Sidebar with categories
                Container(
                  width: 150,
                  color: Colors.grey[200],
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == selectedCategory;

                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.lightGreen : Colors.grey[200],
                          foregroundColor: isSelected ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),

                // Entrees list
                Expanded(
                  child: entrees.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            // Search bar
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            // Entree items
                            Expanded(
                              child: ListView.builder(
                                itemCount: entrees[selectedCategory]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final entree = entrees[selectedCategory]![index];
                                  final isSelected = selectedEntree == entree['name'];

                                  return ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedEntree = null; // Deselect
                                          selectedPrice = null;
                                        } else {
                                          selectedEntree = entree['name']; // Select
                                          selectedPrice = entree['price'];
                                        }
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
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${entree['name']} (${entree['size']})',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              '\$${entree['price']}',
                                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          isSelected ? Icons.check : Icons.help_outline,
                                          color: isSelected ? Colors.white : Colors.black,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _confirmSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
