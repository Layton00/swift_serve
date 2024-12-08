import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class SaladsScreen extends StatefulWidget {
  const SaladsScreen({super.key});

  @override
  _SaladsScreenState createState() => _SaladsScreenState();
}

class _SaladsScreenState extends State<SaladsScreen> {
  final List<Map<String, String>> salads = [];
  final List<String> selectedSalads = [];
  String? selectedSalad; // Stores the confirmed salad
  String? selectedSaladPrice; // Stores the price of the confirmed salad

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load the text file
      final String data = await rootBundle.loadString('assets/salads.txt');
      // Parse the data
      _parseData(data);
    } catch (e) {
      print('Error loading salads data: $e');
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
      // Parse salad details
      if (line.isNotEmpty) {
        List<String> parts = line.split(':::');
        if (parts.length == 2) {
          salads.add({
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
        title: const Text('Salads'),
        backgroundColor: Colors.lightGreen,
      ),
      body: salads.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: salads.length,
                      itemBuilder: (context, index) {
                        final salad = salads[index];
                        final isSelected = selectedSalads.contains(salad['name']);
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedSalads.clear();
                              selectedSalads.add(salad['name'] ?? '');
                              selectedSalad = salad['name']; // Update selected salad
                              selectedSaladPrice = salad['price']; // Update selected salad price
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
                                '${salad['name'] ?? 'Unknown'} (\$${salad['price'] ?? '0.00'})',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline),
                                color: isSelected ? Colors.white : Colors.black,
                                onPressed: () {
                                  // Show additional info about the salad
                                  _showSaladInfo(
                                    context,
                                    salad['name'] ?? 'Unknown',
                                    salad['price'] ?? '0.00',
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
                      if (selectedSalad == null) {
                        _showError(context, 'No salad selected', 'Please select a salad to confirm.');
                      } else {
                        // Save selected salad and navigate back
                        Navigator.of(context).pop({'name': selectedSalad, 'price': selectedSaladPrice});
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

  void _showSaladInfo(BuildContext context, String name, String price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Text(
            'Price: \$${price}\nMore information about this salad will be available here.',
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