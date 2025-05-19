import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'level_one.dart'; // Import your Flame game

class LevelScreen extends StatelessWidget {
  final int level;

  const LevelScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // You can later add a switch for multiple levels
    Widget gameWidget;
    if (level == 1) {
      gameWidget = GameWidget(game: LevelOne());
    } else {
      gameWidget = const Center(child: Text('Level not implemented'));
    }

    return Scaffold(
      body: gameWidget,
    );
  }
}