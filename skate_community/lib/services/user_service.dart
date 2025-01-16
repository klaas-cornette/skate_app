// lib/services/user_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

class UserService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Zoekt gebruikers op basis van een zoekterm (username of email)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('users')
          .select('id, email, username')
          .ilike('username', '%$query%') // Case-insensitive search
          .neq('id', _client.auth.currentUser!.id);

      final data = response;
      return data.map((map) => Map<String, dynamic>.from(map)).toList();
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het zoeken van gebruikers: ${e.message}");
    } on TimeoutException catch (e) {
      print("Timeout-fout: ${e.message}");
      throw Exception(
          "De aanvraag naar de server heeft te lang geduurd. Probeer het later opnieuw.");
    } on SocketException catch (e) {
      print("Netwerkfout: ${e.message}");
      throw Exception(
          "Geen netwerkverbinding. Controleer je internetverbinding en probeer het opnieuw.");
    } catch (e) {
      print("Onverwachte fout: $e");
      throw Exception("Er is een onverwachte fout opgetreden: $e");
    }
  }

  /// Haalt gebruikersdetails op basis van ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('id, email, username')
          .eq('id', userId)
          .single();

      final data = response;
      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het ophalen van de gebruiker: ${e.message}");
    } on TimeoutException catch (e) {
      print("Timeout-fout: ${e.message}");
      throw Exception(
          "De aanvraag naar de server heeft te lang geduurd. Probeer het later opnieuw.");
    } on SocketException catch (e) {
      print("Netwerkfout: ${e.message}");
      throw Exception(
          "Geen netwerkverbinding. Controleer je internetverbinding en probeer het opnieuw.");
    } catch (e) {
      print("Onverwachte fout: $e");
      throw Exception("Er is een onverwachte fout opgetreden: $e");
    }
  }
 
  /// haal de current user op
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _client
          .from('users')
          .select('id, email, username')
          .eq('id', _client.auth.currentUser!.id)
          .single();

      final data = response;
      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het ophalen van de gebruiker: ${e.message}");
    } on TimeoutException catch (e) {
      print("Timeout-fout: ${e.message}");
      throw Exception(
          "De aanvraag naar de server heeft te lang geduurd. Probeer het later opnieuw.");
    } on SocketException catch (e) {
      print("Netwerkfout: ${e.message}");
      throw Exception(
          "Geen netwerkverbinding. Controleer je internetverbinding en probeer het opnieuw.");
    } catch (e) {
      print("Onverwachte fout: $e");
      throw Exception("Er is een onverwachte fout opgetreden: $e");
    }
  }
}
