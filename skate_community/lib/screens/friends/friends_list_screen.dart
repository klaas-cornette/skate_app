// lib/screens/friends_list_screen.dart

import 'package:flutter/material.dart';
import 'package:skate_community/screens/chat/chat_messages_screen.dart';
import 'package:skate_community/screens/friends/add_friends_screen.dart';
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
    _loadFriends();
  }

  // Laadt inkomende vriendverzoeken
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

  /// Laadt de vriendenlijst
  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final friends = await _friendsService.getFriends();
      setState(() {
        _friends = friends;
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
      _loadFriends();
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

  // /// Weigert een vriendverzoek
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

  Future<void> _deleteFriend(String friendId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _friendsService.deleteFriend(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vriend verwijderd.')),
      );
      _loadFriends();
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

  Future<void> _findOrMakeChat(username, friendId) async {
    setState(() {
      _isLoading = true;
      _error = null;
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

  /// Filtert de vriendenlijst op basis van de zoekterm

  Future<void> _filterFriends(String query) async {
    try {
      final friends = await _friendsService.getFriends();
      if (query.isEmpty) {
        setState(() {
          _friends.clear();
          _friends = friends;
        });
        return;
      }
      final filteredFriends = friends.where((friend) {
        final user = friend['users'];
        return user['username'].toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        _friends.clear();
        _friends = filteredFriends;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_error')),
      );
    }
  }

  /// Bouwt de inkomende vriendverzoeken sectie
  Widget _buildFriendRequests() {
    if (_friendRequests.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inkomende Vriendverzoeken',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              margin: EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(sender['username'] ?? sender['email']),
                subtitle: Text(sender['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: _isLoading
                          ? null
                          : () =>
                              _acceptFriendRequest(request['id'], sender['id']),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: _isLoading
                          ? null
                          : () => _declineFriendRequest(request['id']),
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

  /// Bouwt de vriendenlijst sectie
  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return Text('Je hebt nog geen vrienden.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _friends.length,
          itemBuilder: (context, index) {
            final friend = _friends[index];
            final user = friend['users'];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(user['username'] ?? user['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.message, color: Colors.blue),
                      onPressed: () {
                        _findOrMakeChat(user, user['id']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Vriend verwijderen"),
                                  content: Text(
                                      "Weet je zeker dat je deze vriend wilt verwijderen?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text("Annuleren"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text("Verwijderen"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                _deleteFriend(friend['friend_id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Vriend verwijderd.')),
                                );
                              }
                            },
                    ),
                  ],
                ),

                // onTap: () {
                //   // Optioneel: navigeren naar een profielpagina
                //   // Navigator.push(
                //   //   context,
                //   //   MaterialPageRoute(
                //   //     builder: (context) => UserProfileScreen(userId: user['id']),
                //   //   ),
                //   // );
                // },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Zoek vrienden',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: _filterFriends,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vrienden'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zoekbalk
                    _buildSearchBar(),
                    SizedBox(height: 20),

                    // Inkomende Vriendverzoeken (alleen tonen als er verzoeken zijn)
                    if (_friendRequests.isNotEmpty) _buildFriendRequests(),
                    // Vriendenlijst
                    _buildFriendsList(),
                  ],
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
        backgroundColor: Colors.teal, // Pas de kleur aan indien gewenst
        tooltip: 'Voeg Vriend Toe',
        child: Icon(Icons.person_add),
      ),
    );
  }
}
