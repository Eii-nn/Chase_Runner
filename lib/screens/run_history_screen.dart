import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/run.dart';
import '../services/auth_service.dart';
import 'run_details_screen.dart';

class RunHistoryScreen extends StatelessWidget {
  const RunHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Run History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'History'),
              Tab(text: 'Achievements'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHistoryTab(userId),
            _buildAchievementsTab(userId),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(String? userId) {
    if (userId == null) return const Center(child: Text('Please sign in'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('runs')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final runs =
            snapshot.data!.docs.map((doc) => Run.fromFirestore(doc)).toList();

        if (runs.isEmpty) {
          return const Center(child: Text('No runs yet'));
        }

        return ListView.builder(
          itemCount: runs.length,
          itemBuilder: (context, index) {
            final run = runs[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  run.startTime.toString().split(' ')[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Distance: ${(run.distance / 1000).toStringAsFixed(2)} km\n'
                  'Duration: ${run.duration.inMinutes} min\n'
                  'Pace: ${run.averagePace.toStringAsFixed(1)} min/km',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    Text('${run.coinsEarned}'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RunDetailsScreen(run: run),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementsTab(String? userId) {
    if (userId == null) return const Center(child: Text('Please sign in'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('runs')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Collect all achievements
        final achievements = <String, bool>{};
        for (var doc in snapshot.data!.docs) {
          final run = Run.fromFirestore(doc);
          achievements.addAll(Map<String, bool>.from(run.achievements));
        }

        if (achievements.isEmpty) {
          return const Center(child: Text('No achievements yet'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements.entries.elementAt(index);
            return Card(
              color: achievement.value ? Colors.amber : Colors.grey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getAchievementIcon(achievement.key),
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getAchievementTitle(achievement.key),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getAchievementIcon(String achievementKey) {
    switch (achievementKey) {
      case 'distance_5k':
      case 'distance_10k':
        return Icons.directions_run;
      case 'duration_30min':
      case 'duration_1hour':
        return Icons.timer;
      case 'pace_5min':
      case 'pace_6min':
        return Icons.speed;
      default:
        return Icons.emoji_events;
    }
  }

  String _getAchievementTitle(String achievementKey) {
    switch (achievementKey) {
      case 'distance_5k':
        return '5K Run';
      case 'distance_10k':
        return '10K Run';
      case 'duration_30min':
        return '30 Minutes';
      case 'duration_1hour':
        return '1 Hour Run';
      case 'pace_5min':
        return '5 min/km';
      case 'pace_6min':
        return '6 min/km';
      default:
        return achievementKey;
    }
  }
}
