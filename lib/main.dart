import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'level_one.dart'; // <-- Make sure this is the correct path to your LevelOne class
import 'level_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyMenuPage(),
    );
  }
}

class MyMenuPage extends StatefulWidget {
  const MyMenuPage({super.key});

  @override
  State<MyMenuPage> createState() => _MyMenuPageState();
}

class _MyMenuPageState extends State<MyMenuPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 5, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image full screen
          SizedBox.expand(
            child: Image.asset(
              'assets/images/main.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Play button with glow animation
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 300),
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LevelsPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      backgroundColor: Colors.black.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: Text(
                      'PLAY',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.9),
                            blurRadius: _glowAnimation.value,
                            offset: Offset(0, 0),
                          ),
                          Shadow(
                            color: Colors.white.withOpacity(0.7),
                            blurRadius: _glowAnimation.value / 2,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Levels Page
class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with moon and doors
          Positioned.fill(
            child: Image.asset(
              'assets/images/levels.jpg', // Background with doors
              fit: BoxFit.cover,
            ),
          ),

          // Door buttons (transparent and placed over each door)
          Positioned(left: 100, top: 300, child: LevelButton(level: 1)),
          Positioned(left: 240, top: 400, child: LevelButton(level: 2)),
          Positioned(left: 350, top: 290, child: LevelButton(level: 3)),
          Positioned(left: 500, top: 380, child: LevelButton(level: 4)),
          Positioned(left: 570, top: 290, child: LevelButton(level: 5)),
          Positioned(left: 660, top: 420, child: LevelButton(level: 6)),
        ],
      ),
    );
  }
}

// Invisible level buttons over doors
class LevelButton extends StatelessWidget {
  final int level;

  const LevelButton({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (level == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  const LevelOneScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Level $level is locked or not available yet.')),
          );
        }
      },
      child: Container(
        width: 60,
        height: 80,
        color: Colors.transparent, // Fully invisible button
      ),
    );
  }
}

// Runs the Flame game
class LevelOneScreen extends StatelessWidget {
  const LevelOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: LevelOne());
  }
}