import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrickService {
  List<Map<String, dynamic>> tricks = [];

  Future<void> loadTricks() async {
    try {
      final String response = await rootBundle.loadString('assets/store/skate-tricks.json');
      final List<dynamic> data = json.decode(response);

      if (data.isEmpty) {
        throw Exception("De JSON-lijst is leeg. Controleer of het bestand correct is.");
      }

      tricks = List<Map<String, dynamic>>.from(data);
      print("✅ Tricks succesvol geladen: ${tricks.length} tricks");
    } on PlatformException catch (e) {
      print("❌ PlatformException bij laden van JSON: ${e.message}");
      throw Exception("Er was een probleem bij het laden van de tricks. Controleer het JSON-bestand.");
    } on FormatException catch (e) {
      print("❌ JSON Parsing-fout: ${e.message}");
      throw Exception("De JSON is ongeldig of beschadigd.");
    } catch (e) {
      print("❌ Onverwachte fout bij laden van tricks: $e");
      throw Exception("Er is een onbekende fout opgetreden bij het laden van de tricks.");
    }
  }

  Future<List<Map<String, dynamic>>> getDailyChallenges() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastDate = prefs.getString("lastChallengeDate");
      String today = DateTime.now().toIso8601String().split('T')[0];

      if (lastDate == today) {
        String? savedChallenges = prefs.getString("dailyChallenges");
        if (savedChallenges != null) {
          print("✅ Opgeslagen challenges geladen!");
          return List<Map<String, dynamic>>.from(json.decode(savedChallenges));
        }
      }

      await loadTricks();
      if (tricks.isEmpty) {
        throw Exception("Geen tricks beschikbaar voor challenges.");
      }

      List<Map<String, dynamic>> newChallenges = _generateDailyChallenges();
      await prefs.setString("lastChallengeDate", today);
      await prefs.setString("dailyChallenges", json.encode(newChallenges));

      print("✅ Nieuwe daily challenges gegenereerd!");
      return newChallenges;
    } on TimeoutException catch (e) {
      print("❌ Timeout-fout: ${e.message}");
      throw Exception("De aanvraag duurde te lang. Probeer het later opnieuw.");
    } on FormatException catch (e) {
      print("❌ JSON Parsing-fout bij het opslaan van challenges: ${e.message}");
      throw Exception("Opslag van challenges is mislukt. Controleer je opslagruimte.");
    } catch (e) {
      print("❌ Onverwachte fout bij het ophalen van daily challenges: $e");
      return []; // Voorkom crash bij fouten, retourneer een lege lijst.
    }
  }

  List<Map<String, dynamic>> _generateDailyChallenges() {
    if (tricks.isEmpty) {
      print("⚠️ Geen tricks gevonden, returning empty list.");
      return [];
    }

    List<Map<String, dynamic>> easyTricks = tricks.where((t) => t['difficulty'] < 30).toList();
    List<Map<String, dynamic>> allTricks = List.from(tricks);
    final random = Random();
    List<Map<String, dynamic>> selectedChallenges = [];

    try {
      // ✅ Voeg 2 makkelijke tricks toe
      while (selectedChallenges.length < 2 && easyTricks.isNotEmpty) {
        selectedChallenges.add(easyTricks.removeAt(random.nextInt(easyTricks.length)));
      }

      // ✅ Vul aan met 3 willekeurige tricks
      while (selectedChallenges.length < 5 && allTricks.isNotEmpty) {
        selectedChallenges.add(allTricks.removeAt(random.nextInt(allTricks.length)));
      }

      print("✅ Challenges gegenereerd: ${selectedChallenges.length}");
      return selectedChallenges;
    } catch (e) {
      print("❌ Fout bij genereren van challenges: $e");
      return [];
    }
  }
}
