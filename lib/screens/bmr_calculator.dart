import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BMRCalculatorScreen extends StatefulWidget {
  final String userEmail;

  const BMRCalculatorScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<BMRCalculatorScreen> createState() => _BMRCalculatorScreenState();
}

class _BMRCalculatorScreenState extends State<BMRCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _gender = 'male';
  double _bmr = 0;
  Map<String, double> _activityLevels = {
    'sedentary': 0,
    'light': 0,
    'moderate': 0,
    'veryActive': 0,
    'superActive': 0,
  };
  bool _showResults = false;
  List<Map<String, dynamic>> _history = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/bmr-history?email=${widget.userEmail}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _history =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load history'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _saveRecord() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/save-bmr'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.userEmail,
          'age': int.parse(_ageController.text),
          'gender': _gender,
          'weight': double.parse(_weightController.text),
          'height': double.parse(_heightController.text),
          'bmr': _bmr,
          'activityLevels': _activityLevels,
        }),
      );
      if (response.statusCode == 201) {
        _fetchHistory();
      }
    } catch (e) {
      // Error handling is done in the calculate function
    }
  }

  void _calculateBMR() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final age = int.tryParse(_ageController.text) ?? 0;

    // Input validation
    if (weight <= 0 || weight > 300) {
      _showError('Please enter a valid weight (1-300 kg)');
      return;
    }
    if (height <= 0 || height > 250) {
      _showError('Please enter a valid height (1-250 cm)');
      return;
    }
    if (age <= 0 || age > 120) {
      _showError('Please enter a valid age (1-120)');
      return;
    }

    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr = 10 * weight + 6.25 * height - 5 * age;
    bmr += _gender == 'male' ? 5 : -161;

    // Calculate activity levels
    final activityLevels = {
      'sedentary': bmr * 1.2,
      'light': bmr * 1.375,
      'moderate': bmr * 1.55,
      'veryActive': bmr * 1.725,
      'superActive': bmr * 1.9,
    };

    setState(() {
      _bmr = bmr;
      _activityLevels = activityLevels;
      _showResults = true;
    });

    _saveRecord();
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _weightController.clear();
      _heightController.clear();
      _ageController.clear();
      _gender = 'male';
      _bmr = 0;
      _activityLevels = {
        'sedentary': 0,
        'light': 0,
        'moderate': 0,
        'veryActive': 0,
        'superActive': 0,
      };
      _showResults = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMR Calculator'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D5DED), Color(0xFF4CAF50)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Enter Your Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Weight (1-300 kg)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.monitor_weight),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          final weight = double.tryParse(value) ?? 0;
                          if (weight <= 0 || weight > 300) {
                            return 'Enter weight between 1-300 kg';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Height (1-250 cm)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.height),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter height';
                          }
                          final height = double.tryParse(value) ?? 0;
                          if (height <= 0 || height > 250) {
                            return 'Enter height between 1-250 cm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Age (1-120)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter age';
                          }
                          final age = int.tryParse(value) ?? 0;
                          if (age <= 0 || age > 120) {
                            return 'Enter age between 1-120';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.transgender),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Female'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _resetForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Reset'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _calculateBMR();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: const Text(
                              'Calculate',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showResults) ...[
              const SizedBox(height: 30),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Your Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _bmr.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const Text(
                              'kcal/day',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Daily Calorie Needs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildActivityLevelCard(
                        'Sedentary',
                        'Little to no exercise',
                        _activityLevels['sedentary']!,
                      ),
                      _buildActivityLevelCard(
                        'Lightly Active',
                        'Light exercise or sports (1-3 days/week)',
                        _activityLevels['light']!,
                      ),
                      _buildActivityLevelCard(
                        'Moderately Active',
                        'Moderate exercise or sports (4-5 days/week)',
                        _activityLevels['moderate']!,
                      ),
                      _buildActivityLevelCard(
                        'Very Active',
                        'Hard exercise or sports (6-7 days/week)',
                        _activityLevels['veryActive']!,
                      ),
                      _buildActivityLevelCard(
                        'Super Active',
                        'Very hard exercise, physical job, or training twice a day',
                        _activityLevels['superActive']!,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              'History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _isLoadingHistory
                ? const CircularProgressIndicator()
                : _history.isEmpty
                    ? const Text('No history yet')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final record = _history[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'BMR: ${record['bmr'].toStringAsFixed(0)} kcal',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(record['date']),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Weight: ${record['weight']} kg | Height: ${record['height']} cm',
                                  ),
                                  Text(
                                    'Maintenance calories: ${record['activityLevels']['moderate'].toStringAsFixed(0)} kcal',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildActivityLevelCard(
      String title, String description, double value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
