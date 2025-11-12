import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/firebase_database_service.dart';

class SfPage extends StatefulWidget {
  final void Function(String result)? onFlip;

  const SfPage({super.key, this.onFlip});

  @override
  State<SfPage> createState() => _SfPageState();
}

class _SfPageState extends State<SfPage> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  String _result = "";
  String _resultMessage = ""; // e.g. "The result is HEADS. Coin flipped at ..."
  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();

  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isSpinning = false;
  String _finalOutcome = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _storeFlipAndTrim(String outcome) async {
    try {
      await _dbService.addFlip(outcome, maxKeep: 5);
    } catch (e) {
      debugPrint("Failed to store flip: $e");
    }
  }

  Future<void> _onFlipComplete(String outcome) async {
    final now = DateTime.now();
    final formatted = DateFormat('MM/dd/yyyy h:mm a').format(now);
    final message = "The result is ${outcome[0].toUpperCase()}${outcome.substring(1).toLowerCase()}. Coin flipped at $formatted";

    setState(() {
      _result = outcome;
      _resultMessage = message;
    });

    // store to DB and trim to last 5
    await _storeFlipAndTrim(outcome);

    // call optional callback to parent
    widget.onFlip?.call(outcome);
  }

  void _flipCoin() {
    if (_isSpinning) {
      // If spinning, skip to final outcome immediately
      _controller.stop();
      _controller.value = 1.0;
      setState(() {
        _isSpinning = false;
        _result = _finalOutcome;
      });
      _onFlipComplete(_finalOutcome);
      return;
    }

    setState(() {
      _isSpinning = true;
      _result = "";
      _resultMessage = "";
    });

    // Randomize outcome first
    _finalOutcome = _random.nextBool() ? "HEADS" : "TAILS";

    // Randomize number of spins (5–10 full rotations)
    final spins = 5 + _random.nextInt(6);

    // Make sure the coin ends on the chosen outcome
    final endAngle = (_finalOutcome == "HEADS")
        ? spins * 2 * pi // full rotation ends with HEADS
        : (spins * 2 * pi) + pi; // half-turn ends with TAILS

    _animation = Tween<double>(begin: 0, end: endAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward(from: 0).whenComplete(() async {
      setState(() {
        _isSpinning = false;
        _result = _finalOutcome;
      });

      await _onFlipComplete(_finalOutcome);
    });
  }

  Widget _buildCoinFace(String text) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFC5A200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.black87, width: 6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(4, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(2, 2), blurRadius: 3)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Page uses the same background blue as your app
    return Container(
      color: const Color(0xFF007BFF),
      child: SafeArea(
        top: false, // app bar handled outside
        bottom: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // coin graphic + tappable flip
              GestureDetector(
                onTap: _flipCoin,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    double angle = _animation.value % (2 * pi);

                    // Show final outcome if not spinning
                    bool showHeads =
                    _isSpinning ? (angle <= pi) : (_finalOutcome == "HEADS");

                    // Flip text when coin rotates past 90° or 270° to avoid mirrored text
                    double rotationY = _animation.value;
                    bool flipText = angle > pi / 2 && angle < 3 * pi / 2;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective for 3D effect
                        ..rotateY(rotationY),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateY(flipText ? pi : 0),
                        child: _buildCoinFace(showHeads ? "HEADS" : "TAILS"),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 36),

              // Large result headline similar to reference (e.g., "HEADS")
              Text(
                _result.isNotEmpty ? _result : "TAP",
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Result message line: "The result is Heads. Coin flipped at ..."
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _resultMessage.isNotEmpty
                      ? _resultMessage
                      : (_isSpinning ? "Spinning..." : "Tap the coin to flip!"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
