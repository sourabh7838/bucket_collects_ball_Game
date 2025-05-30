import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/ball.dart';
import '../widgets/bucket.dart';
import '../models/ball_data.dart';
import '../models/game_settings.dart';
import '../widgets/particle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sound_service.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const double bucketWidth = 70.0;
  static const double bucketHeight = 60.0;
  static const double ballSize = 20.0;
  
  double bucketX = 0.0;
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  List<BallData> balls = [];
  List<Widget> particles = [];
  Timer? gameTimer;
  Timer? difficultyTimer;
  final Random random = Random();
  GameSettings settings = const GameSettings();  // Initialize with default values
  late AnimationController _bucketController;
  late AnimationController _emptyingController;
  double currentBallSpeed = 3.0;
  int currentSpawnInterval = 2000;
  int currentBinCapacity = 5;
  int currentBinFill = 0;
  bool isEmptyingBin = false;
  int currentLevel = 1;
  final SoundService _soundService = SoundService();
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _soundService.initialize();
    _loadGameSettings();  // This will update settings later with saved values
    _bucketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _emptyingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: settings.binEmptyDuration),
    );
    _emptyingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isEmptyingBin = false;
          currentBinFill = 0;
          currentLevel++;
          currentBinCapacity = settings.initialBinCapacity + currentLevel - 1;
        });
        _emptyingController.reset();
      }
    });
    _loadHighScore();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
        screenHeight = MediaQuery.of(context).size.height;
        bucketX = screenWidth / 2 - bucketWidth / 2;
      });
      startGame();
    });
  }

  Future<void> _loadHighScore() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      highScore = preferences.getInt('highScore') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (score > highScore) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('highScore', score);
      setState(() {
        highScore = score;
      });
    }
  }

  Future<void> _loadGameSettings() async {
    final loadedSettings = await GameSettings.loadFromPrefs();
    if (mounted) {  // Check if the widget is still mounted
      setState(() {
        settings = loadedSettings;
        currentBallSpeed = settings.initialBallSpeed;
        currentSpawnInterval = settings.ballSpawnInterval;
        currentBinCapacity = settings.initialBinCapacity;
      });
    }
  }

  void _onSettingsChanged(GameSettings newSettings) {
    setState(() {
      settings = newSettings;
      currentBallSpeed = settings.initialBallSpeed;
      currentSpawnInterval = settings.ballSpawnInterval;
      currentBinCapacity = settings.initialBinCapacity;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    difficultyTimer?.cancel();
    _bucketController.dispose();
    _emptyingController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        gameTimer?.cancel();
        difficultyTimer?.cancel();
      } else {
        startGame();
      }
    });
  }

  void startGame() {
    setState(() {
      if (!isGameOver) {
        score = score;  // Keep current score if just unpausing
      } else {
        score = 0;  // Reset score if starting new game
      }
      isGameOver = false;
      isPaused = false;
      balls.clear();
      particles.clear();
      currentBallSpeed = settings.initialBallSpeed;
      currentSpawnInterval = settings.ballSpawnInterval;
      currentBinCapacity = settings.initialBinCapacity;
      currentBinFill = 0;
      currentLevel = 1;
      isEmptyingBin = false;
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGame();
    });

    _scheduleBallSpawn();

    difficultyTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      increaseDifficulty();
    });
  }

  void _scheduleBallSpawn() {
    if (isGameOver || isPaused) return;
    
    if (balls.length < settings.maxBallsOnScreen) {
      Future.delayed(Duration(milliseconds: currentSpawnInterval), () {
        if (!isGameOver && !isPaused) {
          spawnBall();
          _scheduleBallSpawn();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        _scheduleBallSpawn();
      });
    }
  }

  void increaseDifficulty() {
    setState(() {
      currentBallSpeed *= settings.speedIncreaseFactor;
      currentSpawnInterval = (currentSpawnInterval * 0.95).toInt();
      currentSpawnInterval = currentSpawnInterval.clamp(1500, 2500);
    });
  }

  void spawnBall() {
    if (balls.length >= settings.maxBallsOnScreen) return;
    
    bool tooClose = false;
    double newX = random.nextDouble() * (screenWidth - ballSize);
    
    for (var ball in balls) {
      if ((ball.x - newX).abs() < ballSize * 2 && ball.y < screenHeight * 0.3) {
        tooClose = true;
        break;
      }
    }

    if (!tooClose) {
      setState(() {
        balls.add(
          BallData(
            x: newX,
            y: -ballSize,
            speed: currentBallSpeed + (random.nextDouble() * 0.5),
          ),
        );
      });
    }
  }

  void _addCatchParticles(Offset position) {
    setState(() {
      particles.add(
        ParticleSystem(
          position: position,
          color: Colors.yellow,
          onComplete: () {
            setState(() {
              particles.removeAt(0);
            });
          },
        ),
      );
    });
  }

  void emptyBin() {
    setState(() {
      isEmptyingBin = true;
      _emptyingController.forward(from: 0);
    });
  }

  void updateGame() {
    if (isGameOver || isEmptyingBin || isPaused) return;

    setState(() {
      for (int i = balls.length - 1; i >= 0; i--) {
        balls[i].y += balls[i].speed;

        if (balls[i].y + ballSize >= screenHeight - bucketHeight &&
            balls[i].x + ballSize >= bucketX &&
            balls[i].x <= bucketX + bucketWidth) {
          score++;
          currentBinFill++;
          _addCatchParticles(Offset(balls[i].x + ballSize / 2, balls[i].y + ballSize / 2));
          _soundService.playTapSound();
          balls.removeAt(i);
          _bucketController.forward(from: 0);

          if (currentBinFill >= currentBinCapacity) {
            emptyBin();
          }
          continue;
        }

        if (balls[i].y > screenHeight) {
          setState(() {
            isGameOver = true;
          });
          _saveHighScore();
          _soundService.playLoseSound();
          gameTimer?.cancel();
          difficultyTimer?.cancel();
          break;
        }
      }
    });
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      bucketX += details.delta.dx;
      bucketX = bucketX.clamp(0, screenWidth - bucketWidth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: onDragUpdate,
        child: Stack(
          children: [
            // Background
            Container(
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
            ),
            
            // Top Bar with Score, Level, and Buttons
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score and Level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score: $score',
                        style: const TextStyle(
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
                      Text(
                        'High Score: $highScore',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Level: $currentLevel',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Buttons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: !isGameOver ? togglePause : null,
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          if (!isGameOver) {
                            gameTimer?.cancel();
                            difficultyTimer?.cancel();
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(
                                currentSettings: settings,
                                onSettingsChanged: (newSettings) {
                                  _onSettingsChanged(newSettings);
                                  if (!isGameOver) {
                                    startGame();
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Game Elements
            ...particles,
            ...balls.map((ball) => Positioned(
              left: ball.x,
              top: ball.y,
              child: Ball(
                color: Colors.orange,
                isGlowing: true,
              ),
            )),

            // Bucket
            AnimatedBuilder(
              animation: _bucketController,
              builder: (context, child) {
                return Positioned(
                  left: bucketX,
                  bottom: _bucketController.value * 10,
                  child: Bucket(
                    isActive: _bucketController.value > 0,
                    currentFill: currentBinFill,
                    capacity: currentBinCapacity,
                    isEmptying: isEmptyingBin,
                  ),
                );
              },
            ),

            // Pause Overlay
            if (isPaused && !isGameOver)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'PAUSED',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: togglePause,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Resume',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Game Over overlay
            if (isGameOver)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Game Over!',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Final Score: $score',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      if (score >= highScore) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'New High Score!',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Play Again',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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