import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'level_one.dart'; // Make sure this path is correct for your project

class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<LevelOne> {
  Vector2 velocity = Vector2.zero();
  double gravity = 600;
  double jumpForce = -300;
  bool onGround = true;

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('assets/images/AnimationSheet_Character.png');

    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
      ),
    );

    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += gravity * dt;
    position += velocity * dt;

    if (position.y >= gameRef.size.y - 50) {
      position.y = gameRef.size.y - 50;
      velocity.y = 0;
      onGround = true;
    }
  }

  void jump() {
    if (onGround) {
      velocity.y = jumpForce;
      onGround = false;
    }
  }
}