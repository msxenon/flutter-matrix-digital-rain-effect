import 'package:flutter/material.dart';
import 'package:matrix_digital_rain_effect/src/presentation/matrix_digital_rain/matrix_scene.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(fontFamily: 'Nunito'),
      home: const MyHomePage(title: 'The Matrix digital rain'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: SizedBox(
          width: 375,
          height: 815,
          child: MatrixScene(),
        ),
      ),
    );
  }
}
