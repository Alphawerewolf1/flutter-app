import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quinez/forgot_password.dart';
import 'package:quinez/home_page.dart';
import 'package:quinez/sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailOrUsernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    final input = emailOrUsernameController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter both email/username and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String emailToUse = input;
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

      // 🔍 If input is NOT an email, try login first assuming username
      if (!emailRegex.hasMatch(input)) {
        try {
          // Try to sign in directly assuming the username was an email (may fail)
          await _auth.signInWithEmailAndPassword(
              email: input, password: password);
        } on FirebaseAuthException {
          // We'll handle proper username lookup after authentication check below
        }
      }

      // 🔐 Step 1: Try email-based sign-in
      UserCredential? credential;
      try {
        credential = await _auth.signInWithEmailAndPassword(
          email: emailToUse,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // If email sign-in fails and it's not an email input, fallback to username lookup
        if (!emailRegex.hasMatch(input)) {
          // 🔎 Attempt username → email lookup AFTER sign-in check
          final usernameSnapshot = await _firestore
              .collection('users')
              .where('username', isEqualTo: input)
              .limit(1)
              .get();

          if (usernameSnapshot.docs.isEmpty) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No account found with this username',
            );
          }

          final foundEmail = usernameSnapshot.docs.first['email'];
          credential = await _auth.signInWithEmailAndPassword(
            email: foundEmail,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final user = credential?.user;
      if (user == null) throw Exception(
          "Authentication failed — no user found.");

      // ✅ Step 2: Now authenticated, we can safely check Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User record missing in database")),
        );
        await _auth.signOut();
        setState(() => isLoading = false);
        return;
      }

      // ✅ Step 3: Navigate to HomePage
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account found for this email or username";
          break;
        case 'wrong-password':
          message = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          message = "Invalid email format.";
          break;
        default:
          message = "Login failed. ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
          SnackBar(content: Text("Login error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final bool isDesktop = screenWidth >= 900;
    final bool isTablet = screenWidth >= 600 && screenWidth < 900;

    double imageWidth = screenWidth *
        (isDesktop ? 0.22 : isTablet ? 0.28 : 0.36);
    if (imageWidth > 220) imageWidth = 220;
    if (imageWidth < 90) imageWidth = 90;
    final double imageHeight = imageWidth * 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 BACKGROUND IMAGE FIRST → stays behind everything
            Positioned(
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/vr.png',
                    width: imageWidth * 1.3,
                    height: imageHeight * 1.3,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            // 🔹 MAIN FOREGROUND CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Log in to\nNoteCast',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      const Text(
                        'Username or Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailOrUsernameController,
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
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPass(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot?',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: passwordController,
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
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: isLoading ? null : loginUser,
                          child: isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Don’t have an account?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (
                                          context) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}