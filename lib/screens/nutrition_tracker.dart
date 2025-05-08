import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:collection/collection.dart';

class NutritionTrackerScreen extends StatefulWidget {
  const NutritionTrackerScreen({super.key});

  @override
  _NutritionTrackerScreenState createState() => _NutritionTrackerScreenState();
}

class _NutritionTrackerScreenState extends State<NutritionTrackerScreen> {
  List<Map<String, dynamic>> _foodDatabase = [];
  List<Map<String, dynamic>> _foodItems = [];
  String? _selectedFood;
  int _servings = 1;
  double _totalCalories = 0;
  Map<String, double> _totalNutrients = {
    'Calories': 0,
    'Protein': 0,
    'Carbs': 0,
    'Fat': 0,
    'Sugar': 0,
    'Calcium': 0,
    'Fiber': 0,
    'Sodium': 0,
  };
  bool _isLoading = true;
  String? _errorMessage;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFoodList = [];
  bool _showNotFoundMessage = false;

  @override
  void initState() {
    super.initState();
    _loadFoodDatabase();
    _searchController.addListener(_filterFoodItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodDatabase() async {
    try {
      final data = await rootBundle.loadString('lib/screens/food1.csv');
      final lines = const LineSplitter().convert(data);

      if (lines.isEmpty) {
        throw Exception('CSV file is empty');
      }

      final headers = lines[0].split(',').map((h) => h.trim()).toList();
      final foodData = <Map<String, dynamic>>[];

      for (var i = 1; i < lines.length; i++) {
        final row = lines[i];
        final regex = RegExp(r'"(?:[^"]|"")*"|[^,]+');
        final matches = regex.allMatches(row);
        final values =
            matches.map((m) => m.group(0)?.replaceAll('"', '') ?? '').toList();

        if (values.length != headers.length) continue;

        final foodItem = <String, dynamic>{};
        for (var j = 0; j < headers.length; j++) {
          foodItem[headers[j]] = values[j].trim();
        }
        foodData.add(foodItem);
      }

      setState(() {
        _foodDatabase = foodData;
        _filteredFoodList = foodData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load food database: ${e.toString()}';
      });
    }
  }

  void _filterFoodItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoodList = _foodDatabase.where((item) {
        final foodName = item['Shrt_Desc'].toString().toLowerCase();
        return foodName.contains(query);
      }).toList();

      // Check if the current text doesn't match any food item
      if (query.isNotEmpty && _filteredFoodList.isEmpty) {
        _showNotFoundMessage = true;
        _selectedFood = null; // Clear selection if no match
      } else {
        _showNotFoundMessage = false;
      }
    });
  }

  void _addFoodItem() {
    if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a food item from the list')),
      );
      return;
    }

    final food = _foodDatabase.firstWhereOrNull(
      (item) => item['Shrt_Desc'] == _selectedFood,
    );

    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected food not found in database')),
      );
      return;
    }

    final nutrients = {
      'Calories': _parseNutrientValue(food['Energ_Kcal']),
      'Protein': _parseNutrientValue(food['Protein_(g)']),
      'Carbs': _parseNutrientValue(food['Carbohydrt_(g)']),
      'Fat': _parseNutrientValue(food['Lipid_Tot_(g)']),
      'Sugar': _parseNutrientValue(food['Sugar_Tot_(g)']),
      'Calcium': _parseNutrientValue(food['Calcium_(mg)']),
      'Fiber': _parseNutrientValue(food['Fiber_TD_(g)']),
      'Sodium': _parseNutrientValue(food['Sodium_(mg)']),
    };

    setState(() {
      _foodItems.add({
        'name': _selectedFood!,
        'servings': _servings,
        'nutrients': nutrients,
      });
      _updateTotals();
      _selectedFood = null;
      _searchController.clear();
      _showNotFoundMessage = false;
    });
  }

  double _parseNutrientValue(dynamic value) {
    if (value == null || value.toString().isEmpty) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0;
  }

  void _updateTotals() {
    _totalCalories = 0;
    _totalNutrients = _totalNutrients.map((key, value) => MapEntry(key, 0.0));

    for (var item in _foodItems) {
      final servings = item['servings'] as int;
      final nutrients = item['nutrients'] as Map<String, double>;

      _totalCalories += nutrients['Calories']! * servings;

      for (var nutrient in nutrients.entries) {
        _totalNutrients[nutrient.key] =
            (_totalNutrients[nutrient.key] ?? 0) + (nutrient.value * servings);
      }
    }
  }

  void _resetTracker() {
    setState(() {
      _foodItems.clear();
      _selectedFood = null;
      _servings = 1;
      _totalCalories = 0;
      _totalNutrients = _totalNutrients.map((key, value) => MapEntry(key, 0.0));
      _searchController.clear();
      _showNotFoundMessage = false;
    });
  }

  void _removeFoodItem(int index) {
    setState(() {
      _foodItems.removeAt(index);
      _updateTotals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.green.shade600],
            ),
          ),
        ),
        elevation: 10,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                'Add Food Items',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Autocomplete<String>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return const Iterable<String>.empty();
                                      }
                                      return _filteredFoodList
                                          .map((item) =>
                                              item['Shrt_Desc'].toString())
                                          .where((item) => item
                                              .toLowerCase()
                                              .contains(textEditingValue.text
                                                  .toLowerCase()));
                                    },
                                    onSelected: (String selection) {
                                      setState(() {
                                        _selectedFood = selection;
                                        _showNotFoundMessage = false;
                                      });
                                    },
                                    fieldViewBuilder: (
                                      BuildContext context,
                                      TextEditingController controller,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted,
                                    ) {
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Search and select food',
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value.isEmpty) {
                                              _showNotFoundMessage = false;
                                            }
                                          });
                                        },
                                      );
                                    },
                                    optionsViewBuilder: (
                                      BuildContext context,
                                      AutocompleteOnSelected<String> onSelected,
                                      Iterable<String> options,
                                    ) {
                                      return Align(
                                        alignment: Alignment.topLeft,
                                        child: Material(
                                          elevation: 4.0,
                                          child: SizedBox(
                                            height: 200.0,
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: options.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final String option =
                                                    options.elementAt(index);
                                                return InkWell(
                                                  onTap: () {
                                                    onSelected(option);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Text(option),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (_showNotFoundMessage)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Food not found in database. Please select from the list.',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const Text('Servings:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Slider(
                                      value: _servings.toDouble(),
                                      min: 1,
                                      max: 10,
                                      divisions: 9,
                                      label: _servings.toString(),
                                      activeColor: Colors.blue.shade600,
                                      inactiveColor: Colors.grey.shade300,
                                      onChanged: (double value) {
                                        setState(() {
                                          _servings = value.toInt();
                                        });
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _servings.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _addFoodItem,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        backgroundColor: Colors.blue.shade600,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      icon: const Icon(Icons.add,
                                          color: Colors.white),
                                      label: const Text(
                                        'Add Food',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _resetTracker,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        backgroundColor: Colors.grey.shade600,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      icon: const Icon(Icons.refresh,
                                          color: Colors.white),
                                      label: const Text(
                                        'Reset',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_foodItems.isNotEmpty) ...[
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  'Nutrition Summary',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildNutritionCard(
                                  'Total Calories',
                                  '${_totalCalories.toStringAsFixed(1)} kcal',
                                  Icons.local_fire_department,
                                  Colors.orange,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNutritionCard(
                                        'Protein',
                                        '${_totalNutrients['Protein']?.toStringAsFixed(1) ?? '0'}g',
                                        Icons.fitness_center,
                                        Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildNutritionCard(
                                        'Carbs',
                                        '${_totalNutrients['Carbs']?.toStringAsFixed(1) ?? '0'}g',
                                        Icons.grain,
                                        Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildNutritionCard(
                                        'Fat',
                                        '${_totalNutrients['Fat']?.toStringAsFixed(1) ?? '0'}g',
                                        Icons.water_drop,
                                        Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildNutritionCard(
                                        'Sugar',
                                        '${_totalNutrients['Sugar']?.toStringAsFixed(1) ?? '0'}g',
                                        Icons.cake,
                                        Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Food Items',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    Text(
                                      'Total: ${_foodItems.length}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _foodItems.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = _foodItems[index];
                                    final nutrients = item['nutrients']
                                        as Map<String, double>;
                                    return Dismissible(
                                      key: Key(item['name'] + index.toString()),
                                      background: Container(
                                        color: Colors.red.shade100,
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) =>
                                          _removeFoodItem(index),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              item['servings'].toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          item['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        subtitle: Text(
                                          '${nutrients['Calories']?.toStringAsFixed(1) ?? '0'} kcal',
                                          style: TextStyle(
                                              color: Colors.grey.shade600),
                                        ),
                                        trailing: Text(
                                          '${nutrients['Protein']?.toStringAsFixed(1) ?? '0'}g protein',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildNutritionCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
