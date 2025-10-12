import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize once
  runApp(const NoteCastApp());
}

class NoteCastApp extends StatelessWidget {
  const NoteCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NoteCast',
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final baseSize = math.min(screenWidth, screenHeight);

          final controllerWidth = (baseSize * 0.35).clamp(120, 280).toDouble();
          final controllerHeight = controllerWidth * 0.65;

          final gamerWidth = (baseSize * 0.45).clamp(160, 320).toDouble();
          final gamerHeight = gamerWidth * 0.65;

          final titleFontSize = (baseSize * 0.07).clamp(26, 40).toDouble();

          final textTop = screenHeight * 0.08;
          final buttonTop = screenHeight * 0.52;
          final controllerTop =
              textTop + (buttonTop - textTop) * 0.6 - controllerHeight / 2;

          return Stack(
            children: [
              Positioned(
                top: textTop,
                left: 30,
                child: Text(
                  'Welcome To\nNoteCast',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: controllerTop,
                left: (screenWidth - controllerWidth) / 2,
                child: Transform.rotate(
                  angle: -10 * math.pi / 180,
                  child: Image.asset(
                    'assets/images/controller.png',
                    width: controllerWidth,
                    height: controllerHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: buttonTop,
                left: screenWidth * 0.18,
                right: screenWidth * 0.18,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.61,
                left: 0,
                right: 0,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: (screenWidth - gamerWidth) / 2,
                child: Image.asset(
                  'assets/images/gamer.png',
                  width: gamerWidth,
                  height: gamerHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
