import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

class SesionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createSession(startTime, endTime, String selectedSkatepark) async {
    try {
      await _client.from('sessions').insert({
        'start_time': startTime,
        'end_time': endTime,
        'skatepark_id': selectedSkatepark,
        'user_id': _client.auth.currentUser?.id,
      });
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het maken van de sessie: ${e.message}");
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