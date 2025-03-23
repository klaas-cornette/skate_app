
import 'package:flutter/material.dart';
import 'package:skate_community/screens/widgets/session/my_session_card.dart';

class MySessionListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  const MySessionListWidget({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return MySessionCard(session: session);
      },
    );
  }
}
