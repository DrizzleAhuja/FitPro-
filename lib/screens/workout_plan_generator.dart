import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class WorkoutPlanGeneratorScreen extends StatefulWidget {
  final String userEmail; // Add this to receive user email

  const WorkoutPlanGeneratorScreen({super.key, required this.userEmail});

  @override
  _WorkoutPlanGeneratorScreenState createState() =>
      _WorkoutPlanGeneratorScreenState();
}

class _WorkoutPlanGeneratorScreenState
    extends State<WorkoutPlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fitnessGoal = 'Lose Weight';
  String _gender = 'Male';
  String _trainingMethod = 'Resistance Training';
  String _workoutType = 'Weighted';
  String _strengthLevel = 'Beginner';
  String _generatedPlan = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _workoutHistory = []; // To store workout history
  bool _showHistory = false; // To toggle history view

  final List<String> _fitnessGoals = [
    'Lose Weight',
    'Gain Muscle',
    'Improve Endurance',
    'General Fitness'
  ];

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _trainingMethods = [
    'Resistance Training',
    'Resistance + Cardio',
    'Meal Plan Only',
    'Custom Routine'
  ];
  final List<String> _workoutTypes = ['Weighted', 'Bodyweight', 'No Equipment'];
  final List<String> _strengthLevels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _fetchWorkoutHistory(); // Fetch history when screen loads
  }

  Future<void> _fetchWorkoutHistory() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/workout-history?email=${widget.userEmail}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _workoutHistory = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('Error fetching workout history: $e');
    }
  }

  Future<void> _savePlanToDatabase() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/save-workout-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.userEmail,
          'fitnessGoal': _fitnessGoal,
          'gender': _gender,
          'trainingMethod': _trainingMethod,
          'workoutType': _workoutType,
          'strengthLevel': _strengthLevel,
          'planContent': _generatedPlan,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout plan saved successfully!')),
        );
        _fetchWorkoutHistory(); // Refresh history after saving
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save plan: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving plan: $e')),
      );
    }
  }

  Future<void> _generatePlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _generatedPlan = '';
    });

    try {
      const String apiKey = "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";
      const String apiUrl =
          "https://api-inference.huggingface.co/models/mistralai/Mixtral-8x7B-Instruct-v0.1";

      final prompt = '''
Create a detailed $_fitnessGoal workout plan for a $_gender at $_strengthLevel level.
Training method: $_trainingMethod. Workout type: $_workoutType.

Provide the response in Markdown format with the following structure:

# Workout Plan for [Goal]

**Gender:** $_gender  
**Level:** $_strengthLevel  
**Training Method:** $_trainingMethod  
**Workout Type:** $_workoutType  

## Weekly Overview
- [Brief description of weekly structure]
- [Number of workout days per week]
- [Cardio recommendations if applicable]

## Detailed Workout Plan

### Day 1: [Muscle Group/Focus]
**Focus:** [Primary muscles worked]  
**Duration:** [Workout duration]  
**Equipment Needed:** [List equipment]  

#### Exercises:
1. **Exercise Name**  
   - Sets: 3-4  
   - Reps: 8-12  
   - Rest: 60-90 sec  
   - Notes: [Technique tips or variations]  

2. **Exercise Name**  
   - Sets: 3  
   - Reps: 10-15  
   - Rest: 45-60 sec  

### Day 2: [Muscle Group/Focus]
[Same structure as Day 1]

## Progression Plan
- Weekly progression strategy
- How to increase difficulty
- When to add weight/reps/sets

## Additional Notes
- Warm-up recommendations (5-10 minutes)
- Cool-down suggestions (stretching routine)
- Recovery tips (rest days, hydration, sleep)

Make sure:
1. The plan is realistic for a $_strengthLevel
2. Uses $_workoutType equipment
3. Includes specific exercises appropriate for $_gender
4. Provides clear instructions for each exercise
5. Includes rest periods between sets
''';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 2000,
            'temperature': 0.5,
            'return_full_text': false,
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _generatedPlan = responseData[0]?['generated_text']?.trim() ??
              "Could not generate plan. Please try again.";
        });
      } else {
        setState(() {
          _generatedPlan =
              "Error: ${response.statusCode}. Please try again later.";
        });
      }
    } catch (e) {
      setState(() {
        _generatedPlan = "Failed to generate plan: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan Generator'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D5DED), Color(0xFF4CAF50)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.close : Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_showHistory) ...[
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create Your Custom Workout Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdown(
                          'Fitness Goal',
                          _fitnessGoal,
                          _fitnessGoals,
                          (value) => setState(() => _fitnessGoal = value!),
                        ),
                        const SizedBox(height: 15),
                        _buildDropdown(
                          'Gender',
                          _gender,
                          _genders,
                          (value) => setState(() => _gender = value!),
                        ),
                        const SizedBox(height: 15),
                        _buildDropdown(
                          'Training Method',
                          _trainingMethod,
                          _trainingMethods,
                          (value) => setState(() => _trainingMethod = value!),
                        ),
                        const SizedBox(height: 15),
                        _buildDropdown(
                          'Workout Type',
                          _workoutType,
                          _workoutTypes,
                          (value) => setState(() => _workoutType = value!),
                        ),
                        const SizedBox(height: 15),
                        _buildDropdown(
                          'Strength Level',
                          _strengthLevel,
                          _strengthLevels,
                          (value) => setState(() => _strengthLevel = value!),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _generatePlan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Generate Workout Plan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_generatedPlan.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Your Custom Workout Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: MarkdownBody(
                            data: _generatedPlan,
                            styleSheet: MarkdownStyleSheet(
                              h1: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                              h2: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                              h3: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                              h4: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[500],
                              ),
                              p: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                              listBullet: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                              strong: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _savePlanToDatabase,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Save This Plan',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Your Workout History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      if (_workoutHistory.isEmpty)
                        const Text('No workout plans saved yet.')
                      else
                        ..._workoutHistory.map((plan) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: ExpansionTile(
                              title: Text(
                                '${plan['fitnessGoal']} - ${plan['date'].toString().substring(0, 10)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${plan['trainingMethod']} (${plan['workoutType']})',
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: MarkdownBody(
                                    data: plan['planContent'],
                                    styleSheet: MarkdownStyleSheet(
                                      h1: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                      h2: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                      p: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          isExpanded: true,
        ),
      ],
    );
  }
}
