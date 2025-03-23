import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    try {

      return await _client.auth.signUp(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> addUserToDatabase(String userId, String email, String username) async {
    final name = username.toLowerCase();
    try {
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        'username': name,
      });

      await _client.from('user_settings').insert({
        'user_id': userId,
        'location_sharing': true,
      });
    } catch (e) {
      throw Exception('Failed to add user to database: ${e.toString()}');
    }
  }

  Future<bool> usernameExists(String username) async {
    final response = await _client.from('users').select().eq('username', username);

    return response.isNotEmpty;
  }

  Future<void> deleteAccount(userId) async {
    try {
      final supabaseClient = SupabaseClient('https://neqdscflzlkjkmuwcazq.supabase.co',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lcWRzY2ZsemxramttdXdjYXpxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNTE0MDY1NywiZXhwIjoyMDUwNzE2NjU3fQ.5olvACI6wH-nqSPYIfbPirkSvNkPPb6gH8NWF3pi1mE');

      await _client.from('users').delete().eq('id', userId);
      await supabaseClient.auth.admin.deleteUser(userId);
      print('user deleted');
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }
}
