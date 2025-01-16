import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

class SkateparkService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List> fetchSkateparks() async {
    try {
      // Probeer de skateparken op te halen
      final response = await _client.from('skateparks').select('*');
      
      // Controleer of de response leeg of ongeldig is
      if (response.isEmpty) {
        throw Exception("De lijst met skateparken is leeg. Controleer of de database gevuld is.");
      }
      return response;
    } on PostgrestException catch (e) {
      // Fout specifiek gerelateerd aan Supabase/Postgrest
      print("Postgrest-fout: ${e.message}");
      throw Exception("Er is een fout opgetreden bij het ophalen van de skateparken: ${e.message}");
    } on TimeoutException catch (e) {
      // Timeout fout
      print("Timeout-fout: ${e.message}");
      throw Exception("De aanvraag naar de server heeft te lang geduurd. Probeer het later opnieuw.");
    } on SocketException catch (e) {
      // Netwerkfout
      print("Netwerkfout: ${e.message}");
      throw Exception("Geen netwerkverbinding. Controleer je internetverbinding en probeer het opnieuw.");
    } catch (e) {
      // Algemene fout
      print("Onverwachte fout: $e");
      throw Exception("Er is een onverwachte fout opgetreden: $e");
    }
  }

  Future<Map> fetchSkateparkById(String id) async {
    try {
      // Probeer het skatepark op te halen
      final response = await _client.from('skateparks').select('*').eq('id', id).single();
      
      // Controleer of de response leeg of ongeldig is
      if (response.isEmpty) {
        throw Exception("Het skatepark met ID $id is niet gevonden.");
      }
      return response;
    } on PostgrestException catch (e) {
      // Fout specifiek gerelateerd aan Supabase/Postgrest
      print("Postgrest-fout: ${e.message}");
      throw Exception("Er is een fout opgetreden bij het ophalen van het skatepark: ${e.message}");
    } on TimeoutException catch (e) {
      // Timeout fout
      print("Timeout-fout: ${e.message}");
      throw Exception("De aanvraag naar de server heeft te lang geduurd. Probeer het later opnieuw.");
    } on SocketException catch (e) {
      // Netwerkfout
      print("Netwerkfout: ${e.message}");
      throw Exception("Geen netwerkverbinding. Controleer je internetverbinding en probeer het opnieuw.");
    } catch (e) {
      // Algemene fout
      print("Onverwachte fout: $e");
      throw Exception("Er is een onverwachte fout opgetreden: $e");
    }
  }
}
