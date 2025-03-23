import 'package:flutter/material.dart';
import 'package:skate_community/screens/friends/add_friends_screen.dart';
import 'package:skate_community/screens/widgets/main/background_wrapper.dart';
import 'package:skate_community/screens/widgets/friend/friend_list_widget.dart';
import 'package:skate_community/screens/widgets/friend/friend_requests_widget.dart';
import 'package:skate_community/services/friend_service.dart';
import 'package:skate_community/screens/widgets/main/footer_widget.dart';
import 'package:skate_community/middleware/middleware.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final FriendsService _friendsService = FriendsService();
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
      final friends = await _friendsService.getFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading friends: $e');
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

  @override
  Widget build(BuildContext context) {
    return AuthMiddleware(
        child: Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF0C1033),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
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
                FriendRequestsWidget(
                  friendRequests: _friendRequests,
                  isLoading: _isLoading,
                  onAccept: _acceptFriendRequest,
                  onDecline: _declineFriendRequest,
                ),
                FriendsListWidget(
                  friends: _friends,
                  isLoading: _isLoading,
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
      bottomNavigationBar: FooterWidget(currentIndex: 1),
    ));
  }
}
