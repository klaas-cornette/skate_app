import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/screens/widgets/chat_list_widget.dart';
import 'package:skate_community/screens/widgets/filtered_friend_list_widget.dart';

class ChatbodyWidget extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> chats;
  final List<Map<String, dynamic>> filteredFriends;
  final SupabaseClient supabase;
  
  // Callback wanneer je in de chats op een item klikt
  final Function(Map<String, dynamic> chat) onOpenChat;
  
  // Callback wanneer je in de gefilterde friends op iemand klikt
  final Function(String username, String friendId) onOpenFilteredFriend;

  const ChatbodyWidget({
    super.key,
    required this.isLoading,
    required this.error,
    required this.chats,
    required this.filteredFriends,
    required this.supabase,
    required this.onOpenChat,
    required this.onOpenFilteredFriend,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!));
    }
    if (filteredFriends.isNotEmpty) {
      return FilteredFriendListWidget(
        filteredFriends: filteredFriends,
        onTap: onOpenFilteredFriend,
      );
    } else {

      return ChatListWidget(
        chats: chats,
        supabase: supabase,
        onOpenChat: onOpenChat,
      );
    }
  }
}
