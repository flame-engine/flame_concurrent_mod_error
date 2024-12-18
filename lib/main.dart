import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _random = Random();

class BuzzComponent extends RectangleComponent with HasGameRef<MyGame> {
  BuzzComponent({
    required this.target,
  }) : super(
          priority: 200,
          size: Vector2.all(10),
          anchor: Anchor.center,
          paint: Paint()..color = Colors.red,
        );

  final PositionComponent target;
  bool _beingRemoved = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.buzzActive || target.isRemoved) {
      removeFromParent();
      _beingRemoved = true;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    position = target.position.clone() +
        Vector2(
          _random.nextDouble() * target.size.x,
          _random.nextDouble() * target.size.y,
        );

    _animate();
  }

  void _animate() {
    //if (_beingRemoved) {
    //  return;
    //}
    final animateTo = target.position.clone() +
        Vector2(
          _random.nextDouble() * target.size.x,
          _random.nextDouble() * target.size.y,
        );
    add(
      MoveEffect.to(
        animateTo,
        LinearEffectController(.08),
        onComplete: () => _animate(),
      ),
    );
  }
}

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  late final RectangleComponent target;
  bool buzzActive = false;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    camera = CameraComponent.withFixedResolution(width: 256, height: 240);

    world.add(
      target = RectangleComponent(
        anchor: Anchor.center,
        size: Vector2.all(50),
        paint: Paint()..color = Colors.white,
      ),
    );

    add(
      KeyboardListenerComponent(
        keyDown: {
          LogicalKeyboardKey.space: (_) {
            return false;
          },
        },
        keyUp: {
          LogicalKeyboardKey.space: (_) {
            buzzActive = true;

            for (var i = 0; i < 200; i++) {
              world.add(BuzzComponent(target: target));
            }

            add(
              TimerComponent(
                period: 1,
                onTick: () {
                  buzzActive = false;
                },
              ),
            );

            return false;
          },
        },
      ),
    );
  }
}

void main() {
  runApp(GameWidget.controlled(gameFactory: MyGame.new));
}
