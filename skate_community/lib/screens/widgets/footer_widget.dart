import 'package:flutter/material.dart';
import 'package:skate_community/screens/home_screen.dart';
import 'package:skate_community/screens/friends/friends_list_screen.dart';
import 'package:skate_community/screens/chat/chat_screen.dart';
import 'package:skate_community/screens/sessions/session_list_screen.dart';
import 'package:skate_community/screens/trick/challenge_screen.dart';



class FooterWidget extends StatelessWidget {
  final int currentIndex;

  const FooterWidget({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Voorkom dubbele navigatie

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FriendsListScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SessionListScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChallengeScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9AC4F5), Color(0xFF0C1033)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex == 5 ? 999 : currentIndex, // Geen selectie als currentIndex -1 is
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: [
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
