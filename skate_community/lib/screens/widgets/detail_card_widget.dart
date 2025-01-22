import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final Map<String, dynamic>? skatepark;

  const DetailCard({super.key, required this.skatepark});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              skatepark!['name'],
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                  color: Color(0xFF0C1033)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.toggle_on, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Buiten: ${skatepark!['indoor'] ? 'Nee' : 'Ja'}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.wc, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'WC: ${skatepark!['hasWc'] ? 'Ja' : 'Nee'}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if(!skatepark!['indoor'])Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.yellow),
                const SizedBox(width: 8),
                Text(
                  'Verlichting: ${skatepark!['lightedUntil']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            if(!skatepark!['indoor'])const SizedBox(height: 10),
            
            Row(
              children: [
                const Icon(Icons.straighten, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  skatepark!['size'],
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
}
