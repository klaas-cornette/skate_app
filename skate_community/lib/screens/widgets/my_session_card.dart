
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MySessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  const MySessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.parse(session['start_time']);
    final endTime = DateTime.parse(session['end_time']);
    final startFmt = DateFormat('dd MMM yyyy, HH:mm').format(startTime);
    final endFmt = DateFormat('HH:mm').format(endTime);

    final skateparkName = session['skatepark']?['name'] ?? 'Onbekend Park';
    final userName = session['user']?['username'] ?? 'Onbekend Gebruiker';

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
            // Bovenste rij: Skatepark links, geen join-knop hier
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    skateparkName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0C1033),
                    ),
                  ),
                ),
                // evt. actions in "Mijn Sessie"
              ],
            ),
            const SizedBox(height: 8),
            // Datum
            Text(
              '$startFmt - $endFmt',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Gebruiker
            Text(
              'Door: $userName',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
