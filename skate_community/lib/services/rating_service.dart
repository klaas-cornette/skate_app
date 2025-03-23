import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

class RatingService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getRatingsForSkatepark(String skateparkId) async {
    try {
      final response = await _client
          .from('ratings')
          .select('obstacles, maintenance, weather, community')
          .eq('skatepark_id', skateparkId);

      final data = response as List;
      if (data.isEmpty) {
        return {
          'obstacles': 0.0,
          'maintenance': 0.0,
          'weather': 0.0,
          'community': 0.0,
          'count': 0,
        };
      }

      double obstaclesSum = 0;
      double maintenanceSum = 0;
      double weatherSum = 0;
      double communitySum = 0;
      final count = data.length;

      for (var row in data) {
        obstaclesSum += (row['obstacles'] as int).toDouble();
        maintenanceSum += (row['maintenance'] as int).toDouble();
        weatherSum += (row['weather'] as int).toDouble();
        communitySum += (row['community'] as int).toDouble();
      }

      return {
        'obstacles': obstaclesSum / count,
        'maintenance': maintenanceSum / count,
        'weather': weatherSum / count,
        'community': communitySum / count,
        'count': count,
      };
    } on PostgrestException catch (e) {
      throw Exception('Postgrest-fout: ${e.message}');
    } on TimeoutException catch (e) {
      throw Exception('Timeout-fout: ${e.message}');
    } on SocketException catch (e) {
      throw Exception('Netwerkfout: ${e.message}');
    } catch (e) {
      throw Exception('Onverwachte fout: $e');
    }
  }

  Future<void> saveRating({
    required String skateparkId,
    required double obstacles,
    required double maintenance,
    required double weather,
    required double community,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Geen ingelogde gebruiker gevonden');
      }
      final checkResponse =
          await _client.from('ratings').select('id').eq('user_id', userId).eq('skatepark_id', skateparkId);

      if (checkResponse.isEmpty) {
        await _client.from('ratings').insert({
          'user_id': userId,
          'skatepark_id': skateparkId,
          'obstacles': obstacles.round(),
          'maintenance': maintenance.round(),
          'weather': weather.round(),
          'community': community.round(),
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      } else {
        final ratingId = checkResponse[0]['id'] as String;
        await _client.from('ratings').update({
          'obstacles': obstacles.round(),
          'maintenance': maintenance.round(),
          'weather': weather.round(),
          'community': community.round(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', ratingId);
      }
    } on PostgrestException catch (e) {
      throw Exception('Postgrest-fout: ${e.message}');
    } on TimeoutException catch (e) {
      throw Exception('Timeout-fout: ${e.message}');
    } on SocketException catch (e) {
      throw Exception('Netwerkfout: ${e.message}');
    } catch (e) {
      throw Exception('Onverwachte fout: $e');
    }
  }
}
