import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphx/graphx.dart';

class MatrixRainDrawingScene extends GSprite {
  final List<String> _matrixChars;
  late GSprite _container;
  late GBitmap _captured;
  // 20FPS
  static const _reRenderDuration = Duration(milliseconds: 50);
  Timer? _timer;
  final textStyle = const TextStyle(
    color: Colors.green,
    fontSize: 15.0,
    fontFeatures: [
      FontFeature.tabularFigures(),
    ],
  );
  Size _charSize = Size.zero;
  final _random = Random();
  MatrixRainDrawingScene(this._matrixChars);

  int _getRandomCharIndex() {
    return _random.nextInt(_matrixChars.length - 1);
  }

  @override
  void addedToStage() {
    super.addedToStage();

    // Initialize container
    _initContainer();

    // Clip stage to widget size
    stage?.maskBounds = true;

    // Set character size
    _setCharSize();

    // Calculate column count
    final columnCount = (stage!.stageWidth / _charSize.width).floor() + 1;

    // Generate starting random characters list and y positions
    final startRandomCharsList = List.generate(columnCount, (index) => _getRandomCharIndex());
    final yPos = _generateYPos(columnCount);

    // Start timer for periodic rendering
    _timer = Timer.periodic(_reRenderDuration, (_) async {
      try {
        await _draw(yPos, startRandomCharsList);
      } catch (e) {
        debugPrint('Error during draw: $e');
      }
    });
  }

  void _setCharSize() {
    final label = _getNormalGText('X');
    _charSize = Size(label.textWidth, label.textHeight);
  }

  /// Draws the Matrix rain effect.
  Future<void> _draw(List<double> yPos, List<int> startRandomCharsInt) async {
    /// we have to draw a rect (transparent), so the bounds are detected when
    /// capturing the snapshot.
    final dimBG = GSprite();
    dimBG.graphics
        .beginFill(Colors.black.withOpacity(0.1))
        .drawRect(0, 0, stage!.stageWidth, stage!.stageHeight)
        .endFill();
    _container.addChild(dimBG);
    Map<Offset, String> overlays = {};

    for (var i = 0; i < yPos.length; i++) {
      final cursor = yPos[i] ~/ _charSize.height;

      final x = i * (_charSize.width * 2);
      final text = _matrixChars[(startRandomCharsInt[i] + cursor) % (_matrixChars.length - 1)];

      final label = _getNormalGText(text);

      _container.addChild(label);
      label.setPosition(x + (label.textWidth / 2), yPos[i]);

      overlays.putIfAbsent(Offset(x + (label.textWidth / 2), yPos[i]), () => text);
      // randomly reset the end of the column if it's at least 100px high
      if (yPos[i] > 100 + _random.nextDouble() * 10000) {
        yPos[i] = 0;
      } else {
        yPos[i] += _charSize.height;
      }
    }

    // Save snapshot and release resources
    await _saveAndRelease();

    // Draw white overlay characters
    _drawWhiteChars(overlays);
  }

  // Create a GText object with the given text and text style
  GText _getGText(String text, TextStyle textStyle) {
    return GText(
      text: text,
      textStyle: textStyle,
    )
      ..validate()
      ..alignPivot();
  }

  // Create a GText object with the given text and the default text style
  GText _getNormalGText(String text) {
    return _getGText(
      text,
      textStyle,
    );
  }

  Future<void> _saveAndRelease() async {
    /// get a Texture (Image) from the container GSprite,
    /// at 100% resolution (1x).
    /// This value should match the dpiScale of the screen.
    final texture = await _container.createImageTexture(false);

    /// potential bug in GraphX, we should reset the pivot point in the Texture.
    /// so it doesnt goes off-stage if we press/move away the screen area.
    texture.pivotX = texture.pivotY = 0;

    /// after capturing the Texture, we clear the drawn line... to start fresh.
    /// and not overload the CPU.
    _container.graphics.clear();
    _container.removeChildren(0, -1, true);
    removeChildren(0, -1, true);
    _initContainer();

    /// refresh the GBitmap with the new texture.
    _captured.texture = texture;
  }

  void _initContainer() {
    _container = GSprite();

    /// we have to draw a rect (transparent), so the bounds are detected when
    /// capturing the snapshot.
    _container.graphics
        .beginFill(Colors.red.withOpacity(0))
        .drawRect(0, 0, stage!.stageWidth, stage!.stageHeight)
        .endFill();
    _captured = GBitmap();

    /// Increase the smoothing quality when painting the Image into the
    /// canvas.
    _captured.nativePaint.filterQuality = FilterQuality.high;
    addChild(_container);
    _container.addChild(_captured);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<double> _generateYPos(int columnCount) {
    return List<double>.generate(columnCount, (index) => (index * _charSize.height) * _random.nextDouble());
  }

  void _drawWhiteChars(Map<Offset, String> overlays) {
    for (int i = 0; i < overlays.length; i++) {
      final offset = overlays.keys.toList()[i];
      final text = overlays.values.toList()[i];
      final whiteLabel = _getGText(
        text,
        textStyle.copyWith(
          color: Colors.white.withOpacity(_random.nextDouble()),
          shadows: [Shadow(color: Colors.white.withOpacity(_random.nextDouble()), blurRadius: 10)],
        ),
      );

      addChild(whiteLabel);
      whiteLabel.setPosition(offset.dx, offset.dy);
    }
  }
}
