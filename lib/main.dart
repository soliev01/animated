import 'dart:math';
import 'dart:ui';
import 'colors.dart';
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
        duration: const Duration(milliseconds: 700), vsync: this);
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

//type simple circular
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

// 5 star shape
  // final int peaks = 5;

  // @override
  // Path getStarClip(Size size) {
  //   final center = centerOffset ?? Offset(size.width / 2, size.height / 2);

  //   final path = Path();

  //   final innerRadius = lerpDouble(0, maxRadius(size, center), fraction)!;
  //   final outerRadius = 1.5 * innerRadius;

  //   for (var k = 0; k < peaks; k++) {
  //     /// radial offset between peaks
  //     /// coordinates of points are [𝑟cos(2𝜋𝑘/n+𝜋/2), 𝑟sin(2𝜋𝑘/5+𝜋/2)]
  //     final _bAngle = 2 * pi * k / peaks + pi / 2;
  //     final _sAngle = 2 * pi * k / peaks + pi / 2 + pi / peaks;

  //     final outerVertices =
  //         Offset(outerRadius * cos(_bAngle), outerRadius * sin(_bAngle));
  //     final innerVertices =
  //         Offset(innerRadius * cos(_sAngle), innerRadius * sin(_sAngle));

  //     if (k == 0) {
  //       path
  //         ..moveTo(outerVertices.dx, outerVertices.dy)
  //         ..lineTo(innerVertices.dx, innerVertices.dy);
  //     } else {
  //       path
  //         ..lineTo(outerVertices.dx, outerVertices.dy)
  //         ..lineTo(innerVertices.dx, innerVertices.dy);
  //     }
  //   }
  //   return Path()..addPath(path..close(), center);
  // }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return oldClipper != this;
  }
}
