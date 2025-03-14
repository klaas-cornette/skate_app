// lib/services/settings_service.dart

import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Haalt de instellingen van de gebruiker op uit de user_settings tabel
  Future<Map<String, dynamic>> loadUserSettings(String userId) async {
    try {
      final response = await _client
          .from('user_settings')
          .select('location_sharing')
          .eq('user_id', userId)
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw Exception('Postgrest error: ${e.message}');
    } on TimeoutException catch (e) {
      throw Exception('Timeout error: ${e.message}');
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update de locatietoegang instelling in de user_settings tabel
  Future<void> updateLocationSharing(String userId, bool value) async {
    try {
      await _client
          .from('user_settings')
          .update({'location_sharing': value}).eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Postgrest error: ${e.message}');
    } on TimeoutException catch (e) {
      throw Exception('Timeout error: ${e.message}');
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
