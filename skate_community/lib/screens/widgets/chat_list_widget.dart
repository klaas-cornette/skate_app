import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ChatListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> chats;
  final SupabaseClient supabase;
  final Function(Map<String, dynamic> chat) onOpenChat;

  const ChatListWidget ({
    super.key,
    required this.chats,
    required this.supabase,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return const Center(child: Text('Je hebt nog geen chats.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.parse(chat['created_at']));

        final currentUserId = supabase.auth.currentUser!.id;
        // Pas aan naar jouw datastructuur
        final chatPartnerUsername = (chat['user1_id'] == currentUserId)
            ? chat['user2']['username']
            : chat['user1']['username'];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.chat, color: Colors.white),
            ),
            title: Text('Chat met: $chatPartnerUsername'),
            subtitle: Text(formattedDate),
            onTap: () {
              // We roepen onOpenChat aan met de chat + evt. extra info
              onOpenChat({
                'id': chat['id'],
                'partnerName': chatPartnerUsername,
              });
            },
          ),
        );
      },
    );
  }
}
