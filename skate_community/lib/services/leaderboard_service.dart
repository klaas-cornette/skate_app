import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/services/friend_service.dart';
import 'dart:async';
import 'dart:io';

class LeaderboardService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getLeaderboard() async {
    try {
      final response = await _client.from('user_tricks').select('*, user_id:users(id, username, profile_image)');
      final data = response; // Controleer eventueel of dit 'response.data' moet zijn.

      final Map<String, Map<String, dynamic>> leaderboardMap = {};

      for (var row in data) {
        // Haal de user data op uit de joined data.
        final userMap = row['user_id'] as Map<String, dynamic>;
        final userId = userMap['id'] as String;
        final trickScore = (row['points'] as int) * (row['count'] as int);
        if (!leaderboardMap.containsKey(userId)) {
          leaderboardMap[userId] = {
            'username': userMap['username'],
            'avatar_url': userMap['profile_image'],
            'total_score': 0,
          };
        }
        leaderboardMap[userId]!['total_score'] = (leaderboardMap[userId]!['total_score'] as int) + trickScore;
      }

      final leaderboardList = leaderboardMap.entries.map((entry) {
        final userInfo = entry.value;
        return {
          'user_id': entry.key,
          'username': userInfo['username'],
          'avatar_url': userInfo['avatar_url'],
          'total_score': userInfo['total_score'],
        };
      }).toList()
        ..sort((a, b) => (b['total_score'] as int).compareTo(a['total_score'] as int));

      return {
        'leaderboard': leaderboardList,
      };
    } on PostgrestException catch (e) {
      // Fout specifiek gerelateerd aan Supabase/Postgrest.
      print("Postgrest-fout: ${e.message}");
      throw Exception("Er is een fout opgetreden bij het ophalen van de leaderboard: ${e.message}");
    } on TimeoutException catch (e) {
      // Timeout fout.
      print("Timeout-fout: ${e.message}");
      throw Exception("De aanvraag naar de server heeft te lang geduurd. Probeer het later opnieuw.");
    } on SocketException catch (e) {
      // Netwerkfout.
      print("Netwerkfout: ${e.message}");
      throw Exception("Geen netwerkverbinding. Controleer je internetverbinding en probeer het opnieuw.");
    } catch (e) {
      // Algemene fout.
      print("Onverwachte fout: $e");
      throw Exception("Er is een onverwachte fout opgetreden: $e");
    }
  }

  Future<Map<String, dynamic>> getFriendsLeaderboard() async {
    final FriendsService friendsService = FriendsService();
    try {
      final leaderboard = await getLeaderboard();
      final friends = await friendsService.getFriends();
      List friendIds = friends.map((friend) => friend['friend_id']).toList();
      friendIds.add(_client.auth.currentUser!.id);  
      final friendsLeaderboard = leaderboard['leaderboard'].where((entry) => friendIds.contains(entry['user_id'])).toList();

      return {
        'leaderboard': friendsLeaderboard,
      };
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception("Er is een fout opgetreden bij het ophalen van de vrienden leaderboard: ${e.message}");
    } on TimeoutException catch (e) {
      print("Timeout-fout: ${e.message}");
      throw Exception("De aanvraag naar de server heeft te lang geduurd. Probeer het later opnieuw.");
    } on SocketException catch (e) {
      print("Netwerkfout: ${e.message}");
      throw Exception("Geen netwerkverbinding. Controleer je internetverbinding en probeer het opnieuw.");
    } catch (e) {
      print("Onverwachte fout: $e");
      throw Exception("Er is een onverwachte fout opgetreden: $e");
    }
  }
}
