import 'package:flutter/material.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final Function(String userId) onAddFriend;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.isLoading,
    required this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(
              horizontal: 8), // Zorg voor horizontale marges
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 16),
        
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Zorg dat de hoogte zich aanpast aan de inhoud
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  color: Colors.grey,
                  size: 48,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Geen resultaten gevonden',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Probeer een andere zoekterm.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            minTileHeight: 80,
            leading: CircleAvatar(
              backgroundColor: Color(0xFF9AC4F5),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              user['username'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: ElevatedButton(
              onPressed: isLoading ? null : () => onAddFriend(user['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0C1033),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Toevoegen'),
            ),
          ),
        );
      },
    );
  }
}
