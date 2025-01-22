import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionList extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;

  const SessionList({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, size: 48, color: Colors.grey),
              const SizedBox(height: 10),
              const Text(
                'Geen geplande sessies beschikbaar.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final user = sessions[index]['user'];
        final session = sessions[index];
        final startTime = DateFormat('dd MMM yyyy, HH:mm')
            .format(DateTime.parse(session['start_time']));
        final endTime =
            DateFormat('HH:mm').format(DateTime.parse(session['end_time']));

        return Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF9AC4F5), // Donkerblauw thema
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF0C1033),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      user['username'] ?? 'Onbekend',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C1033),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Van: $startTime Tot: $endTime',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0C1033),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
