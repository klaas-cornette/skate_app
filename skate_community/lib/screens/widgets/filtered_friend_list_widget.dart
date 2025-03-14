import 'package:flutter/material.dart';

class FilteredFriendListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filteredFriends;
  final Function(String username, String friendId) onTap;

  const FilteredFriendListWidget ({
    super.key,
    required this.filteredFriends,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredFriends.isEmpty) {
      return const Center(child: Text('Geen vrienden gevonden.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = filteredFriends[index];
        // Pas aan aan je datastructuur (hier: friend['username']?)
        final username = friend['username'] ?? 'Onbekend';
        final friendId = friend['id']; // ID om chat te starten

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.message, color: Colors.white),
            ),
            title: Text('Chat met: $username'),
            onTap: () {
              onTap(username, friendId);
            },
          ),
        );
      },
    );
  }
}
