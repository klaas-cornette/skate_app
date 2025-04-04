import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

class SesionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getFilteredSessions(String skateParkId) async {
    try {
      final currentUserId = _client.auth.currentUser!.id;

      final friendsResponse = await _client.from('friends').select('friend_id').or('user_id.eq.$currentUserId');

      final friendIds = (friendsResponse as List)
          .map((friend) => friend['friend_id'] == currentUserId ? friend['user_id'] : friend['friend_id'])
          .toList();

      friendIds.add(currentUserId);

      final response = await _client
          .from('sessions')
          .select('id, start_time, end_time, user_id, user:users (username, email, id)')
          .eq('skatepark_id', skateParkId)
          .order('start_time', ascending: false);

      final sessions = (response as List).where((session) {
        return friendIds.contains(session['user_id']);
      }).toList();

      return sessions.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception("Er is een fout opgetreden bij het ophalen van de sessies: ${e.message}");
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
      throw Exception("Er is een fout opgetreden bij het maken van de sessie: ${e.message}");
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

  Future<List<Map<String, dynamic>>> getUserSession() async {
    final currentUserId = _client.auth.currentUser!.id;

    final response = await _client
        .from('sessions')
        .select('id, start_time, end_time, user_id, user:users (username, email, id), skatepark:skateparks (name)')
        .eq('user_id', currentUserId)
        .order('start_time', ascending: true);

    final now = DateTime.now();

    final filteredSessions = (response as List).where((item) {
      final startTime = DateTime.parse(item['start_time']);
      return startTime.isAfter(now);
    }).toList();

    return filteredSessions.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getFriendSessions() async {
    final userId = _client.auth.currentUser!.id;
    final friendsResponse = await _client.from('friends').select('friend_id, user_id');

    final response = await _client
        .from('sessions')
        .select('id, start_time, end_time, user_id, skatepark_id, user:users (username, email, id), skatepark:skateparks (name)')
        .order('start_time', ascending: true);

    final now = DateTime.now();

    final filteredData = response.where((item) {
      return friendsResponse.any(
        (friend) => friend['user_id'] == item['user_id'] || friend['friend_id'] == item['user_id'],
      );
    }).toList();

    final filteredSessions = filteredData.where((item) {
      final startTime = DateTime.parse(item['start_time']);
      return item['user_id'] != userId && startTime.isAfter(now);
    }).toList();

    return (filteredSessions as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getSessionById(String sessionId) async {
    final response = await _client
        .from('sessions')
        .select('id, start_time, end_time, skatepark_id, user_id, user:users (username, email, id)')
        .eq('id', sessionId)
        .single();

    return response;
  }
}
