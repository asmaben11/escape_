import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

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
          SizedBox.expand(
            child: Image.asset(
              'assets/images/main.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.only(top: constraints.maxHeight * 0.4),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.1,
                            vertical: constraints.maxHeight * 0.05,
                          ),
                          backgroundColor: Colors.black.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.9),
                                blurRadius: _glowAnimation.value,
                              ),
                              Shadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: _glowAnimation.value / 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final List<Map<String, double>> buttonPositions = [
            {'left': 0.125, 'top': 0.55},
            {'left': 0.3, 'top': 0.68},
            {'left': 0.4375, 'top': 0.52},
            {'left': 0.625, 'top': 0.65},
            {'left': 0.7125, 'top': 0.52},
            {'left': 0.825, 'top': 0.72},
          ];

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/levels.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              for (int i = 0; i < buttonPositions.length; i++)
                Positioned(
                  left: width * buttonPositions[i]['left']!,
                  top: height * buttonPositions[i]['top']!,
                  child: GestureDetector(
                    onTap: () {
                      if (i == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LevelOneScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Level ${i + 1} is locked or not available yet.')),
                        );
                      }
                    },
                    child: Container(
                      width: width * 0.08,
                      height: height * 0.15,
                      color: Colors.transparent,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LevelOneScreen extends StatefulWidget {
  const LevelOneScreen({super.key});

  @override
  State<LevelOneScreen> createState() => _LevelOneScreenState();
}

class _LevelOneScreenState extends State<LevelOneScreen> {
  final CharacterDisplayGame game = CharacterDisplayGame();

  @override
  void initState() {
    super.initState();
    game.onLevelComplete = () {
      setState(() {}); // To show the win overlay
    };
    game.onPlayerDied = () {
    setState(() {}); // Show lose overlay
  };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          // 🔴 Lose overlay
          if (game.showLoseOverlay)
            GestureDetector(
              onTap: () {
                setState(() {
                  game.overlays.clear();
                  game.restart();
                });
              },
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'You Died! Tap to Retry',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

          // 🟢 Win overlay
          if (game.showWinOverlay)
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Back to level selection
              },
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Text(
                  'Level Complete!\nTap to Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.greenAccent),
                ),
              ),
            ),

          // Control Buttons (same as before)
          Positioned(
            left: 20,
            bottom: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTapDown: (_) => game.moveLeft = true,
                  onTapUp: (_) => game.moveLeft = false,
                  onTapCancel: () => game.moveLeft = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_left, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTapDown: (_) => game.moveRight = true,
                  onTapUp: (_) => game.moveRight = false,
                  onTapCancel: () => game.moveRight = false,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_right, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),

          // Jump Button
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTapDown: (_) => game.isJumping = true,
              onTapUp: (_) => game.isJumping = false,
              onTapCancel: () => game.isJumping = false,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class CharacterDisplayGame extends FlameGame {
  late SpriteAnimationComponent character;
  late SpriteAnimationComponent spikeTrap;
  late SpriteAnimation doorAnimation;

  late SpriteComponent door;
  bool moveLeft = false;
  bool moveRight = false;
  bool isJumping = false;
  bool isDead = false;
  bool facingRight = true;
  double moveSpeed = 200;

  double verticalSpeed = 0.0;
  final double gravity = 500;
  final double jumpForce = -500;
  bool isOnGround = true;
  bool doorTriggered = false;
  bool trapVisible = false;
  bool doorOpened = false;
  bool levelComplete = false;
  bool showLoseOverlay = false;
bool showWinOverlay = false;
Function()? onLevelComplete; // <-- Add this to call back to Flutter when level completes
Function()? onPlayerDied;
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await images.loadAll([
      'background.png',
      'Character.png',
      'doors.png',
      'long_metal_spike_01.png',
      'long_metal_spike_02.png',
      'long_metal_spike_03.png',
    ]);

    // Background
    add(SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..position = Vector2.zero());

    // Character animation
    final image = images.fromCache('Character.png');
final frameSize = Vector2(32, 32);

// Walking animation frames
final walkFrames = [
  Sprite(image, srcPosition: Vector2(0, 96), srcSize: frameSize),
  Sprite(image, srcPosition: Vector2(32, 96), srcSize: frameSize),
  Sprite(image, srcPosition: Vector2(64, 96), srcSize: frameSize),
  Sprite(image, srcPosition: Vector2(96, 96), srcSize: frameSize),
];

final walkAnimation = SpriteAnimation.spriteList(walkFrames, stepTime: 0.15, loop: true);
character = SpriteAnimationComponent()
  ..animation = walkAnimation
  ..size = Vector2(size.x * 0.06, size.x * 0.06)
  ..position = Vector2(size.x * 0.05, size.y * 0.65);
add(character);

    // Spike trap animation
    spikeTrap = SpriteAnimationComponent()
      ..animation = SpriteAnimation.spriteList([
        Sprite(images.fromCache('long_metal_spike_01.png')),
        Sprite(images.fromCache('long_metal_spike_02.png')),
        Sprite(images.fromCache('long_metal_spike_03.png')),
      ], stepTime: 0.2, loop: true)
      ..size = Vector2(size.x * 0.05, size.x * 0.05)
      ..position = Vector2(size.x * 0.76, size.y * 0.65)
      ..opacity = 0;
    add(spikeTrap);

    // Door animation setup
    final doorSheet = images.fromCache('doors.png');
    final frameHeight = doorSheet.height / 10;
    door = SpriteComponent()
      ..sprite = Sprite(
        doorSheet,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
      )
      ..size = Vector2(size.x * 0.15, (size.x * 0.15) * (frameHeight / doorSheet.width))
      ..position = Vector2(size.x * 0.78, size.y * 0.6);
    add(door);

    doorAnimation = SpriteAnimation.spriteList(
      List.generate(10, (i) {
        return Sprite(
          doorSheet,
          srcPosition: Vector2(0, i * frameHeight),
          srcSize: Vector2(doorSheet.width.toDouble(), frameHeight),
        );
      }),
      stepTime: 0.1,
      loop: false,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead || levelComplete) return;

    // Movement
    if (moveLeft) {
      character.position.x -= moveSpeed * dt;
      if (facingRight) {
        character.flipHorizontally();
        facingRight = false;
      }
    }
    if (moveRight) {
      character.position.x += moveSpeed * dt;
      if (!facingRight) {
        character.flipHorizontally();
        facingRight = true;
      }
    }

    // Jumping
    if (isJumping && isOnGround) {
      verticalSpeed = jumpForce;
      isOnGround = false;
    }

    verticalSpeed += gravity * dt;
    character.position.y += verticalSpeed * dt;

    final groundY = size.y * 0.65;
    if (character.position.y >= groundY) {
      character.position.y = groundY;
      verticalSpeed = 0;
      isOnGround = true;
    }

    // Stay on screen
    character.position.x = character.position.x.clamp(0, size.x - character.size.x);

    // Trigger trap
    if (!doorTriggered && character.position.x >= door.position.x - character.size.x * 1.2) {
      doorTriggered = true;
      door.add(MoveEffect.by(Vector2(size.x * 0.05, 0), EffectController(duration: 0.3)));
      spikeTrap.add(OpacityEffect.to(1.0, EffectController(duration: 0.4)));
      trapVisible = true;
    }

    // Check trap collision
    if (trapVisible) {
      final characterBox = Rect.fromLTWH(
        character.position.x + character.size.x * 0.2,
        character.position.y + character.size.y * 0.2,
        character.size.x * 0.6,
        character.size.y * 0.6,
      );
      final trapBox = Rect.fromLTWH(
        spikeTrap.position.x + spikeTrap.size.x * 0.1,
        spikeTrap.position.y + spikeTrap.size.y * 0.1,
        spikeTrap.size.x * 0.8,
        spikeTrap.size.y * 0.8,
      );
      if (characterBox.overlaps(trapBox)) {
        die();
      }
    }

    // Reaching door
    if (!doorOpened &&
        character.position.x >= door.position.x - character.size.x * 0.3 &&
        isOnGround &&
        trapVisible &&
        !isDead) {
      openDoor();
    }
  }
void die() {
  if (!isDead) {
    isDead = true;
    showLoseOverlay = true;
    character.add(
      OpacityEffect.to(0, EffectController(duration: 1.2, curve: Curves.easeOut)),
    );
    onPlayerDied?.call(); // <--- Notify the Flutter side
  }
}
  


  void openDoor() {
    doorOpened = true;

    final animatedDoor = SpriteAnimationComponent()
      ..animation = doorAnimation
      ..size = door.size
      ..position = door.position.clone();

    remove(door);
    add(animatedDoor);

    Future.delayed(const Duration(milliseconds: 300), () {
      character.addAll([
        MoveEffect.by(Vector2(animatedDoor.size.x * 0.6, 0), EffectController(duration: 0.5)),
        OpacityEffect.to(0, EffectController(duration: 0.5)),
      ]);

      Future.delayed(const Duration(milliseconds: 900), () {
        final reversed = SpriteAnimation.spriteList(
          List.generate(10, (i) {
            return Sprite(
              images.fromCache('doors.png'),
              srcPosition: Vector2(0, (9 - i) * (images.fromCache('doors.png').height / 10)),
              srcSize: Vector2(
                images.fromCache('doors.png').width.toDouble(),
                images.fromCache('doors.png').height / 10,
              ),
            );
          }),
          stepTime: 0.1,
          loop: false,
        );

        final closingDoor = SpriteAnimationComponent()
          ..animation = reversed
          ..size = animatedDoor.size
          ..position = animatedDoor.position.clone();

        remove(animatedDoor);
        add(closingDoor);
        levelComplete = true;
        showWinOverlay = true;

// Inform Flutter UI to change screen
         onLevelComplete?.call();
        
      });
    });
  }
  void restart() {
  overlays.clear();
  children.clear();
  isDead = false;
  levelComplete = false;
  showLoseOverlay = false;
  showWinOverlay = false;
  doorOpened = false;
  doorTriggered = false;
  trapVisible = false;

  onLoad(); // Reload everything
}
}