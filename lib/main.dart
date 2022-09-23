import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AnimationScreen(),
    );
  }
}

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with SingleTickerProviderStateMixin {
  Offset? _tapPosition; //position of global tap on Scaffold
  late Animation animation;
  final _random = Random();
  late AnimationController _controller;
  List<Color> colors = const [
    Color(0xff55efc4),
    Color(0xff81ecec),
    Color(0xff74b9ff),
    Color(0xffa29bfe),
    Color(0xffdfe6e9),
    Color(0xff00b894),
    Color(0xff0984e3),
    Color(0xfffd79a8),
    Color(0xffffeaa7),
    Color(0xfffab1a0),
    Color(0xffff7675),
    Color(0xfffd79a8),
    Color(0xffd63031),
    Color(0xfffdcb6e),
    Color(0xffe17055),
    Color(0xff2d3436),
    Color(0xffff6b6b),
    Color(0xff00d2d3),
    Color(0xff5f27cd),
    Color(0xff222f3e),
    Color(0xff01a3a4),
    Color(0xffff9ff3),
    Color(0xff1dd1a1),
    Color(0xffa55eea),
    Color(0xffeb3b5a),
    Color(0xff0fb9b1),
    Color(0xffa5b1c2),
    Color(0xfffc5c65),
    Color(0xfffd9644),
    Color(0xffcd84f1),
    Color(0xffff3838),
    Color(0xff0fbcf9)
  ];
  _getRandomColor() {
    return colors[_random.nextInt(colors.length)];
    //return (colors..shuffle(_random)).first;
    //return Colors.primaries[_random.nextInt(Colors.primaries.length)];
    // return Color.fromARGB(
    //   _random.nextInt(256),
    //   _random.nextInt(256),
    //   _random.nextInt(256),
    //   _random.nextInt(256),
    // );
  }

  late Color _currentColor;
  late Color _scaffoldColor = Colors.white;

  void _getTapPosition(TapDownDetails details) async {
    final tapPosition = details.globalPosition;
    if (_controller.isCompleted) {
      _controller.reset();
      _scaffoldColor = _currentColor;

      setState(() {
        _tapPosition = tapPosition;
        _currentColor = _getRandomColor();
        _controller.forward();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentColor = _getRandomColor();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _getTapPosition(details),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _scaffoldColor,
        body: Stack(children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => ClipPath(
              clipper: CircularClipper(
                  centerOffset: _tapPosition, fraction: _controller.value),
              child: Container(color: _currentColor),
            ),
          ),
        ]),
      ),
    );
  }
}

class CircularClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset? centerOffset;

  CircularClipper({required this.fraction, required this.centerOffset});

  static double maxRadius(Size size, Offset center) {
    final width = max(center.dx, size.width - center.dx);
    final height = max(center.dy, size.height - center.dy);
    return sqrt(pow(width, 2) + pow(height, 2));
  }

  @override
  getClip(Size size) {
    final center = centerOffset ?? Offset(size.width / 2, size.height / 2);

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: lerpDouble(0, maxRadius(size, center), fraction)!,
        ),
      );
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return oldClipper != this;
  }
}
