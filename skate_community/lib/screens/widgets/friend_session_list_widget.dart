// lib/screens/session_list/friend_session_list_widget.dart

import 'package:flutter/material.dart';
import 'package:skate_community/screens/widgets/friend_session_card.dart';

class FriendSessionListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final Function(String sessionId) onJoinSession;

  const FriendSessionListWidget({
    super.key,
    required this.sessions,
    required this.onJoinSession,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return FriendSessionCard(
          session: session,
          onJoin: onJoinSession,
        );
      },
    );
  }
}
