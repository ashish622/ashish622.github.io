import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

/// [Widget] displaying the home page container and buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double _targetPosition = 0.0;
  bool _isAnimating = false;
  double _screenWidth = html.window.innerWidth!.toDouble();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: _targetPosition,
    ).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
          setState(() {
            _isAnimating = false;
          });
        }
      });

    // Listen for window resize and maximize events
    html.window.addEventListener('resize', (event) {
      print('this is the event ${event.target}');
      setState(() {
        _screenWidth = html.window.innerWidth!.toDouble();
        _adjustPosition();
      });
    });

    html.window.addEventListener('visibilitychange', (event) {
      if (html.document.visibilityState == 'visible') {
        setState(() {
          _screenWidth = html.window.innerWidth!.toDouble();
          _adjustPosition();
        });
      }
    });
  }

  /// function that handles the left or right movement of the box
  void _moveContainer(double target) {
    setState(() {
      _isAnimating = true;
      _targetPosition = target;
      _animation = Tween<double>(
        begin: _animation.value,
        end: _targetPosition,
      ).animate(_controller);
      _controller.forward(from: 0.0);
    });
  }

  /// function that handles the changes in tab size
  void _adjustPosition() {
    final leftEdge = -_screenWidth / 2 + 32;
    final rightEdge = _screenWidth / 2 - 32;

    debugPrint("this is the screen width $_screenWidth");

    if (_targetPosition > leftEdge && _targetPosition < 0) {
      _moveContainer(leftEdge);
    } else if(_targetPosition < leftEdge && _targetPosition < 0){
      _moveContainer(leftEdge);
    }
    else if (_targetPosition < rightEdge && _targetPosition > 0) {
      _moveContainer(rightEdge);
    } else if(_targetPosition > rightEdge && _targetPosition > 0){
      _moveContainer(rightEdge);
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// left corner of the screen (32 is the box size)
    final leftEdge = -_screenWidth / 2 + 32;

    /// right corner of the screen
    final rightEdge = _screenWidth / 2 - 32;

    bool canMoveLeft = _animation.value > leftEdge && !_isAnimating;
    bool canMoveRight = _animation.value < rightEdge && !_isAnimating;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {

                    /// animated box that will animate
                    return Transform.translate(
                      offset: Offset(_animation.value, 0.0),
                      transformHitTests: false,
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// button to move box to left
                ElevatedButton(
                  onPressed: canMoveLeft ? () => _moveContainer(leftEdge) : null,
                  child: const Text("Left"),
                ),

                /// button to move box to right
                ElevatedButton(
                  onPressed: canMoveRight ? () => _moveContainer(rightEdge) : null,
                  child: const Text("Right"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
