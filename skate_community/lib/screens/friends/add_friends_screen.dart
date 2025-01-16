// lib/screens/add_friend_screen.dart

import 'package:flutter/material.dart';
import 'package:skate_community/services/friend_service.dart';
import 'package:skate_community/services/user_service.dart';

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

  /// Laadt inkomende vriendverzoeken
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

  /// Zoekt gebruikers op basis van de zoekterm
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

    print(friendIds);

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

  /// Verzendt een vriendverzoek naar een gebruiker
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

  /// Accepteert een vriendverzoek
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

  /// Weigert een vriendverzoek
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

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'Geen resultaten gevonden.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade200,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                user['username'] ?? user['email'],
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(user['email']),
              trailing: ElevatedButton(
                onPressed: _isLoading ? null : () => _sendFriendRequest(user['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Toevoegen'),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildFriendRequests() {
    if (_friendRequests.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inkomende Vriendverzoeken',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _friendRequests.length,
          itemBuilder: (context, index) {
            final request = _friendRequests[index];
            final sender = request['sender'];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  sender['username'] ?? sender['email'],
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(sender['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: _isLoading
                          ? null
                          : () => _acceptFriendRequest(request['id'], sender['id']),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: _isLoading ? null : () => _declineFriendRequest(request['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voeg Vrienden Toe'),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zoek nieuwe vrienden',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Voer een gebruikersnaam in',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.search, color: Colors.teal),
                            ),
                            onSubmitted: (_) => _searchUsers(),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _searchUsers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Zoek'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildSearchResults(),
                    SizedBox(height: 30),
                    if (_friendRequests.isNotEmpty) _buildFriendRequests(),
                  ],
                ),
              ),
            ),
    );
  }
}

