import 'package:flutter/material.dart';

class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exercise Library'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Cardio'),
              Tab(text: 'Strength'),
              Tab(text: 'Flexibility'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildExerciseList(allExercises),
            _buildExerciseList(cardioExercises),
            _buildExerciseList(strengthExercises),
            _buildExerciseList(flexibilityExercises),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList(List<Exercise> exercises) {
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ExpansionTile(
          leading: Icon(
            exercise.type == 'Cardio'
                ? Icons.directions_run
                : exercise.type == 'Strength'
                    ? Icons.fitness_center
                    : Icons.self_improvement,
            color: exercise.type == 'Cardio'
                ? Colors.red
                : exercise.type == 'Strength'
                    ? Colors.blue
                    : Colors.green,
          ),
          title: Text(exercise.name),
          subtitle: Text(exercise.type),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exercise.imageUrl.isNotEmpty)
                    Image.network(
                      exercise.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    exercise.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (exercise.videoUrl.isNotEmpty)
                    ElevatedButton(
                      onPressed: () =>
                          _showVideoDialog(context, exercise.videoUrl),
                      child: const Text('Watch Video Demonstration'),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showVideoDialog(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Video'),
        content: const Text('This would show the exercise video in a real app'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class Exercise {
  final String name;
  final String type;
  final String description;
  final String imageUrl;
  final String videoUrl;

  Exercise({
    required this.name,
    required this.type,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
  });
}

// Sample exercise data
final List<Exercise> allExercises = [
  Exercise(
    name: 'Running',
    type: 'Cardio',
    description:
        'Running is a great cardiovascular exercise that improves heart health and burns calories.',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5',
    videoUrl: 'https://example.com/running',
  ),
  Exercise(
    name: 'Push-ups',
    type: 'Strength',
    description:
        'Push-ups work the chest, shoulders, triceps, and core muscles.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://example.com/pushups',
  ),
  Exercise(
    name: 'Squats',
    type: 'Strength',
    description: 'Squats target the quadriceps, hamstrings, glutes, and core.',
    imageUrl: 'https://images.unsplash.com/photo-1534258936925-c58bed479fcb',
    videoUrl: 'https://example.com/squats',
  ),
  Exercise(
    name: 'Yoga',
    type: 'Flexibility',
    description: 'Yoga improves flexibility, balance, and mental focus.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://example.com/yoga',
  ),
  Exercise(
    name: 'Cycling',
    type: 'Cardio',
    description:
        'Cycling is a low-impact cardio exercise that strengthens the legs and improves endurance.',
    imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e',
    videoUrl: 'https://example.com/cycling',
  ),
];

final List<Exercise> cardioExercises =
    allExercises.where((e) => e.type == 'Cardio').toList();
final List<Exercise> strengthExercises =
    allExercises.where((e) => e.type == 'Strength').toList();
final List<Exercise> flexibilityExercises =
    allExercises.where((e) => e.type == 'Flexibility').toList();
