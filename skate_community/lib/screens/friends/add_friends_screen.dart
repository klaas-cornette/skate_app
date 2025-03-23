import 'package:flutter/material.dart';
import 'package:skate_community/screens/widgets/friend/add_friend_request_widget.dart';
import 'package:skate_community/screens/widgets/main/background_wrapper.dart';
import 'package:skate_community/screens/widgets/friend/search_bar_widget.dart';
import 'package:skate_community/screens/widgets/friend/search_results_widget.dart';
import 'package:skate_community/services/friend_service.dart';
import 'package:skate_community/services/user_service.dart';
import 'package:skate_community/middleware/middleware.dart';
import 'package:skate_community/screens/widgets/main/footer_widget.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final UserService _userService = UserService();
  final FriendsService _friendsService = FriendsService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _friendRequests = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requests = await _friendsService.getIncomingFriendRequests();
      setState(() {
        _friendRequests = requests;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Zoek naar gebruikers op basis van de zoekterm
      final results = await _userService.searchUsers(query);

      // Haal de ID's van je vrienden op
      final currentUser = await _userService.getCurrentUser(); // Pas dit aan aan je methode voor user ID
      final currentUserId = currentUser['id'];
      final friends = await _friendsService.getFriends(); // Haal vrienden op
      final friendIds = friends.map((friend) => friend['friend_id']).toSet();

      // Filter jezelf en je vrienden uit de resultaten
      final filteredResults = results.where((user) {
        final userId = user['id'];
        return userId != currentUserId && !friendIds.contains(userId);
      }).toList();

      setState(() {
        _searchResults = filteredResults;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _friendsService.sendFriendRequest(receiverId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vriendverzoek verzonden!')),
      );
      _searchUsers(); // Refresh de zoekresultaten
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

  Future<void> _acceptFriendRequest(String requestId, String senderId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _friendsService.acceptFriendRequest(requestId, senderId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vriend toegevoegd!')),
      );
      _loadFriendRequests();
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

  Future<void> _declineFriendRequest(String requestId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _friendsService.declineFriendRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vriendverzoek afgewezen.')),
      );
      _loadFriendRequests();
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
              'Voeg vrienden toe',
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
                SearchBarWidget(
                  controller: _searchController,
                  isLoading: _isLoading,
                  onSearch: _searchUsers,
                ),
                const SizedBox(height: 20),
                SearchResultsWidget(
                  results: _searchResults,
                  isLoading: _isLoading,
                  onAddFriend: _sendFriendRequest,
                ),
                const SizedBox(height: 20),
                AddFriendRequestsWidget(
                  friendRequests: _friendRequests,
                  isLoading: _isLoading,
                  onAccept: _acceptFriendRequest,
                  onDecline: _declineFriendRequest,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FooterWidget(currentIndex: 999),
    ));
  }
}
