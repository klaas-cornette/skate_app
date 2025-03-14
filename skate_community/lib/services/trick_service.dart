import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrickService {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> tricks = [];

  Future<void> loadTricks() async {
    try {
      final String response = await rootBundle.loadString('assets/store/skate-tricks.json');
      final List<dynamic> data = json.decode(response);

      if (data.isEmpty) {
        throw Exception("De JSON-lijst is leeg. Controleer of het bestand correct is.");
      }

      tricks = List<Map<String, dynamic>>.from(data);
      print("Tricks succesvol geladen: ${tricks.length} tricks");
    } on PlatformException catch (e) {
      print("PlatformException bij laden van JSON: ${e.message}");
      throw Exception("Er was een probleem bij het laden van de tricks. Controleer het JSON-bestand.");
    } on FormatException catch (e) {
      print("JSON Parsing-fout: ${e.message}");
      throw Exception("De JSON is ongeldig of beschadigd.");
    } catch (e) {
      print("Onverwachte fout bij laden van tricks: $e");
      throw Exception("Er is een onbekende fout opgetreden bij het laden van de tricks.");
    }
  }

  Future<List<Map<String, dynamic>>> getDailyChallenges() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastDate = prefs.getString("lastChallengeDate");
      String today = DateTime.now().toIso8601String().split('T')[0];
      final user = _client.auth.currentUser!.id;

      if (lastDate == today) {
        final response = await _client.from('daily_challenges').select('*').eq('created_at', today).eq('user_id', _client.auth.currentUser!.id);
        print("Daily challenges voor vandaag: $response");
        if (response.isNotEmpty) {
          return List<Map<String, dynamic>>.from(response);
        }
        await loadTricks();
        if (tricks.isEmpty) {
          throw Exception("Geen tricks beschikbaar voor challenges.");
        }

        await _generateDailyChallenges();
        await prefs.setString("lastChallengeDate", today);
        await prefs.setString("lastChallengeUser", user);

        print("Nieuwe daily challenges gegenereerd!");

        final data = await _client.from('daily_challenges').select('*').eq('created_at', today).eq('user_id', _client.auth.currentUser!.id);

        print(data);
        return List<Map<String, dynamic>>.from(data);
      }

      await loadTricks();
        if (tricks.isEmpty) {
          throw Exception("Geen tricks beschikbaar voor challenges.");
        }

        await _generateDailyChallenges();
        await prefs.setString("lastChallengeDate", today);
        await prefs.setString("lastChallengeUser", user);

        print("Nieuwe daily challenges gegenereerd!");

        final data = await _client.from('daily_challenges').select('*').eq('created_at', today).eq('user_id', _client.auth.currentUser!.id);

        print(data);
        return List<Map<String, dynamic>>.from(data);
    } on TimeoutException catch (e) {
      print("Timeout-fout: ${e.message}");
      throw Exception("De aanvraag duurde te lang. Probeer het later opnieuw.");
    } on FormatException catch (e) {
      print("JSON Parsing-fout bij het opslaan van challenges: ${e.message}");
      throw Exception("Opslag van challenges is mislukt. Controleer je opslagruimte.");
    } catch (e) {
      print("Onverwachte fout bij het ophalen van daily challenges: $e");
      return []; // Voorkom crash bij fouten, retourneer een lege lijst.
    }
  }

  Future<List<Map<String, dynamic>>> _generateDailyChallenges() async {
    List<Map<String, dynamic>> easyTricks = tricks.where((t) => t['difficulty'] < 30).toList();
    List<Map<String, dynamic>> allTricks = List.from(tricks);
    final random = Random();

    List<Map<String, dynamic>> selectedChallenges = [];

    try {
      while (selectedChallenges.length < 3 && easyTricks.isNotEmpty) {
        selectedChallenges.add(easyTricks.removeAt(random.nextInt(easyTricks.length)));
      }

      while (selectedChallenges.length < 5 && allTricks.isNotEmpty) {
        selectedChallenges.add(allTricks.removeAt(random.nextInt(allTricks.length)));
      }

      print("Challenges gegenereerd: ${selectedChallenges.length}");

      String today = DateTime.now().toIso8601String().split('T')[0];

      final existingChallenges = await _client.from('daily_challenges').select('trick_id').eq('created_at', today).eq('user_id', _client.auth.currentUser!.id);

      final existingTrickIds = existingChallenges.map((e) => e['trick_id'].toString()).toSet();
      final newTrickIds = selectedChallenges.map((e) => e['id'].toString()).toSet();

      print("Bestaande challenges: $existingTrickIds");
      print("Nieuwe challenges: $newTrickIds");

      // **Stap 2: Als de challenges hetzelfde zijn, doe niks**
      if (existingTrickIds.containsAll(newTrickIds) && newTrickIds.containsAll(existingTrickIds)) {
        print("⚠️ Daily challenges zijn al hetzelfde, geen update nodig.");
        return selectedChallenges;
      }

      // **Stap 3: Verwijder de oude challenges als er nieuwe zijn**
      await _client.from('daily_challenges').delete().neq('created_at', today);
      print("🗑️ Oude daily challenges verwijderd.");

      // **Stap 4: Voeg de nieuwe daily challenges toe**
      List<Map<String, dynamic>> challengesToInsert = selectedChallenges
          .map((challenge) => {
                "trick_id": challenge['id'],
                "user_id": _client.auth.currentUser!.id,
                "completed": false,
                "points": challenge['difficulty'],
                "name": challenge['name'],
                "created_at": today,
              })
          .toList();

      await _client.from('daily_challenges').insert(challengesToInsert);
      print("✅ Nieuwe daily challenges toegevoegd aan de database!");

      return selectedChallenges;
    } catch (e) {
      print("❌ Fout bij genereren van challenges: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getActiveChallengById(challengeId) async {
    try {
      final response = await _client.from('daily_challenges').select('*').eq("trick_id", challengeId).eq("user_id", _client.auth.currentUser!.id).single();

      return response;
    } on TimeoutException catch (e) {
      print("Timeout-fout: ${e.message}");
      throw Exception("De aanvraag duurde te lang. Probeer het later opnieuw.");
    } on FormatException catch (e) {
      print("JSON Parsing-fout bij het opslaan van challenges: ${e.message}");
      throw Exception("Opslag van challenges is mislukt. Controleer je opslagruimte.");
    } catch (e) {
      print("Onverwachte fout bij het ophalen van daily challenges: $e");
      return {};
    }
  }

  Future<void> addUserChallenge(String challengeId, String trickName, int points) async {
    try {
      final userId = _client.auth.currentUser!.id;

      await _client.from('daily_challenges').update({"completed": true}).eq('trick_id', challengeId);

      final existingChallenge = await _client.from('user_tricks').select('count').eq('user_id', userId).eq('trick_id', challengeId);

      if (existingChallenge.isNotEmpty) {
        print("✅ Challenge bestaat al, bijwerken...");
        final lastCompleted = DateTime.now().toIso8601String();
        await _client
            .from('user_tricks')
            .update({
              "count": existingChallenge[0]['count'] + 1,
              "last_completed": lastCompleted,
            })
            .eq('user_id', userId)
            .eq('trick_id', challengeId);

        print("✅ Challenge bijgewerkt!");
        return;
      }

      await _client.from('user_tricks').insert({
        "user_id": userId,
        "trick_id": challengeId,
        "trick_name": trickName,
        "points": points,
        "count": 1,
        "last_completed": DateTime.now().toIso8601String(),
      });

      print("✅ Challenge toegevoegd aan gebruiker!");
    } on PostgrestException catch (e) {
      print("❌ Postgrest-fout bij toevoegen van challenge: ${e.message}");
      throw Exception("Fout bij toevoegen van challenge: ${e.message}");
    } on TimeoutException catch (e) {
      print("⏳ Timeout-fout: ${e.message}");
      throw Exception("De aanvraag duurde te lang. Probeer het later opnieuw.");
    } catch (e) {
      print("❌ Onverwachte fout bij toevoegen van challenge: $e");
      throw Exception("Kan challenge niet toevoegen.");
    }
  }

  Future<void> removeUserChallenge(String challengeId) async {
    try {
      final userId = _client.auth.currentUser!.id;

      await _client.from('daily_challenges').update({"completed": false}).eq('trick_id', challengeId);

      final challenge = await _client.from('user_tricks').select('count').eq('user_id', userId).eq('trick_id', challengeId).single();

      final count = challenge['count'] - 1;
      await _client.from('user_tricks').update({"count": count}).eq('user_id', userId).eq('trick_id', challengeId);

      print("✅ Challenge verwijderd!");
    } on PostgrestException catch (e) {
      print("❌ Postgrest-fout bij verwijderen van challenge: ${e.message}");
      throw Exception("Fout bij verwijderen van challenge: ${e.message}");
    } on TimeoutException catch (e) {
      print("⏳ Timeout-fout: ${e.message}");
      throw Exception("De aanvraag duurde te lang. Probeer het later opnieuw.");
    } catch (e) {
      print("❌ Onverwachte fout bij verwijderen van challenge: $e");
      throw Exception("Kan challenge niet verwijderen.");
    }
  }

  Future<List<Map<String, dynamic>>> getUserCompletedChallenges(String userId) async {
    try {
      final response = await _client.from('user_tricks').select('*').eq('user_id', userId);

      if (response.isEmpty) {
        print("ℹ️ Geen voltooide challenges gevonden.");
        return [];
      }

      print("✅ Voltooide challenges opgehaald!");
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      print("❌ Postgrest-fout bij ophalen van challenges: ${e.message}");
      throw Exception("Kan voltooide challenges niet ophalen: ${e.message}");
    } on TimeoutException catch (e) {
      print("⏳ Timeout-fout: ${e.message}");
      throw Exception("De aanvraag duurde te lang. Probeer het later opnieuw.");
    } catch (e) {
      print("❌ Onverwachte fout bij ophalen van challenges: $e");
      return [];
    }
  }
}
