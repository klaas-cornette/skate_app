// lib/main.dart
import 'package:flutter/material.dart';
import 'package:skate_community/screens/auth/auth_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://neqdscflzlkjkmuwcazq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lcWRzY2ZsemxramttdXdjYXpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUxNDA2NTcsImV4cCI6MjA1MDcxNjY1N30.6zgC0tJSw2u-vfneVVolFYGhPxL2CeOarNzAug23HF8',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skate Community',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Gebruik AuthWrapper als home
    );
  }
}
