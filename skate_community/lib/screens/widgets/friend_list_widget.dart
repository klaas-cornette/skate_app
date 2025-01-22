import 'package:flutter/material.dart';

class FriendsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final bool isLoading;
  final Function(Map<String, dynamic> user, String userId) onChat;
  final Function(String friendId) onDelete;

  const FriendsListWidget({
    super.key,
    required this.friends,
    required this.isLoading,
    required this.onChat,
    required this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context, String friendId) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Vriend verwijderen"),
          content:
              const Text("Weet je zeker dat je deze vriend wilt verwijderen?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Annuleren"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Verwijderen",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onDelete(friendId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Vriendenlijst
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            final user = friend['users'];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(user['username'] ?? user['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.blue),
                      onPressed:
                          isLoading ? null : () => onChat(user, user['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: isLoading
                          ? null
                          : () {
                              _confirmDelete(context, friend['friend_id']);
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Loader overlay
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
