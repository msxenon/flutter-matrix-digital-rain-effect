import 'package:flutter/material.dart';
import 'package:graphx/graphx.dart';
import 'package:matrix_digital_rain_effect/src/data/get_matrix_characters.dart';
import 'package:matrix_digital_rain_effect/src/presentation/matrix_digital_rain/matrix_rain_drawing_scene.dart';

class MatrixScene extends StatelessWidget {
  const MatrixScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SceneBuilderWidget(
      builder: () => SceneController(back: MatrixRainDrawingScene(getMatrixCharacters())),
      autoSize: true,
    );
  }
}
