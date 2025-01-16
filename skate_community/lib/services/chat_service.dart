// lib/services/chat_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getChatsFromUser(String userId) async {
    try {
      final response = await _client
          .from('chats')
          .select(
              '*, user1:users!fk_chat_user1(id, username, email), user2:users!fk_chat_user2(id, username, email)')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('created_at', ascending: false);

      return response.map((map) => Map<String, dynamic>.from(map)).toList();
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het ophalen van de chats: ${e.message}");
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

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    try {
      final response = await _client
          .from('messages')
          .select(
              'id, chat_id, sender_id, content, created_at, sender:users (id, username, email)')
          .eq('chat_id', chatId)
          .order('created_at', ascending: false);

      return response.map((map) => Map<String, dynamic>.from(map)).toList();
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het ophalen van de berichten: ${e.message}");
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

  /// Verzendt een bericht naar een specifieke chat
  Future<void> sendMessage(
      String chatId, String senderId, String content) async {
    try {
      await _client.from('messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'content': content,
      });
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het verzenden van het bericht: ${e.message}");
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

  Future<List<Map<String, dynamic>>> findOrMakeChat(String friendId) async {
    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client.from('chats').select('id').or(
          'and(user1_id.eq.$userId,user2_id.eq.$friendId),and(user1_id.eq.$friendId,user2_id.eq.$userId)');

      if (response.isNotEmpty) {
        print('Chat gevonden: $response');
        return response.map((map) => Map<String, dynamic>.from(map)).toList();
      } else {
        print('Geen chat gevonden, maak een nieuwe chat aan.');
        final chatResponse = await _client.from('chats').insert({
          'user1_id': userId,
          'user2_id': friendId,
        }).select('id');
        print('Nieuwe chat aangemaakt: $chatResponse');
        if (chatResponse.isNotEmpty) {
          return chatResponse
              .map((map) => Map<String, dynamic>.from(map))
              .toList();
        } else {
          throw Exception("Fout bij het aanmaken van een nieuwe chat.");
        }
      }
    } on PostgrestException catch (e) {
      print("Postgrest-fout: ${e.message}");
      throw Exception(
          "Er is een fout opgetreden bij het ophalen of aanmaken van de chat: ${e.message}");
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
