import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/run_provider.dart';
import '../providers/settings_provider.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class ActiveRunScreen extends StatefulWidget {
  const ActiveRunScreen({super.key});

  @override
  State<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends State<ActiveRunScreen>
    with SingleTickerProviderStateMixin {
  MapController? _mapController;
  bool _isPaused = false;
  bool _locationPermissionGranted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  LatLng? _currentCenter;
  bool _isMapFullScreen = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _mapController = MapController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _initializeMap();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController = null;
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        _locationPermissionGranted = true;
      });
    } else {
      final requestedPermission = await Geolocator.requestPermission();
      setState(() {
        _locationPermissionGranted =
            requestedPermission == LocationPermission.always ||
                requestedPermission == LocationPermission.whileInUse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationPermissionGranted) {
      return _buildPermissionRequest();
    }

    return Consumer<RunProvider>(
      builder: (context, runProvider, child) {
        return Scaffold(
          body: GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: Stack(
              children: [
                // Map Layer
                _buildMap(runProvider),

                // Map Controls - Always visible
                _buildMapControls(runProvider),

                // Chaser Status - Always visible in chase mode
                if (runProvider.runMode == RunMode.chase)
                  _buildChaserIndicator(runProvider),

                // Show controls based on toggle
                if (_showControls) ...[
                  // Top Bar with Run Mode
                  _buildTopBar(runProvider),

                  // Primary Stats (Time and Distance)
                  _buildPrimaryStats(runProvider),

                  // Bottom Controls
                  _buildControlPanel(runProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapControls(RunProvider runProvider) {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 16,
      child: Column(
        children: [
          // Fullscreen toggle
          FloatingActionButton.small(
            heroTag: 'map_toggle',
            onPressed: () {
              setState(() {
                _isMapFullScreen = !_isMapFullScreen;
                _showControls = !_isMapFullScreen;
              });
            },
            elevation: 4,
            backgroundColor:
                Theme.of(context).colorScheme.surface.withOpacity(0.9),
            child: Icon(
              _isMapFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 8),

          // Center on location button
          FloatingActionButton.small(
            heroTag: 'center_location',
            onPressed: () {
              if (runProvider.currentLocation != null) {
                _mapController?.move(
                  LatLng(
                    runProvider.currentLocation!.latitude,
                    runProvider.currentLocation!.longitude,
                  ),
                  16,
                );
              }
            },
            elevation: 4,
            backgroundColor:
                Theme.of(context).colorScheme.surface.withOpacity(0.9),
            child: Icon(
              Icons.my_location,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(RunProvider runProvider) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              runProvider.runMode == RunMode.chase
                  ? Icons.directions_run
                  : Icons.landscape,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              runProvider.runMode == RunMode.chase ? 'Chase Mode' : 'Free Run',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryStats(RunProvider runProvider) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Time
            Text(
              _formatDuration(runProvider.duration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Distance
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  (runProvider.distance / 1000).toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'km',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row of mini-stats
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildMiniStat(
                  'Pace',
                  runProvider.averagePace.isFinite
                      ? '${runProvider.averagePace.toStringAsFixed(1)} min/km'
                      : '--:--',
                  Icons.speed,
                ),
                const SizedBox(width: 12),
                _buildMiniStat(
                  'Cal',
                  runProvider.calories.isFinite
                      ? runProvider.calories.toStringAsFixed(0)
                      : '--',
                  Icons.local_fire_department,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 14,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChaserIndicator(RunProvider runProvider) {
    final distance = runProvider.chaserDistance;
    final double percent = (distance / 100).clamp(0.0, 1.0);

    final color = distance <= 20
        ? Colors.red
        : distance <= 50
            ? Colors.orange
            : Colors.green;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 90, // Position to right of mode indicator
      right: 70, // Leave room for map controls
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_run,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Stack(
                    children: [
                      // Background
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Foreground
                      FractionallySizedBox(
                        widthFactor: percent,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Distance text
                  Text(
                    '${distance.toStringAsFixed(0)}m behind',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(RunProvider runProvider) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Toggle audio
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    settingsProvider
                        .setAudioEnabled(!settingsProvider.audioEnabled);
                  },
                  icon: Icon(
                    settingsProvider.audioEnabled
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Text(
                  'Audio',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Pause/Resume button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'pause_resume',
                  onPressed: () {
                    setState(() {
                      if (_isPaused) {
                        runProvider.resumeRun();
                      } else {
                        runProvider.pauseRun();
                      }
                      _isPaused = !_isPaused;
                    });
                  },
                  backgroundColor: _isPaused ? Colors.green : Colors.orange,
                  child: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPaused ? 'Resume' : 'Pause',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // End run button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'stop',
                  onPressed: () => _showStopRunDialog(runProvider),
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.stop,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'End',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildPermissionRequest() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Location Permission Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'We need your location to track your run. Please grant location permission to continue.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    await _checkLocationPermission();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Grant Permission',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(RunProvider runProvider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FlutterMap(
        mapController: _mapController!,
        options: MapOptions(
          initialCenter: _currentCenter ?? const LatLng(51.5074, -0.1278),
          initialZoom: 16,
          onMapReady: () {
            if (_currentCenter != null) {
              _mapController?.move(_currentCenter!, 16);
            }
          },
          onPositionChanged: (position, hasGesture) {
            if (hasGesture && runProvider.currentLocation != null) {
              setState(() {
                _currentCenter = position.center;
              });
            }
          },
          interactionOptions: const InteractionOptions(
            enableScrollWheel: false,
            enableMultiFingerGestureRace: true,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            maxZoom: 19,
            tileBuilder: (context, widget, tile) {
              return widget;
            },
            fallbackUrl: 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          // Route Polyline with Gradient
          if (runProvider.routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: runProvider.routePoints
                      .map((point) => LatLng(point.latitude, point.longitude))
                      .toList(),
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 4,
                  gradientColors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ],
            ),
          // Current Location Marker with Pulse Animation
          if (runProvider.currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    runProvider.currentLocation!.latitude,
                    runProvider.currentLocation!.longitude,
                  ),
                  width: 40,
                  height: 40,
                  child: _PulsingMarker(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _initializeMap() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
        });
        if (_mapController != null && mounted) {
          _mapController!.move(_currentCenter!, 16);
        }
      }
    } catch (e) {
      debugPrint('Error initializing map: $e');
      // Set a default location (e.g., city center) if unable to get current location
      setState(() {
        _currentCenter = const LatLng(51.5074, -0.1278); // London as default
      });
    }
  }

  Future<void> _showStopRunDialog(RunProvider runProvider) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Run?'),
        content: const Text('Are you sure you want to end this run?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await runProvider.endRun();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/summary');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Run'),
          ),
        ],
      ),
    );
  }
}

class _PulsingMarker extends StatefulWidget {
  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse
              Container(
                width: 40 * (0.6 + _animation.value * 0.4),
                height: 40 * (0.6 + _animation.value * 0.4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              // Inner circle
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
