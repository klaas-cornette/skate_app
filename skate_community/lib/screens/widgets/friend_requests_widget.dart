import 'package:flutter/material.dart';

class FriendRequestsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> friendRequests;
  final bool isLoading;
  final Function(String requestId, String senderId) onAccept;
  final Function(String requestId) onDecline;

  const FriendRequestsWidget({
    super.key,
    required this.friendRequests,
    required this.isLoading,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    if (friendRequests.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            final request = friendRequests[index];
            final sender = request['sender'];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(sender['username'] ?? sender['email']),
                subtitle: Text(sender['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Color(0xFF0C1033)),
                      onPressed: isLoading
                          ? null
                          : () => onAccept(request['id'], sender['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: isLoading
                          ? null
                          : () => onDecline(request['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
