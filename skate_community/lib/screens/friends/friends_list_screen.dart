import 'package:flutter/material.dart';
import 'package:skate_community/screens/chat/chat_messages_screen.dart';
import 'package:skate_community/screens/friends/add_friends_screen.dart';
import 'package:skate_community/screens/widgets/background_wrapper.dart';
import 'package:skate_community/screens/widgets/friend_list_widget.dart';
import 'package:skate_community/screens/widgets/friend_requests_widget.dart';
import 'package:skate_community/services/friend_service.dart';
import 'package:skate_community/services/chat_service.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final FriendsService _friendsService = FriendsService();
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
    _loadFriends();
  }

  Future<void> _loadFriendRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _friendRequests = await _friendsService.getIncomingFriendRequests();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _friends = await _friendsService.getFriends();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptFriendRequest(String requestId, String senderId) async {
    await _friendsService.acceptFriendRequest(requestId, senderId);
    _loadFriendRequests();
    _loadFriends();
  }

  Future<void> _declineFriendRequest(String requestId) async {
    await _friendsService.declineFriendRequest(requestId);
    _loadFriendRequests();
  }

  Future<void> _deleteFriend(String friendId) async {
    await _friendsService.deleteFriend(friendId);
    _loadFriends();
  }

  Future<void> _findOrMakeChat(username, friendId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _chatService.findOrMakeChat(friendId);
      String chatPartnerName = username['username'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatMessagesScreen(
            chatId: response[0]['id'], // Zorg dat je het chatId doorgeeft
            chatPartnerName: chatPartnerName, // Zorg dat je de naam doorgeeft
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C1033), Color(0xFF9AC4F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'Vrienden',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 5,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: BackgroundWrapper(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vriendverzoeken
                FriendRequestsWidget(
                  friendRequests: _friendRequests,
                  isLoading: _isLoading,
                  onAccept: _acceptFriendRequest,
                  onDecline: _declineFriendRequest,
                ),
                const SizedBox(height: 20),
                // Vriendenlijst
                FriendsListWidget(
                  friends: _friends,
                  isLoading: _isLoading,
                  onChat: _findOrMakeChat,
                  onDelete: _deleteFriend,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFriendScreen()),
          );
        },
        backgroundColor: Color(0xFF0C1033),
        tooltip: 'Voeg Vriend Toe',
        child: const Icon(
          Icons.person_add,
          color: Colors.white,
          ),
      ),
    );
  }
}
