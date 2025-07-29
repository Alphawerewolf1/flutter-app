import 'package:flutter/material.dart';
import 'package:quinez/new_pass.dart'; // Import your new page
import 'package:quinez/main.dart';
import 'package:quinez/sign_up.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final TextEditingController _verificationController = TextEditingController();

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  void _onVerificationSubmitted(String value) {
    if (value.isNotEmpty) {
      // Navigate to NewPass page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewPass()),
      );
    } else {
      // Optionally, show a snackbar or alert if empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const Text(
                  'Forgot Your\nPassword',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                const Text(
                  'Email:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Verification Code label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Verification Code:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),

                // Verification code TextField with controller & onSubmitted
                TextField(
                  controller: _verificationController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: _onVerificationSubmitted,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // VR Image Positioned
          Positioned(
            bottom: screenHeight * 0.01,
            right: screenWidth * 0.01,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/vr.png',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
