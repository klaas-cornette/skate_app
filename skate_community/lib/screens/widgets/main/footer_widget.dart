import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skate_community/screens/home_screen.dart';
import 'package:skate_community/screens/friends/friends_list_screen.dart';
import 'package:skate_community/screens/chat/chat_screen.dart';
import 'package:skate_community/screens/sessions/session_list_screen.dart';
import 'package:skate_community/screens/trick/challenge_screen.dart';

class FooterWidget extends StatelessWidget {
  final int currentIndex;

  const FooterWidget({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FriendsListScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SessionListScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChallengeScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool noSelection = currentIndex == 999;
    final int effectiveIndex = noSelection ? 0 : currentIndex;
    final Color selectedColor = noSelection ? Colors.white70 : Colors.white;
    final Color unselectedColor = Colors.white70;

    return Container(
      padding: const EdgeInsets.only(bottom: 5, top: 5),
      decoration: BoxDecoration(
        color: Color(0xFF0C1033),
      ),
      child: BottomNavigationBar(
        currentIndex: effectiveIndex,
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: Colors.transparent,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Vrienden"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Sessies"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "challenges"),
        ],
      ),
    );
  }
}
