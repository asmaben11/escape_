import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class Door extends SpriteAnimationComponent {
  @override
  Future<void> onLoad() async {
    final doorSheet = await Flame.images.load('assets/images/doors.png');
    animation = SpriteAnimation.fromFrameData(
      doorSheet,
      SpriteAnimationData.sequenced(
        amount: 9,
        textureSize: Vector2(65, 32),
        stepTime: 0.1,
        loop: true,
      ),
    );
  }
}