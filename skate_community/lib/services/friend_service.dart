// lib/services/friend_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

class FriendsService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Zoekt gebruikers op basis van een zoekterm (username of email)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('users') // Verwijs naar de juiste tabel
          .select('id, email, username')
          .ilike('username', '%$query%') // Case-insensitive search
          .neq('id', _client.auth.currentUser!.id);

      return response.map((map) => Map<String, dynamic>.from(map)).toList();
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

  /// Stuurt een vriendverzoek
  Future<void> sendFriendRequest(String receiverId) async {
    try {
      // Controleer of er al een bestaand verzoek of vriendschap is
      List<dynamic> existingRequestResponse = [];
      existingRequestResponse = await _client
          .from('friend_requests')
          .select('*')
          .or('sender_id.eq.${_client.auth.currentUser!.id},receiver_id.eq.${_client.auth.currentUser!.id}')
          .eq('receiver_id', receiverId)
          .eq('sender_id', _client.auth.currentUser!.id);

      if (existingRequestResponse.isNotEmpty) {
        throw Exception('Vriendverzoek is al verzonden.');
      }

      // Controleer of jullie al bevriend zijn
      List<dynamic> existingFriendResponse = [];
      existingFriendResponse = await _client
          .from('friends')
          .select('*')
          .or('user_id.eq.${_client.auth.currentUser!.id},friend_id.eq.${_client.auth.currentUser!.id}')
          .eq('friend_id', receiverId)
          .eq('user_id', _client.auth.currentUser!.id);

      if (existingFriendResponse.isNotEmpty) {
        throw Exception('Je bent al bevriend met deze gebruiker.');
      }

      // Verzend het vriendverzoek
      await _client.from('friend_requests').insert({
        'sender_id': _client.auth.currentUser!.id,
        'receiver_id': receiverId,
      });
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het verzenden van het vriendverzoek: ${e.message}");
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

  /// Haalt inkomende vriendverzoeken op
  Future<List<Map<String, dynamic>>> getIncomingFriendRequests() async {
    try {
      final response = await _client
          .from('friend_requests')
          .select(
              'id, sender_id, receiver_id, status, created_at, sender:users (username, email, id)')
          .eq('receiver_id', _client.auth.currentUser!.id)
          .eq('status', 'pending');

      return response.map((map) => Map<String, dynamic>.from(map)).toList();
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het ophalen van vriendverzoeken: ${e.message}");
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

  /// Accepteert een vriendverzoek
  Future<void> acceptFriendRequest(String requestId, String senderId) async {
    try {
      await _client.rpc('accept_friend_request', params: {
        'f_request_id': requestId,
        'f_sender_id': senderId,
      });
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het accepteren van het vriendverzoek: ${e.message}");
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

  /// Decline een vriendverzoek
  Future<void> declineFriendRequest(String requestId) async {
    try {
      final response = await _client
          .from('friend_requests')
          .update({'status': 'declined'}).eq('id', requestId);

      if (response.error != null) {
        throw Exception(
            'Error declining friend request: ${response.error!.message}');
      }
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het weigeren van het vriendverzoek: ${e.message}");
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

  /// Haalt de vriendenlijst op
  Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final response = await _client
          .from('friends')
          .select('id, friend_id, users (id, username, email)')
          .eq('user_id', _client.auth.currentUser!.id);

      return response.map((map) => Map<String, dynamic>.from(map)).toList();
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het ophalen van je vrienden: ${e.message}");
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

  /// Delete friend
  Future<void> deleteFriend(String friendId) async {
    try {
      await _client
          .from('friends')
          .delete()
          .eq('user_id', _client.auth.currentUser!.id)
          .eq('friend_id', friendId);

      await _client
          .from('friends')
          .delete()
          .eq('friend_id', _client.auth.currentUser!.id)
          .eq('user_id', friendId);

      await _client.from('friend_requests').delete().or(
          'and(sender_id.eq.$friendId,receiver_id.eq.${_client.auth.currentUser!.id}),''and(sender_id.eq.${_client.auth.currentUser!.id},receiver_id.eq.$friendId)');
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het verwijderen van de vriend: ${e.message}");
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
