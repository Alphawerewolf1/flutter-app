import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quinez/auth_service.dart';
import 'package:quinez/home_page.dart';
import 'package:quinez/main.dart'; // Import for WelcomeScreen

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User logged in → go to home
          return const HomePage();
        } else {
          // No user logged in → go to welcome screen (not login)
          return const WelcomeScreen();
        }
      },
    );
  }
}
