import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BMICalculatorScreen extends StatefulWidget {
  final String userEmail;

  const BMICalculatorScreen({
    super.key,
    required this.userEmail,
  });

  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();

  String _gender = 'male';
  double? _bmi;
  String _category = '';
  List<Map<String, dynamic>> _history = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/bmi-history?email=${widget.userEmail}'),
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
        Uri.parse('http://localhost:3000/save-bmi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.userEmail,
          'age': int.parse(_ageController.text),
          'gender': _gender,
          'weight': double.parse(_weightController.text),
          'heightFeet': int.parse(_heightFeetController.text),
          'heightInches': int.parse(_heightInchesController.text),
          'bmi': _bmi,
          'category': _category,
        }),
      );
      if (response.statusCode == 201) {
        _fetchHistory();
      }
    } catch (e) {
      // Error handling is done in the calculate function
    }
  }

  void _calculateBMI() {
    final age = int.tryParse(_ageController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final heightFeet = int.tryParse(_heightFeetController.text) ?? 0;
    final heightInches = int.tryParse(_heightInchesController.text) ?? 0;

    // Input validation
    if (age <= 0 || age > 120) {
      _showError('Please enter a valid age (1-120)');
      return;
    }
    if (weight <= 0 || weight > 300) {
      _showError('Please enter a valid weight (1-300 kg)');
      return;
    }
    if (heightFeet <= 0 || heightFeet > 8) {
      _showError('Please enter valid feet (1-8 ft)');
      return;
    }
    if (heightInches < 0 || heightInches >= 12) {
      _showError('Please enter valid inches (0-11 in)');
      return;
    }
    if (heightFeet == 0 && heightInches == 0) {
      _showError('Height cannot be zero');
      return;
    }

    final heightInMeters = (heightFeet * 0.3048) + (heightInches * 0.0254);
    final calculatedBMI = weight / (heightInMeters * heightInMeters);

    String category;
    if (calculatedBMI < 18.5) {
      category = "Underweight";
    } else if (calculatedBMI < 24.9) {
      category = "Normal weight";
    } else if (calculatedBMI < 29.9) {
      category = "Overweight";
    } else if (calculatedBMI < 35) {
      category = "Obese";
    } else {
      category = "Morbid obesity";
    }

    setState(() {
      _bmi = calculatedBMI;
      _category = category;
    });

    _saveRecord();
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
        title: const Text('BMI Calculator'),
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
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age (1-120)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
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
                    const SizedBox(height: 15),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight (1-300 kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _heightFeetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Height (1-8 ft)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.height),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _heightInchesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Height (0-11 in)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Calculate BMI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (_bmi != null) ...[
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
                            color: _getCategoryColor(),
                            width: 5,
                          ),
                        ),
                        child: Text(
                          _bmi!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _category,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getBMIAdvice(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
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
                                        'BMI: ${record['bmi'].toStringAsFixed(1)}',
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
                                    'Category: ${record['category']}',
                                    style: TextStyle(
                                      color: _getCategoryColorFromBMI(
                                          record['bmi']),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Weight: ${record['weight']} kg | Height: ${record['heightFeet']}ft ${record['heightInches']}in',
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

  Color _getCategoryColor() {
    if (_bmi == null) return Colors.black;
    if (_bmi! < 18.5) return Colors.blue;
    if (_bmi! < 24.9) return const Color(0xFF4CAF50);
    if (_bmi! < 29.9) return Colors.orange;
    if (_bmi! < 35) return Colors.red;
    return Colors.deepPurple;
  }

  Color _getCategoryColorFromBMI(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24.9) return const Color(0xFF4CAF50);
    if (bmi < 29.9) return Colors.orange;
    if (bmi < 35) return Colors.red;
    return Colors.deepPurple;
  }

  String _getBMIAdvice() {
    if (_bmi == null) return '';
    if (_bmi! < 18.5)
      return 'Consider consulting a nutritionist to gain weight healthily';
    if (_bmi! < 24.9) return 'Great! Maintain your healthy lifestyle';
    if (_bmi! < 29.9) return 'Regular exercise and balanced diet can help';
    if (_bmi! < 35) return 'Consult a health professional for guidance';
    return 'Please seek medical advice for a health plan';
  }
}
