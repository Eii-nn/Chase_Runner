import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/run_provider.dart';
import '../models/chaser.dart';
import '../models/run_data.dart';

class RunSetupScreen extends StatefulWidget {
  const RunSetupScreen({super.key});

  @override
  State<RunSetupScreen> createState() => _RunSetupScreenState();
}

class _RunSetupScreenState extends State<RunSetupScreen> {
  Chaser _selectedChaser = Chaser.defaultChaser();
  bool _isGhostMode = false;
  RunData? _ghostRun;
  RunMode _selectedRunMode = RunMode.chase;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if we have arguments for ghost mode
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('ghostRun')) {
      _ghostRun = args['ghostRun'] as RunData;
      _isGhostMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Run Mode Selection
            _buildRunModeSelection(),
            const SizedBox(height: 24),

            // Only show chaser selection in chase mode
            if (_selectedRunMode == RunMode.chase) ...[
              _buildChaserSelection(),
              const SizedBox(height: 24),
            ],

            // Ghost Run Option
            _buildGhostRunOption(),
            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startRun,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'START RUN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Run Mode',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                title: 'Chase Mode',
                description: 'Run from a virtual chaser',
                icon: Icons.directions_run,
                isSelected: _selectedRunMode == RunMode.chase,
                onTap: () => setState(() => _selectedRunMode = RunMode.chase),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModeCard(
                title: 'Free Run',
                description: 'Run at your own pace',
                icon: Icons.landscape,
                isSelected: _selectedRunMode == RunMode.free,
                onTap: () => setState(() => _selectedRunMode = RunMode.free),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChaserSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Chaser',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildChaserCard(
                name: 'Rookie',
                speed: 'Slow',
                image: 'assets/images/chaser_rookie.png',
                isSelected: _selectedChaser.name == 'Rookie',
                onTap: () {
                  setState(() {
                    _selectedChaser = Chaser(
                      id: 'rookie_1',
                      name: 'Rookie',
                      description:
                          'A beginner chaser that runs at a slow pace.',
                      imagePath: 'assets/images/chaser_rookie.png',
                      difficulty: ChaserDifficulty.easy,
                      baseSpeed: 8.0,
                    );
                  });
                },
              ),
              _buildChaserCard(
                name: 'Pro',
                speed: 'Medium',
                image: 'assets/images/chaser_pro.png',
                isSelected: _selectedChaser.name == 'Pro',
                onTap: () {
                  setState(() {
                    _selectedChaser = Chaser(
                      id: 'pro_1',
                      name: 'Pro',
                      description: 'An experienced runner with good stamina.',
                      imagePath: 'assets/images/chaser_pro.png',
                      difficulty: ChaserDifficulty.medium,
                      baseSpeed: 10.0,
                    );
                  });
                },
              ),
              _buildChaserCard(
                name: 'Elite',
                speed: 'Fast',
                image: 'assets/images/chaser_elite.png',
                isSelected: _selectedChaser.name == 'Elite',
                onTap: () {
                  setState(() {
                    _selectedChaser = Chaser(
                      id: 'elite_1',
                      name: 'Elite',
                      description:
                          'A professional athlete with incredible speed.',
                      imagePath: 'assets/images/chaser_elite.png',
                      difficulty: ChaserDifficulty.hard,
                      baseSpeed: 12.0,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChaserCard({
    required String name,
    required String speed,
    required String image,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run,
              size: 36,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            Text(
              speed,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGhostRunOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghost Run',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Race Against Your Past Self'),
          subtitle: const Text('Select a previous run to race against'),
          value: _isGhostMode,
          onChanged: (value) {
            setState(() {
              _isGhostMode = value;
              if (value && _ghostRun == null) {
                // Navigate to run history to select a ghost run
                Navigator.pushNamed(context, '/history', arguments: {
                  'selectMode': true,
                }).then((selectedRun) {
                  if (selectedRun != null) {
                    setState(() {
                      _ghostRun = selectedRun as RunData;
                    });
                  } else {
                    setState(() {
                      _isGhostMode = false;
                    });
                  }
                });
              }
            });
          },
        ),
        if (_isGhostMode && _ghostRun != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Selected run: ${_ghostRun!.formattedDate} - ${_ghostRun!.formattedDistance} km',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  void _startRun() {
    final runProvider = Provider.of<RunProvider>(context, listen: false);
    runProvider.startRun(
      customChaser: _selectedRunMode == RunMode.chase ? _selectedChaser : null,
      ghostRunData: _isGhostMode ? _ghostRun : null,
      mode: _selectedRunMode,
    );
    Navigator.pushNamed(context, '/active');
  }
}
