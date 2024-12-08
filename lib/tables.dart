import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  String? selectedTable;
  Map<String, List<String>> tableOrders = {};
  Map<String, List<String>> tableRequests = {};

  @override
  void initState() {
    super.initState();
    _loadTableInfo();
    _loadTableRequests();
  }

  Future<void> _loadTableInfo() async {
    final file = File('assets/tableinfo.txt');
    List<String> lines = await file.readAsLines();
    Map<String, List<String>> orders = {};

    for (String line in lines) {
      if (line.startsWith('[') && line.contains(']')) {
        String tableName = line.substring(1, line.indexOf(']'));
        String orderInfo = line.substring(line.indexOf(']') + 1).trim();
        orders[tableName] = orderInfo.isNotEmpty
            ? orderInfo.split(',').map((item) => item.trim()).toList()
            : [];
      }
    }

    setState(() {
      tableOrders = orders;
    });
  }

  Future<void> _loadTableRequests() async {
    final file = File('assets/tableinfo.txt');
    List<String> lines = await file.readAsLines();
    Map<String, List<String>> requests = {};

    for (String line in lines) {
      if (line.startsWith('[') && line.contains(']')) {
        String tableName = line.substring(1, line.indexOf(']'));
        int colonIndex = line.indexOf(':');
        if (colonIndex != -1) {
          String requestInfo = line.substring(colonIndex + 1).trim();
          requests[tableName] = requestInfo.isNotEmpty
              ? requestInfo.split(',').map((item) => item.trim()).toList()
              : [];
        }
      }
    }

    setState(() {
      tableRequests = requests;
    });
  }

  Future<void> _closeTable() async {
    if (selectedTable == null) return;

    final file = File('assets/tableinfo.txt');
    List<String> lines = await file.readAsLines();
    List<String> updatedLines = [];

    for (String line in lines) {
      if (line.startsWith('[') && line.contains(']')) {
        String tableName = line.substring(1, line.indexOf(']'));
        if (tableName == selectedTable) {
          updatedLines.add('[$tableName] ');
        } else {
          updatedLines.add(line);
        }
      } else {
        updatedLines.add(line);
      }
    }

    await file.writeAsString(updatedLines.join('\n'));

    setState(() {
      tableOrders[selectedTable!] = [];
      tableRequests[selectedTable!] = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Row(
        children: [
          // Left side with table buttons
          Container(
            width: 250,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                final tableNumber = index + 1;
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedTable = 'Table $tableNumber';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Table $tableNumber',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          // Right side with submenu
          Expanded(
            child: selectedTable == null
                ? const Center(
                    child: Text(
                      'Select a table to view details',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedTable!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreen,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Info',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: ListView(
                                    children: [
                                      ...?tableOrders[selectedTable]?.map((item) => Text(
                                            item,
                                            style: const TextStyle(fontSize: 16, color: Colors.black),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Requests',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: ListView(
                                    children: [
                                      ...?tableRequests[selectedTable]?.map((item) => Text(
                                            item,
                                            style: const TextStyle(fontSize: 16, color: Colors.black),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _closeTable,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Close table',
                            style: TextStyle(fontSize: 16),
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