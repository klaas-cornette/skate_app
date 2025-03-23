import 'package:flutter/material.dart';
import 'package:skate_community/screens/auth/sign_in_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthMiddleware extends StatefulWidget {
  final Widget child;
  const AuthMiddleware({super.key, required this.child});

  @override
  _AuthMiddlewareState createState() => _AuthMiddlewareState();
}

class _AuthMiddlewareState extends State<AuthMiddleware> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Supabase.instance.client.auth.currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Supabase.instance.client.auth.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
