import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/run_provider.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final List<String> _trainingPlans = [
    'Beginner 5K Plan',
    'Intermediate 10K Plan',
    'Advanced Half Marathon Plan',
    'Custom Plan',
  ];

  String? _selectedPlan;
  bool _isGeneratingPlan = false;

  final Map<String, List<String>> _coachingTips = {
    'speed': [
      'Try interval training to increase your speed',
      'Focus on proper form to improve efficiency',
      'Add strength training to your routine for better power',
      'Short, fast runs can help increase your top speed',
    ],
    'endurance': [
      'Gradually increase your long run distance each week',
      'Maintain a conversational pace on long runs',
      'Add one longer run each week to build endurance',
      'Cross-training can help build overall stamina',
    ],
    'recovery': [
      'Make sure you\'re getting adequate sleep',
      'Consider active recovery like walking or swimming',
      'Proper nutrition is essential for recovery',
      'Don\'t skip your rest days - they\'re when you get stronger',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final runProvider = Provider.of<RunProvider>(context);
    final pastRuns = runProvider.pastRuns;

    // Analysis of past runs would happen here
    final hasEnoughData = pastRuns.length >= 3;
    final averagePace = hasEnoughData
        ? pastRuns
                .map((run) => run.duration.inMinutes / run.distance)
                .reduce((a, b) => a + b) /
            pastRuns.length
        : null;
    final averageDistance = hasEnoughData
        ? pastRuns.map((run) => run.distance).reduce((a, b) => a + b) /
            pastRuns.length
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE0E0E0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card with running insights
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF1976D2),
                            radius: 24,
                            child: Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Coach',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Your personalized running assistant',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (!hasEnoughData)
                        const Text(
                          'Complete more runs to get personalized recommendations!',
                          style: TextStyle(fontSize: 16),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Based on your running history:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Average pace: ${averagePace!.toStringAsFixed(1)} min/km',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Average distance: ${averageDistance!.toStringAsFixed(2)} km',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Consistency: ${pastRuns.length} runs logged',
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Training plans section
              const Text(
                'Training Plans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select a training plan:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        value: _selectedPlan,
                        hint: const Text('Choose a plan'),
                        onChanged: (value) {
                          setState(() {
                            _selectedPlan = value;
                          });
                        },
                        items: _trainingPlans.map((plan) {
                          return DropdownMenuItem<String>(
                            value: plan,
                            child: Text(plan),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedPlan == null
                              ? null
                              : () {
                                  setState(() {
                                    _isGeneratingPlan = true;
                                  });

                                  // Simulate AI processing
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      setState(() {
                                        _isGeneratingPlan = false;
                                      });

                                      // Show success dialog
                                      _showPlanGeneratedDialog();
                                    },
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isGeneratingPlan
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Generate Plan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Coaching tips section
              const Text(
                'Coaching Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  children: [
                    _buildTipCard(
                      'Improve Your Speed',
                      _coachingTips['speed']![0],
                      Icons.speed,
                      const Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 8),
                    _buildTipCard(
                      'Build Endurance',
                      _coachingTips['endurance']![0],
                      Icons.trending_up,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildTipCard(
                      'Recovery Matters',
                      _coachingTips['recovery']![0],
                      Icons.nightlight_round,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String tip, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 24,
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanGeneratedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Training Plan Generated'),
        content: Text(
          'Your $_selectedPlan has been generated! Check the Training tab to see your schedule.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
