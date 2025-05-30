import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings currentSettings;
  final Function(GameSettings) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _ballSpeed;
  late double _speedIncrease;
  late int _spawnInterval;
  late int _maxBalls;
  late int _binCapacity;
  late bool _soundEnabled;
  late bool _particleEffects;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _ballSpeed = widget.currentSettings.initialBallSpeed;
      _speedIncrease = widget.currentSettings.speedIncreaseFactor;
      _spawnInterval = widget.currentSettings.ballSpawnInterval;
      _maxBalls = widget.currentSettings.maxBallsOnScreen;
      _binCapacity = widget.currentSettings.initialBinCapacity;
      _soundEnabled = widget.currentSettings.soundEnabled;
      _particleEffects = widget.currentSettings.particleEffectsEnabled;
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ballSpeed', _ballSpeed);
    await prefs.setDouble('speedIncrease', _speedIncrease);
    await prefs.setInt('spawnInterval', _spawnInterval);
    await prefs.setInt('maxBalls', _maxBalls);
    await prefs.setInt('binCapacity', _binCapacity);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('particleEffects', _particleEffects);

    final newSettings = GameSettings(
      initialBallSpeed: _ballSpeed,
      speedIncreaseFactor: _speedIncrease,
      ballSpawnInterval: _spawnInterval,
      maxBallsOnScreen: _maxBalls,
      initialBinCapacity: _binCapacity,
      soundEnabled: _soundEnabled,
      particleEffectsEnabled: _particleEffects,
    );

    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Game Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF1a237e),
        elevation: 8,
        shadowColor: Colors.black38,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a237e),
              Color(0xFF3949ab),
              Color(0xFF3f51b5),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ball Speed',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'How fast the balls fall initially',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Slider(
                      value: _ballSpeed,
                      min: 1.0,
                      max: 3.0,
                      divisions: 4,
                      label: _ballSpeed.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => _ballSpeed = value);
                        _saveSettings();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Speed Increase Per Level',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'How much faster balls fall in each level (×)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Slider(
                      value: _speedIncrease,
                      min: 1.05,
                      max: 1.2,
                      divisions: 3,
                      label: _speedIncrease.toStringAsFixed(2),
                      onChanged: (value) {
                        setState(() => _speedIncrease = value);
                        _saveSettings();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Initial Bin Capacity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'How many balls the bin can hold at start',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Slider(
                      value: _binCapacity.toDouble(),
                      min: 3,
                      max: 7,
                      divisions: 4,
                      label: _binCapacity.toString(),
                      onChanged: (value) {
                        setState(() => _binCapacity = value.toInt());
                        _saveSettings();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Maximum Balls',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Maximum number of balls falling at once',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Slider(
                      value: _maxBalls.toDouble(),
                      min: 4,
                      max: 8,
                      divisions: 4,
                      label: _maxBalls.toString(),
                      onChanged: (value) {
                        setState(() => _maxBalls = value.toInt());
                        _saveSettings();
                      },
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text(
                        'Sound Effects',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Play sounds when catching balls',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() => _soundEnabled = value);
                        _saveSettings();
                      },
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Particle Effects',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Show sparkles when catching balls',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _particleEffects,
                      onChanged: (value) {
                        setState(() => _particleEffects = value);
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 