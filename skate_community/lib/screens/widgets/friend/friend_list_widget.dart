import 'package:flutter/material.dart';
import 'package:skate_community/screens/widgets/main/search_bar.dart' as custom;
import 'package:skate_community/services/friend_service.dart';

class FriendsListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> friends;
  final bool isLoading;
  final Function(String friendId) onDelete;
  

  const FriendsListWidget({
    super.key,
    required this.friends,
    required this.isLoading,
    required this.onDelete,
  });

  @override
  _FriendsListWidgetState createState() => _FriendsListWidgetState();
}

class _FriendsListWidgetState extends State<FriendsListWidget> {
  List<Map<String, dynamic>> _filteredFriends = [];

  final FriendsService _friendsService = FriendsService();

  Future<void> _loadfriends() async {
    final friends = await _friendsService.getFriends();
    setState(() {
      _filteredFriends = friends;
    });
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFriends = widget.friends;
      });
      return;
    }
    final filteredFriends = widget.friends.where((friend) {
      final user = friend['users'];
      return user['username'].toLowerCase().contains(query.toLowerCase()) ||
          user['email'].toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredFriends = filteredFriends;
    });
  }

  void _onchange(String query) {
    _handleSearch(query);
  }

  Future<void> _confirmDelete(BuildContext context, String friendId) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Vriend verwijderen"),
          content: const Text("Weet je zeker dat je deze vriend wilt verwijderen?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Annuleren"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Verwijderen",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDelete(friendId);
    }
  }

  @override
  void initState() {
    super.initState();
    if(widget.isLoading){
      _loadfriends();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        custom.SearchBar(
          onSearch: _onchange,
          hintText: 'Zoek vrienden',
          onChanged: _handleSearch,
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredFriends.length,
          itemBuilder: (context, index) {
            final friend = _filteredFriends[index];
            final user = friend['users'];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(user['username'] ?? user['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              _confirmDelete(context, friend['friend_id']);
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Loader overlay
        if (widget.isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
