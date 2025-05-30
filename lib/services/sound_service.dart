import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  final AudioPlayer _player = AudioPlayer();
  bool _isSoundEnabled = true;

  // Asset paths without the assets/ prefix since AssetSource adds it automatically
  static const String _tapSoundPath = 'sounds/tap.wav';
  static const String _loseSoundPath = 'sounds/lose.mp3';

  factory SoundService() {
    return _instance;
  }

  SoundService._internal();

  Future<void> initialize() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);
      
      // Verify assets exist
      if (kDebugMode) {
        print('Sound system initializing...');
        print('Tap sound path: $_tapSoundPath');
        print('Lose sound path: $_loseSoundPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing sound: $e');
      }
    }
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  Future<void> playTapSound() async {
    if (!_isSoundEnabled) return;

    try {
      if (kDebugMode) {
        print('Attempting to play tap sound from: $_tapSoundPath');
      }
      
      // Stop any current playback
      await _player.stop();
      
      // Create source and play
      final source = AssetSource(_tapSoundPath);
      if (kDebugMode) {
        print('Created AssetSource for tap sound');
      }
      
      await _player.play(source);
      if (kDebugMode) {
        print('Tap sound playback started');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error playing tap sound: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  Future<void> playLoseSound() async {
    if (!_isSoundEnabled) return;

    try {
      if (kDebugMode) {
        print('Attempting to play lose sound from: $_loseSoundPath');
      }
      await _player.stop();
      final source = AssetSource(_loseSoundPath);
      await _player.play(source);
    } catch (e) {
      if (kDebugMode) {
        print('Error playing lose sound: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
} 