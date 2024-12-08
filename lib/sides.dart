import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class SidesScreen extends StatefulWidget {
  const SidesScreen({super.key});

  @override
  _SidesScreenState createState() => _SidesScreenState();
}

class _SidesScreenState extends State<SidesScreen> {
  final List<Map<String, String>> sides = [];
  final List<String> selectedSides = [];
  String? selectedSide; // Stores the confirmed side
  String? selectedSidePrice; // Stores the price of the confirmed side

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load the text file
      final String data = await rootBundle.loadString('assets/sides.txt');
      // Parse the data
      _parseData(data);
    } catch (e) {
      print('Error loading sides data: $e');
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
      // Parse side details
      if (line.isNotEmpty) {
        List<String> parts = line.split(':::');
        if (parts.length == 2) {
          sides.add({
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
        title: const Text('Sides'),
        backgroundColor: Colors.lightGreen,
      ),
      body: sides.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: sides.length,
                      itemBuilder: (context, index) {
                        final side = sides[index];
                        final isSelected = selectedSides.contains(side['name']);
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedSides.clear();
                              selectedSides.add(side['name'] ?? '');
                              selectedSide = side['name']; // Update selected side
                              selectedSidePrice = side['price']; // Update selected side price
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
                                '${side['name'] ?? 'Unknown'} (\$${side['price'] ?? '0.00'})',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline),
                                color: isSelected ? Colors.white : Colors.black,
                                onPressed: () {
                                  // Show additional info about the side
                                  _showSideInfo(
                                    context,
                                    side['name'] ?? 'Unknown',
                                    side['price'] ?? '0.00',
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
                      if (selectedSide == null) {
                        _showError(context, 'No side selected', 'Please select a side to confirm.');
                      } else {
                        // Save selected side and navigate back
                        Navigator.of(context).pop({'name': selectedSide, 'price': selectedSidePrice});
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

  void _showSideInfo(BuildContext context, String name, String price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Text(
            'Price: \$${price}\nMore information about this side will be available here.',
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