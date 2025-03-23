import 'package:flutter/material.dart';
import 'package:skate_community/screens/chat/chat_messages_screen.dart';
import 'package:skate_community/screens/widgets/main/background_wrapper.dart';
import 'package:skate_community/screens/widgets/chat/chatbody_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/services/chat_service.dart';
import 'package:skate_community/screens/widgets/main/footer_widget.dart';
import 'package:skate_community/services/friend_service.dart';
import 'package:skate_community/screens/widgets/main/search_bar.dart' as custom;
import 'package:skate_community/middleware/middleware.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ChatService _chatService = ChatService();
  final FriendsService _friendsService = FriendsService();

  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _filteredFriends = [];

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _error = 'User not logged in';
        _isLoading = false;
      });
      return;
    }

    try {
      final chats = await _chatService.getChatsFromUser(user.id);
      final friends = await _friendsService.getFriends();
      setState(() {
        _chats = chats;
        _friends = friends;
      });
    } catch (e) {
      setState(() => _error = 'Fout bij laden data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _findOrMakeChat(String username, String friendId) async {
    setState(() => _isLoading = true);
    try {
      final response = await _chatService.findOrMakeChat(friendId);
      final chatId = response[0]['id'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatMessagesScreen(
            chatId: chatId,
            chatPartnerName: username,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _handleSearch(String query) async {
    query = query.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredFriends = [];
      });
      return;
    }
    final users = await _friendsService.searchUsers(query);
    final filteredUsers = users.where((item) {
      return _friends.any(
        (friend) => friend['user_id'] == item['id'] || friend['friend_id'] == item['id'],
      );
    }).toList();

    setState(() {
      _filteredFriends = filteredUsers;
    });
  }

  void _onChanged(String query) {
    _handleSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return AuthMiddleware(
        child: Scaffold(
      // AppBar met gradient
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF0C1033),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Chats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),

      body: BackgroundWrapper(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Zoekbalk
              custom.SearchBar(
                hintText: 'Zoek vrienden om te chatten...',
                onSearch: _handleSearch,
                onChanged: _onChanged,
              ),
              const SizedBox(height: 12),
              // Uitgebreide widget die bepaalt wat we tonen:
              Expanded(
                child: ChatbodyWidget(
                  isLoading: _isLoading,
                  error: _error,
                  chats: _chats,
                  filteredFriends: _filteredFriends,
                  supabase: supabase,
                  onOpenChat: (chat) {
                    // Als je direct wilt openklikken in chat-lijst
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatMessagesScreen(
                          chatId: chat['id'],
                          chatPartnerName: chat['partnerName'],
                        ),
                      ),
                    );
                  },
                  onOpenFilteredFriend: (username, friendId) {
                    // Start of vind chat met friend
                    _findOrMakeChat(username, friendId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FooterWidget(currentIndex: 2),
    ));
  }
}
