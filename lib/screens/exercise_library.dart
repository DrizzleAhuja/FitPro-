import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

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
        return Card(
          margin: const EdgeInsets.all(8),
          child: ExpansionTile(
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
            title: Text(
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(exercise.type),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exercise.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          exercise.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (exercise.musclesWorked.isNotEmpty) ...[
                      Text(
                        'Muscles Worked:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.musclesWorked,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (exercise.videoUrl.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_fill),
                          label: const Text('Watch Video'),
                          onPressed: () async {
                            final url = Uri.parse(exercise.videoUrl);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not launch video'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Exercise {
  final String name;
  final String type;
  final String description;
  final String musclesWorked;
  final String imageUrl;
  final String videoUrl;

  Exercise({
    required this.name,
    required this.type,
    required this.description,
    required this.musclesWorked,
    required this.imageUrl,
    required this.videoUrl,
    required String benefits,
  });
}

// Comprehensive list of exercises with real video links
final List<Exercise> allExercises = [
  // Cardio Exercises
  Exercise(
    name: 'Running',
    type: 'Cardio',
    description:
        'Running is a high-impact cardiovascular exercise that improves heart health, burns calories, and builds endurance. Start with short distances and gradually increase your pace and duration.',
    musclesWorked: 'Quadriceps, Hamstrings, Glutes, Calves, Core',
    benefits:
        'Improves cardiovascular health, burns calories, strengthens bones, reduces stress, and boosts mood.',
    imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5',
    videoUrl: 'https://www.youtube.com/shorts/4vYYHAcMIiE',
  ),
  Exercise(
    name: 'Cycling',
    type: 'Cardio',
    description:
        'Cycling is a low-impact cardio exercise that strengthens the legs and improves endurance. Can be done outdoors or on a stationary bike. Adjust resistance to increase intensity.',
    musclesWorked: 'Quadriceps, Hamstrings, Glutes, Calves, Core',
    benefits:
        'Builds leg strength, improves joint mobility, increases stamina, and is easy on the joints.',
    imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e',
    videoUrl: 'https://www.youtube.com/shorts/DM037fHo-xs',
  ),
  Exercise(
    name: 'Jump Rope',
    type: 'Cardio',
    description:
        'An excellent cardiovascular exercise that improves coordination, agility, and burns calories quickly. Start with short intervals of 30 seconds and gradually increase duration.',
    musclesWorked: 'Calves, Shoulders, Core, Cardiovascular System',
    benefits:
        'Improves coordination, burns calories efficiently, enhances footwork, and can be done anywhere.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=1BZM2Vre5oc',
  ),
  Exercise(
    name: 'Swimming',
    type: 'Cardio',
    description:
        'A full-body workout that improves cardiovascular health and builds endurance with minimal joint impact. Different strokes target different muscle groups.',
    musclesWorked: 'Full body, especially shoulders, back, and legs',
    benefits:
        'Low-impact, improves lung capacity, works all major muscle groups, and is great for recovery.',
    imageUrl: 'https://images.unsplash.com/photo-1530549387789-4c1017266635',
    videoUrl: 'https://www.youtube.com/watch?v=pFN2n7CRqhw',
  ),
  Exercise(
    name: 'Rowing',
    type: 'Cardio',
    description:
        'A full-body cardio workout that engages both upper and lower body muscles while being low-impact. Maintain proper form to maximize benefits and prevent injury.',
    musclesWorked: 'Legs, Back, Arms, Core, Shoulders',
    benefits:
        'Works 85% of muscles, improves cardiovascular health, builds endurance, and is low-impact.',
    imageUrl: 'https://images.unsplash.com/photo-1593764592116-bfb2a97c642a',
    videoUrl: 'https://www.youtube.com/shorts/A-35F9TR0OA',
  ),
  Exercise(
    name: 'High-Intensity Interval Training (HIIT)',
    type: 'Cardio',
    description:
        'Alternates short bursts of intense exercise with recovery periods. Highly effective for fat burning and cardiovascular improvement in shorter time periods.',
    musclesWorked: 'Full body depending on exercises chosen',
    benefits:
        'Burns calories efficiently, improves cardiovascular health, boosts metabolism, and saves time.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=ml6cT4AZdqI',
  ),
  Exercise(
    name: 'Stair Climbing',
    type: 'Cardio',
    description:
        'An intense lower-body workout that builds endurance and leg strength. Can be done on actual stairs or a stair-climbing machine.',
    musclesWorked: 'Quadriceps, Glutes, Hamstrings, Calves',
    benefits:
        'Builds leg strength, improves cardiovascular health, and burns significant calories.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/shorts/LM9lgFK4mkk',
  ),
  Exercise(
    name: 'Elliptical Training',
    type: 'Cardio',
    description:
        'A low-impact cardio option that mimics running without joint stress. Can be done forward or backward to target different muscles.',
    musclesWorked: 'Quadriceps, Hamstrings, Glutes, Core',
    benefits:
        'Low-impact, works upper and lower body, improves cardiovascular health, and is joint-friendly.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/shorts/qgGEGxGEJPY',
  ),
  Exercise(
    name: 'Boxing',
    type: 'Cardio',
    description:
        'A high-intensity workout that combines cardio with strength training. Improves coordination, agility, and endurance.',
    musclesWorked: 'Shoulders, Arms, Core, Legs',
    benefits:
        'Improves coordination, burns calories, relieves stress, and builds endurance.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/shorts/mpHtpo7CxSc',
  ),
  Exercise(
    name: 'Dancing',
    type: 'Cardio',
    description:
        'A fun way to get cardio exercise that improves coordination and rhythm while burning calories.',
    musclesWorked: 'Full body depending on dance style',
    benefits:
        'Improves coordination, boosts mood, burns calories, and can be done socially.',
    imageUrl: 'https://images.unsplash.com/photo-1547153760-18fc86324498',
    videoUrl:
        'https://www.youtube.com/watch?v=AdqrTg_hpEQ&ab_channel=WalkatHome',
  ),

  // Strength Exercises
  Exercise(
    name: 'Push-ups',
    type: 'Strength',
    description:
        'A fundamental bodyweight exercise that builds upper body strength. Variations include wide grip, diamond, and incline/decline push-ups for different emphasis.',
    musclesWorked: 'Pectorals, Deltoids, Triceps, Core',
    benefits:
        'Builds upper body strength, requires no equipment, improves core stability, and has many variations.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
  ),
  Exercise(
    name: 'Squats',
    type: 'Strength',
    description:
        'The king of lower body exercises that builds leg and core strength. Maintain proper form by keeping knees aligned with toes and back straight.',
    musclesWorked: 'Quadriceps, Hamstrings, Glutes, Core, Lower Back',
    benefits:
        'Builds leg strength, improves mobility, enhances core stability, and boosts athletic performance.',
    imageUrl: 'https://images.unsplash.com/photo-1534258936925-c58bed479fcb',
    videoUrl: 'https://www.youtube.com/watch?v=YaXPRqUwItQ',
  ),
  Exercise(
    name: 'Deadlifts',
    type: 'Strength',
    description:
        'A compound exercise that works the posterior chain. Essential for building overall strength. Keep the bar close to your body and lift with your legs, not your back.',
    musclesWorked: 'Hamstrings, Glutes, Lower Back, Core, Traps',
    benefits:
        'Builds full-body strength, improves posture, enhances grip strength, and boosts athletic performance.',
    imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b',
    videoUrl: 'https://www.youtube.com/watch?v=1ZXobu7JvvE',
  ),
  Exercise(
    name: 'Pull-ups',
    type: 'Strength',
    description:
        'An excellent upper body exercise that develops back and arm strength. Start with assisted variations if needed and gradually progress to full bodyweight.',
    musclesWorked: 'Latissimus Dorsi, Biceps, Rear Deltoids, Rhomboids',
    benefits:
        'Builds back strength, improves grip, enhances upper body definition, and requires minimal equipment.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=eGo4IYlbE5g',
  ),
  Exercise(
    name: 'Bench Press',
    type: 'Strength',
    description:
        'The classic upper body exercise for chest development. Use proper form with a spotter when lifting heavy weights.',
    musclesWorked: 'Pectorals, Deltoids, Triceps',
    benefits:
        'Builds chest strength, improves pushing power, enhances upper body size, and is a standard strength measure.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=vcBig73ojpE',
  ),
  Exercise(
    name: 'Overhead Press',
    type: 'Strength',
    description:
        'A shoulder-dominant exercise that builds upper body strength and stability. Keep your core engaged and avoid arching your back excessively.',
    musclesWorked: 'Deltoids, Triceps, Upper Chest, Core',
    benefits:
        'Builds shoulder strength, improves overhead mobility, enhances core stability, and develops functional strength.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=2yjwXTZQDDI',
  ),
  Exercise(
    name: 'Barbell Rows',
    type: 'Strength',
    description:
        'An excellent back exercise that improves posture and builds thickness in the upper back muscles. Keep your back straight and pull the weight to your waist.',
    musclesWorked: 'Latissimus Dorsi, Rhomboids, Trapezius, Biceps',
    benefits:
        'Improves posture, builds back thickness, enhances pulling strength, and balances pushing exercises.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=FWJR5Ve8bnQ',
  ),
  Exercise(
    name: 'Lunges',
    type: 'Strength',
    description:
        'A unilateral exercise that strengthens the legs and improves balance. Keep your front knee aligned with your ankle and maintain an upright torso.',
    musclesWorked: 'Quadriceps, Hamstrings, Glutes, Core',
    benefits:
        'Builds single-leg strength, improves balance, corrects muscle imbalances, and enhances athletic performance.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=QOVaHwm-Q6U',
  ),
  Exercise(
    name: 'Dips',
    type: 'Strength',
    description:
        'A compound upper body exercise that primarily targets the triceps and chest muscles. Use parallel bars or bench variations.',
    musclesWorked: 'Triceps, Pectorals, Shoulders',
    benefits:
        'Builds upper body strength, requires minimal equipment, improves pushing power, and enhances muscle definition.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=2z8JmcrW-As',
  ),
  Exercise(
    name: 'Plank',
    type: 'Strength',
    description:
        'An isometric core exercise that strengthens the abdominal muscles and improves posture. Maintain a straight line from head to heels without sagging or raising your hips.',
    musclesWorked: 'Core (Rectus Abdominis, Obliques, Transverse Abdominis)',
    benefits:
        'Improves core strength, enhances posture, reduces back pain, and requires no equipment.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=BQu26ABuVS0',
  ),
  Exercise(
    name: 'Romanian Deadlift',
    type: 'Strength',
    description:
        'A variation of the deadlift that emphasizes the hamstrings and glutes. Keep a slight bend in your knees and hinge at the hips while maintaining a neutral spine.',
    musclesWorked: 'Hamstrings, Glutes, Lower Back, Core',
    benefits:
        'Builds posterior chain strength, improves hip hinge mechanics, enhances athletic performance, and reduces injury risk.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=2SHsk9AzdjA',
  ),
  Exercise(
    name: 'Bicep Curls',
    type: 'Strength',
    description:
        'An isolation exercise for the biceps. Can be performed with dumbbells, barbells, or resistance bands. Keep your elbows stationary and avoid swinging.',
    musclesWorked: 'Biceps, Forearms',
    benefits:
        'Builds arm strength, improves muscle definition, enhances grip strength, and is easy to learn.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
  ),
  Exercise(
    name: 'Tricep Dips',
    type: 'Strength',
    description:
        'Targets the triceps using bodyweight. Can be performed on parallel bars or a bench. Keep your elbows close to your body and lower yourself until your upper arms are parallel to the floor.',
    musclesWorked: 'Triceps, Shoulders, Chest',
    benefits:
        'Builds tricep strength, requires minimal equipment, improves pushing power, and enhances arm definition.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=6kALZikXxLc',
  ),
  Exercise(
    name: 'Bulgarian Split Squat',
    type: 'Strength',
    description:
        'An advanced unilateral leg exercise that improves balance and leg strength. Place one foot on a bench behind you and squat with the front leg.',
    musclesWorked: 'Quadriceps, Glutes, Hamstrings, Core',
    benefits:
        'Builds single-leg strength, improves balance, corrects muscle imbalances, and enhances athletic performance.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=2C-uNgKwPLE',
  ),
  Exercise(
    name: 'Farmer\'s Walk',
    type: 'Strength',
    description:
        'A functional exercise that builds grip strength and core stability. Carry heavy weights in each hand while maintaining good posture and walking.',
    musclesWorked: 'Forearms, Traps, Core, Shoulders',
    benefits:
        'Improves grip strength, builds functional strength, enhances core stability, and translates to real-world activities.',
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    videoUrl: 'https://www.youtube.com/watch?v=Fkzk_RqlYig',
  ),

  // Flexibility Exercises
  Exercise(
    name: 'Sun Salutation',
    type: 'Flexibility',
    description:
        'A sequence of 12 yoga poses that flow together to warm up the body, improve flexibility, and calm the mind. Perfect as a morning routine or workout warm-up.',
    musclesWorked: 'Full Body, Especially Spine and Hamstrings',
    benefits:
        'Improves flexibility, warms up the body, enhances circulation, reduces stress, and promotes mindfulness.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://www.youtube.com/shorts/vSPv6tOannI',
  ),
  Exercise(
    name: 'Pilates',
    type: 'Flexibility',
    description:
        'A low-impact exercise method that improves flexibility, strength, and body awareness through controlled movements and focused breathing. Emphasizes core strength and alignment.',
    musclesWorked: 'Core, Back, Glutes, Full Body',
    benefits:
        'Improves posture, enhances flexibility, builds core strength, reduces injury risk, and promotes mind-body connection.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl:
        'https://www.youtube.com/watch?v=C2HX2pNbUCM&ab_channel=MoveWithNicole',
  ),
  Exercise(
    name: 'Hamstring Stretch',
    type: 'Flexibility',
    description:
        'A fundamental stretch to improve flexibility in the back of the legs. Can be done seated or standing. Keep your back straight and hinge at the hips rather than rounding your spine.',
    musclesWorked: 'Hamstrings, Lower Back',
    benefits:
        'Improves hamstring flexibility, reduces lower back tension, enhances mobility, and prevents injuries.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl:
        'https://www.youtube.com/watch?v=T_l0AyZywjU&ab_channel=BupaHealth',
  ),
  Exercise(
    name: 'Shoulder Stretch',
    type: 'Flexibility',
    description:
        'Improves shoulder mobility and flexibility, which is especially important for those who sit at desks or perform overhead activities. Includes cross-body, overhead, and doorway stretches.',
    musclesWorked: 'Deltoids, Rotator Cuff, Upper Back',
    benefits:
        'Improves shoulder mobility, reduces stiffness, enhances posture, and prevents shoulder injuries.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl:
        'https://www.youtube.com/watch?v=6jHsraw2NIk&ab_channel=AskDoctorJo',
  ),
  Exercise(
    name: 'Hip Flexor Stretch',
    type: 'Flexibility',
    description:
        'Essential for those who sit for long periods to relieve tightness in the front of the hips. Perform in a lunge position with one knee on the ground, gently pushing hips forward.',
    musclesWorked: 'Hip Flexors, Quadriceps',
    benefits:
        'Relieves hip tightness, improves posture, reduces lower back pain, and enhances mobility.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl:
        'https://www.youtube.com/watch?v=DXuStgWuJV8&ab_channel=BupaHealth',
  ),
  Exercise(
    name: 'Cat-Cow Stretch',
    type: 'Flexibility',
    description:
        'A gentle flow between two poses that warms up the spine and improves flexibility. Move slowly between arching (cow) and rounding (cat) your back while on hands and knees.',
    musclesWorked: 'Spine, Core, Neck',
    benefits:
        'Improves spinal mobility, relieves back tension, enhances posture, and reduces stress.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://www.youtube.com/watch?v=kqnua4rHVVA',
  ),
  Exercise(
    name: 'Child\'s Pose',
    type: 'Flexibility',
    description:
        'A resting yoga pose that stretches the hips, thighs, and ankles while calming the mind. Kneel with knees wide or together and stretch arms forward, lowering chest toward the floor.',
    musclesWorked: 'Hips, Thighs, Ankles, Lower Back',
    benefits:
        'Relieves back tension, stretches hips, calms the mind, and serves as a resting position between exercises.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://www.youtube.com/watch?v=2MJGg-dUKh0',
  ),
  Exercise(
    name: 'Downward Dog',
    type: 'Flexibility',
    description:
        'A foundational yoga pose that stretches the hamstrings, calves, and shoulders while strengthening the arms and legs. Form an inverted V-shape with your body, pressing heels toward the floor.',
    musclesWorked: 'Hamstrings, Calves, Shoulders, Back',
    benefits:
        'Stretches multiple muscle groups, strengthens upper body, improves circulation, and energizes the body.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://www.youtube.com/shorts/LQmzaAWu58s',
  ),
  Exercise(
    name: 'Seated Forward Bend',
    type: 'Flexibility',
    description:
        'Calms the mind while stretching the spine, shoulders, and hamstrings. Sit with legs extended and hinge at the hips to reach forward, keeping back straight rather than rounded.',
    musclesWorked: 'Hamstrings, Spine, Shoulders',
    benefits:
        'Stretches hamstrings, calms the nervous system, improves posture, and relieves mild backache.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl:
        'https://www.youtube.com/watch?v=QRIKGOUJILs&ab_channel=ViveHealth',
  ),
  Exercise(
    name: 'Pigeon Pose',
    type: 'Flexibility',
    description:
        'A deep hip opener that targets the glutes and hip rotators. From downward dog, bring one knee forward and place it behind your wrist, extending the other leg straight back.',
    musclesWorked: 'Hip Rotators, Glutes, Lower Back',
    benefits:
        'Relieves hip tightness, improves flexibility, reduces lower back tension, and enhances mobility.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://www.youtube.com/shorts/AI5A1PRYX7E',
  ),
  Exercise(
    name: 'Cobra Stretch',
    type: 'Flexibility',
    description:
        'A gentle backbend that stretches the chest and abdomen while strengthening the spine. Lie on your stomach and press your upper body up, keeping hips on the ground.',
    musclesWorked: 'Abdominals, Chest, Spine',
    benefits:
        'Improves spinal flexibility, stretches the chest, strengthens the back, and improves posture.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://www.youtube.com/watch?v=JDcdhTuycOI',
  ),
  Exercise(
    name: 'Butterfly Stretch',
    type: 'Flexibility',
    description:
        'A seated stretch that targets the inner thighs and hips. Sit with soles of feet together and knees bent outward, gently pressing knees toward the floor.',
    musclesWorked: 'Inner Thighs, Hips',
    benefits:
        'Improves hip flexibility, stretches inner thighs, enhances circulation, and is gentle on the joints.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://www.youtube.com/watch?v=4J7kbCmPScQ&ab_channel=Medibank',
  ),
  Exercise(
    name: 'Standing Quad Stretch',
    type: 'Flexibility',
    description:
        'Targets the front of the thighs. Stand on one leg and pull the other foot toward your glutes, keeping knees together and torso upright.',
    musclesWorked: 'Quadriceps, Hip Flexors',
    benefits:
        'Stretches the quads, improves balance, prevents muscle imbalances, and enhances mobility.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl:
        'https://www.youtube.com/watch?v=zi5__zBRzYc&ab_channel=BaptistHealth',
  ),
  Exercise(
    name: 'Neck Stretches',
    type: 'Flexibility',
    description:
        'Gentle movements to relieve tension in the neck and shoulders. Includes side bends, rotations, and chin tucks. Move slowly and avoid jerky motions.',
    musclesWorked: 'Neck, Upper Trapezius, Shoulders',
    benefits:
        'Relieves neck tension, improves mobility, reduces headaches, and counteracts desk posture.',
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://www.youtube.com/shorts/6Tr3GLfySYo',
  ),
];

final List<Exercise> cardioExercises =
    allExercises.where((e) => e.type == 'Cardio').toList();
final List<Exercise> strengthExercises =
    allExercises.where((e) => e.type == 'Strength').toList();
final List<Exercise> flexibilityExercises =
    allExercises.where((e) => e.type == 'Flexibility').toList();
