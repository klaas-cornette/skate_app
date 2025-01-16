// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth
        .signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> addUserToDatabase(
      String userId, String email, String username) async {
    try {
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        'username': username,
      });
    } catch (e) {
      throw Exception('Failed to add user to database: ${e.toString()}');
    }
  }
}
