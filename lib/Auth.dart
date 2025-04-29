import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: [GOOGLE_PUBLIC_KEY] // Web Client ID
  scopes: ['email'],
);

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  double _midPoint = 0.5; // Initial midpoint for gradient
  double _buttonSize = 2.0; // Button size factor (1.0 is the normal size)

  @override
  void initState() {
    super.initState();
    _startGradientAnimation();
  }

  // Function to animate the midpoint of the gradient
  void _startGradientAnimation() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _midPoint = (_midPoint == 0.5) ? 0.7 : 0.5;
        });
        _startGradientAnimation();
      }
    });
  }

  // Function to handle Google Sign-In
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-in failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4795E4), // Bottom Right Color
              Color(0xFFC6667A), // Top Left Color
            ],
            stops: [0.0, _midPoint],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertically centers the content
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontally centers the content
            children: [
              Icon(Icons.food_bank, size: 100, color: Colors.indigo), // App Logo (Placeholder)
              const SizedBox(height: 20),
              const Text(
                "Bite Buddy",
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTapDown: (_) {
                  // When the button is pressed, it shrinks
                  setState(() {
                    _buttonSize = 0.9;
                  });
                },
                onTapUp: (_) {
                  // When the button is released, it grows back to original size
                  setState(() {
                    _buttonSize = 1.0;
                  });
                },
                onTapCancel: () {
                  // If the tap is canceled, return to the original size
                  setState(() {
                    _buttonSize = 1.0;
                  });
                },
                child: Transform.scale(
                  scale: _buttonSize,
                  child: ElevatedButton.icon(
                    onPressed: () => signInWithGoogle(context),
                    icon: const Icon(Icons.login, color: Colors.red), // Google Icon
                    label: const Text("Sign in with Google"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
