import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionList extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final void Function(String sessionId)? onJoin; // <-- Toegevoegd

  const SessionList({
    super.key,
    required this.sessions,
    this.onJoin, // <-- Toegevoegd
  });

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
        final session = sessions[index];
        final user = session['user'];

        final sessionId = session['id'].toString();
        final startTime = DateTime.parse(session['start_time']);
        final endTime = DateTime.parse(session['end_time']);
        final startFmt = DateFormat('dd MMM yyyy, HH:mm').format(startTime);
        final endFmt = DateFormat('HH:mm').format(endTime);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          child: Container(
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFFFDE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bovenste rij: Gebruiker en (optioneel) Join-knop
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gebruiker
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF0C1033),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            user?['username'] ?? 'Onbekend',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C1033),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onJoin != null)
                      ElevatedButton.icon(
                        onPressed: () => onJoin!(sessionId),
                        icon: const Icon(Icons.group_add, color: Colors.white),
                        label: const Text('Join'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C1033),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$startFmt - $endFmt',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
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
