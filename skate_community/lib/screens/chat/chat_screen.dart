import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skate_community/screens/chat/chat_messages_screen.dart';
import 'package:skate_community/screens/friends/friends_list_screen.dart';
import 'package:skate_community/screens/widgets/background_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _chats = [];

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void setError(String? error) {
    setState(() {
      _error = error;
    });
  }

  Future<void> fetchChats() async {
    setLoading(true);
    setError(null);
    final user = supabase.auth.currentUser;
    if (user == null) {
      setError('User not logged in');
      setLoading(false);
      return;
    }

    try {
      final chats = await _chatService.getChatsFromUser(user.id);
      setState(() {
        _chats = chats;
      });
    } catch (e) {
      setError('Error fetching chats: $e');
    } finally {
      setLoading(false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Widget _buildChatList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_chats.isEmpty) {
      return const Text('Je hebt nog geen chats.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _chats.length,
          itemBuilder: (context, index) {
            final chat = _chats[index];
            final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
                .format(DateTime.parse(chat['created_at']));
            final chatPartnerUsername =
                chat['user1_id'] == supabase.auth.currentUser!.id
                    ? chat['user2']['username']
                    : chat['user1']['username'];

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.chat, color: Colors.white),
                ),
                title: Text('Chat met: $chatPartnerUsername'),
                subtitle: Text(formattedDate),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatMessagesScreen(
                        chatId: chat['id'],
                        chatPartnerName:
                            chatPartnerUsername, // Zorg dat je de naam doorgeeft
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Stel de hoogte in
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
              'Chats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor:
                Colors.transparent, // Transparant om de gradient te tonen
            elevation: 0, // Geen schaduw
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: Colors.white), // Witte icoon
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FriendsListScreen()),
                  );
                },
              ),
            ],
            iconTheme: IconThemeData(color: Colors.white), // Witte icoonkleur
          ),
        ),
      ),
      body: BackgroundWrapper(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildChatList(),
        ),
      ),
    );
  }
}
