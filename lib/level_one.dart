import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'player.dart';
import 'door.dart';

class LevelOne extends FlameGame with HasCollisionDetection, KeyboardEvents, TapDetector {
  late Player player;
  late SpriteAnimationComponent spike;
  late Door door;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'AnimationSheet_Character.png',
      'long_metal_spike_01.png',
      'long_metal_spike_02.png',
      'long_metal_spike_03.png',
      'doors.png',
      'levels.jpg',
    ]);

    // Background
    add(SpriteComponent(
      sprite: Sprite(images.fromCache('levels.jpg')),
      size: size,
      priority: -1,
    ));

    // Player
    player = Player()
      ..position = Vector2(100, size.y - 150)
      ..size = Vector2(48, 48);
    add(player);

    // Trap (Spike)
    spike = SpriteAnimationComponent(
      size: Vector2(60, 80),
      position: Vector2(400, size.y - 80),
      animation: SpriteAnimation.spriteList([
        Sprite(images.fromCache('long_metal_spike_01.png')),
        Sprite(images.fromCache('long_metal_spike_02.png')),
        Sprite(images.fromCache('long_metal_spike_03.png')),
      ], stepTime: 0.3),
    )..add(RectangleHitbox());
    add(spike);

    // Door
    door = Door()
      ..position = Vector2(size.x - 120, size.y - 140)
      ..size = Vector2(65, 100);
    add(door);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Restart if player collides with spike
    if (player.toRect().overlaps(spike.toRect())) {
      overlays.add('GameOver');
      Future.delayed(const Duration(seconds: 1), () => restart());
    }

    // Check victory
    if (player.toRect().overlaps(door.toRect())) {
      overlays.add('Victory');
      Future.delayed(const Duration(seconds: 2), () {
        // Go back to menu or next level
      });
    }
  }

  void restart() {
    player.position = Vector2(100, size.y - 150);
  }

  @override
  void onTapDown(TapDownInfo info) {
    player.jump();
  }
}