import 'package:flutter/material.dart';

class AddFriendRequestsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> friendRequests;
  final bool isLoading;
  final Function(String requestId, String senderId) onAccept;
  final Function(String requestId) onDecline;

  const AddFriendRequestsWidget({
    super.key,
    required this.friendRequests,
    required this.isLoading,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    if (friendRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friendRequests.length,
      itemBuilder: (context, index) {
        final request = friendRequests[index];
        final sender = request['sender'];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              sender['username'] ?? sender['email'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(sender['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed:
                      isLoading ? null : () => onAccept(request['id'], sender['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: isLoading ? null : () => onDecline(request['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
