import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  final double initialBallSpeed;
  final double speedIncreaseFactor;
  final int ballSpawnInterval;
  final int maxBallsOnScreen;
  final int initialBinCapacity;
  final int binEmptyDuration;
  final bool soundEnabled;
  final bool particleEffectsEnabled;

  const GameSettings({
    this.initialBallSpeed = 2.0,
    this.speedIncreaseFactor = 1.1,
    this.ballSpawnInterval = 2500,
    this.maxBallsOnScreen = 6,
    this.initialBinCapacity = 4,
    this.binEmptyDuration = 1000,
    this.soundEnabled = true,
    this.particleEffectsEnabled = true,
  });

  static Future<GameSettings> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return GameSettings(
      initialBallSpeed: prefs.getDouble('ballSpeed') ?? 2.0,
      speedIncreaseFactor: prefs.getDouble('speedIncrease') ?? 1.1,
      ballSpawnInterval: prefs.getInt('spawnInterval') ?? 2500,
      maxBallsOnScreen: prefs.getInt('maxBalls') ?? 6,
      initialBinCapacity: prefs.getInt('binCapacity') ?? 4,
      binEmptyDuration: 1000,
      soundEnabled: prefs.getBool('soundEnabled') ?? true,
      particleEffectsEnabled: prefs.getBool('particleEffects') ?? true,
    );
  }
} 