import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int index;

  const LeaderboardCard({
    super.key,
    required this.entry,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundImage: entry['avatar_url'] != null
              ? NetworkImage(entry['avatar_url'])
              : const AssetImage('assets/images/default_profile.png')
                  as ImageProvider,
        ),
        title: Text(
          entry['username'] ?? 'Onbekend',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${entry['total_score']} punten'),
        trailing: Text(
          '#${index + 1}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
