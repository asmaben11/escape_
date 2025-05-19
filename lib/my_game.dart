import 'package:flame/game.dart';

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // This will print the screen size — it works for ALL phones
    print('Screen width: ${size.x}');
    print('Screen height: ${size.y}');

    // You can later use size.x and size.y to position or scale things
  }
}