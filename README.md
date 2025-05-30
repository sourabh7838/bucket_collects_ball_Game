# Ball Catcher Game

A fun and challenging Flutter game where you catch falling balls in a bucket. Test your reflexes and strategy as you progress through increasingly difficult levels!

## Technologies Used

### Framework & SDK
- **Flutter**: v3.19.0
- **Dart**: v3.3.0
- **Minimum iOS**: 12.0
- **Minimum Android**: API 21 (Android 5.0)

### Development Tools
- **IDE**: Android Studio / VS Code
- **Version Control**: Git
- **Build Tools**: 
  - Xcode for iOS
  - Gradle for Android

### Key Packages
- **audioplayers**: ^5.2.1
  - Low-latency audio playback
  - Multiple format support
  - Cross-platform compatibility
- **shared_preferences**: ^2.2.2
  - Persistent storage
  - Settings management
  - High score tracking

## Project Structure

```
exercise_3/
├── lib/
│   ├── models/
│   │   ├── ball_data.dart        # Ball properties and behavior
│   │   └── game_settings.dart    # Game configuration model
│   ├── screens/
│   │   ├── game_screen.dart      # Main game screen
│   │   └── settings_screen.dart  # Settings configuration
│   ├── services/
│   │   └── sound_service.dart    # Audio management
│   ├── widgets/
│   │   ├── ball.dart            # Ball widget
│   │   ├── bucket.dart          # Bucket widget
│   │   └── particle.dart        # Visual effects
│   └── main.dart                # App entry point
├── assets/
│   └── sounds/
│       ├── tap.wav              # Ball catch sound
│       └── lose.mp3             # Game over sound
├── ios/                         # iOS specific configuration
├── android/                     # Android specific configuration
├── pubspec.yaml                 # Dependencies and assets
└── README.md                    # Project documentation
```

### Key Components

#### Models
- `ball_data.dart`: Manages ball physics and properties
- `game_settings.dart`: Handles game configuration and persistence

#### Screens
- `game_screen.dart`: Core game logic and UI
- `settings_screen.dart`: Settings management interface

#### Services
- `sound_service.dart`: Audio playback management
  - Sound effect loading
  - Volume control
  - Resource management

#### Widgets
- `ball.dart`: Ball rendering and animations
- `bucket.dart`: Bucket movement and fill states
- `particle.dart`: Visual feedback effects

## Game Features

### Core Gameplay
- Control a bucket by sliding left and right
- Catch falling balls to score points
- Empty the bucket when it reaches capacity to advance to the next level
- Game ends if a ball hits the ground
- Track your high score across game sessions

### Game Controls
- Slide finger left/right to move the bucket
- Tap pause button to pause/resume game
- Access settings through the gear icon

### Dynamic Difficulty
- Increasing ball speed with each level
- Progressive bucket capacity
- Adaptive spawn rates for balanced gameplay
- Carefully tuned difficulty progression

### Customizable Settings
- **Ball Speed**: Adjust initial falling speed (1.0-3.0)
- **Speed Increase**: Control how much faster balls fall each level (5-20%)
- **Initial Bin Capacity**: Set starting bucket capacity (3-7 balls)
- **Maximum Balls**: Limit concurrent falling balls (4-8 balls)
- **Sound Effects**: Toggle catch sound effects
- **Particle Effects**: Toggle visual effects when catching balls

### Visual and Audio Features
- Smooth animations
- Particle effects on ball catch
- Sound effects for enhanced feedback
- Modern UI with gradient background
- Visual feedback for game states

## How to Play

1. **Start the Game**
   - Launch the app
   - The bucket appears at the bottom of the screen

2. **Basic Controls**
   - Slide your finger left or right to move the bucket
   - Catch the falling balls in your bucket
   - Don't let any balls hit the ground!

3. **Scoring & Progression**
   - Each caught ball adds to your score
   - Fill the bucket to advance to the next level
   - Each level increases difficulty:
     - Balls fall faster
     - More balls can appear simultaneously
     - Bucket capacity increases

4. **Game Management**
   - Pause/Resume: Tap the pause button
   - Settings: Access via gear icon
   - High Score: Automatically saved and displayed

5. **Customization**
   - Access settings menu for game customization
   - Adjust difficulty parameters
   - Toggle visual and sound effects

## Installation

1. Ensure Flutter is installed on your system
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Launch with `flutter run`

## Dependencies

- Flutter
- shared_preferences: For saving game settings and high scores
- audioplayers: For sound effects

## Development

Built with Flutter, featuring:
- Clean architecture
- State management
- Persistent storage
- Custom animations
- Sound integration

## License

This project is open source and available under the MIT License.
