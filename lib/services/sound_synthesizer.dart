import 'dart:math';
import 'dart:typed_data';

class SoundSynthesizer {
  static Uint8List generatePaperCrumpleSound() {
    const int sampleRate = 44100;
    const double duration = 0.3; // 300ms
    final int numSamples = (sampleRate * duration).toInt();
    final random = Random();
    
    // Create buffer for PCM data
    final buffer = Float64List(numSamples);
    
    // Generate crumpling noise
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = _envelope(t, duration);
      
      // Mix different frequencies for paper-like sound
      double sample = 0;
      for (int j = 0; j < 5; j++) {
        final freq = 100 + random.nextDouble() * 2000;
        sample += sin(2 * pi * freq * t) * random.nextDouble() * envelope;
      }
      
      // Add some noise
      sample += (random.nextDouble() * 2 - 1) * envelope * 0.3;
      
      // Normalize and store
      buffer[i] = sample * 0.5;
    }
    
    // Convert to 16-bit PCM
    final pcm = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      pcm[i] = (buffer[i] * 32767).toInt().clamp(-32767, 32767);
    }
    
    return pcm.buffer.asUint8List();
  }
  
  static double _envelope(double t, double duration) {
    const attackTime = 0.05;
    const releaseTime = 0.15;
    
    if (t < attackTime) {
      return t / attackTime;
    } else if (t > duration - releaseTime) {
      return (duration - t) / releaseTime;
    }
    return 1.0;
  }
} 