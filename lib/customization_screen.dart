import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CustomizationScreen extends StatefulWidget {
  final String entreeName; // The name of the selected entree
  final String price;      // The price of the selected entree

  const CustomizationScreen({required this.entreeName, required this.price, Key? key})
      : super(key: key);

  @override
  _CustomizationScreenState createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  late String steakCook;
  late List<String> selectedBurgerIngredients;
  late String selectedSide;
  late String selectedDrink;

  Map<String, dynamic> entreeOptions = {};
  String category = "";
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    steakCook = "Medium";
    selectedBurgerIngredients = [];
    selectedSide = "";
    selectedDrink = "";

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load the entrees_data.txt file from assets
      final String data = await rootBundle.loadString('assets/entrees_data.txt');
      final lines = LineSplitter().convert(data);

      // Parse the data and determine category
      Map<String, dynamic> options = _parseEntreeData(lines);
      String detectedCategory = _getCategory(widget.entreeName, options);

      setState(() {
        entreeOptions = options;
        category = detectedCategory;
        steakCook = options['steakCook']?.first ?? 'Medium';
        selectedBurgerIngredients = List<String>.from(options['burgerIngredients'] ?? []);
        selectedSide = options['sides']?.first ?? '';
        selectedDrink = options['drinks']?.first ?? '';
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load customization options: $e";
      });
    }
  }

  String _getCategory(String entreeName, Map<String, dynamic> options) {
    // Detect the category of the selected entree
    if (options['steaks']?.contains(entreeName) == true) return 'Steaks';
    if (options['burgers']?.contains(entreeName) == true) return 'Burgers';
    if (options['sandwiches']?.contains(entreeName) == true) return 'Sandwiches';
    return '';
  }

Map<String, dynamic> _parseEntreeData(List<String> lines) {
  Map<String, dynamic> options = {
    'steaks': [],
    'burgerIngredients': [],
    'sandwiches': [],
    'sides': [],
    'drinks': [],
    'steakCook': []
  };

  String currentCategory = "";
  for (String line in lines) {
    if (line.startsWith('[') && line.endsWith(']')) {
      currentCategory = line.substring(1, line.length - 1).toLowerCase();
    } else if (line.trim().isNotEmpty) {
      final parts = line.split(':');

      // Ensure the category's list is initialized
      if (options[currentCategory] == null) {
        options[currentCategory] = [];
      }

      switch (currentCategory) {
        case 'steaks':
          (options['steaks'] as List).add(parts[0]); // Add the steak name
          options['steakCook'] = parts[1].split(',').map((s) => s.trim()).toList();
          break;
        case 'burgers':
          (options['burgers'] as List).add(parts[0]); // Add the burger name
          options['burgerIngredients'] = parts[1].split(',').map((s) => s.trim()).toList();
          break;
        case 'sandwiches':
          (options['sandwiches'] as List).add(parts[0]); // Add the sandwich name
          // Add sandwich ingredients if present
          if (parts.length > 1 && parts[1].isNotEmpty) {
            options['burgerIngredients'] = [
              ...options['burgerIngredients'],
              ...parts[1].split(',').map((s) => s.trim())
            ].toSet().toList(); // Remove duplicates
          }
          break;
        case 'sides':
          (options['sides'] as List).add(parts[0]); // Add the side
          break;
        case 'drinks':
          (options['drinks'] as List).add(parts[0]); // Add the drink
          break;
      }
    }
  }
  return options;
}



  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Customize ${widget.entreeName} - \$${widget.price}'),
        ),
        body: Center(
          child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 18)),
        ),
      );
    }

    if (entreeOptions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Customize ${widget.entreeName} - \$${widget.price}'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Customize ${widget.entreeName} - \$${widget.price}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category == 'Steaks' && entreeOptions['steakCook'] != null) ...[
                Text("Select Steak Cooking Level", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: (entreeOptions['steakCook'] as List<dynamic>).cast<String>().map((option) {
                    return ChoiceChip(
                      label: Text(option),
                      selected: steakCook == option,
                      onSelected: (selected) {
                        setState(() {
                          steakCook = option;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ],
              if ((category == 'Burgers' || category == 'Sandwiches') && entreeOptions['burgerIngredients'] != null) ...[
                Text("Customize Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Column(
                  children: (entreeOptions['burgerIngredients'] as List<dynamic>).cast<String>().map((ingredient) {
                    return CheckboxListTile(
                      title: Text(ingredient),
                      value: selectedBurgerIngredients.contains(ingredient),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedBurgerIngredients.add(ingredient);
                          } else {
                            selectedBurgerIngredients.remove(ingredient);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ],
              if (entreeOptions['sides'] != null) ...[
                Text("Select a Side", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: (entreeOptions['sides'] as List<dynamic>).cast<String>().map((side) {
                    return ChoiceChip(
                      label: Text(side),
                      selected: selectedSide == side,
                      onSelected: (selected) {
                        setState(() {
                          selectedSide = side;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ],
              if (entreeOptions['drinks'] != null) ...[
                Text("Select a Drink", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: (entreeOptions['drinks'] as List<dynamic>).cast<String>().map((drink) {
                    return ChoiceChip(
                      label: Text(drink),
                      selected: selectedDrink == drink,
                      onSelected: (selected) {
                        setState(() {
                          selectedDrink = drink;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'steakCook': steakCook,
                      'selectedBurgerIngredients': selectedBurgerIngredients,
                      'selectedSide': selectedSide,
                      'selectedDrink': selectedDrink,
                    });
                  },
                  child: Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
