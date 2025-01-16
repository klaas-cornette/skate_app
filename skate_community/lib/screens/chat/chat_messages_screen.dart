import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/services/chat_service.dart';

class ChatMessagesScreen extends StatefulWidget {
  final String chatId;
  final String chatPartnerName;

  const ChatMessagesScreen({
    super.key,
    required this.chatId,
    required this.chatPartnerName,
  });

  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  String? _error;
  final List<Map<String, dynamic>> _messages = [];

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

  void subscribeToMessages() {
    setLoading(true);
    supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', widget.chatId)
        .order('created_at', ascending: false)
        .listen((data) {
          setState(() {
            _messages.clear();
            _messages.addAll(data.map((e) => e));
          });
          setLoading(false);
        });
  }

  @override
  void initState() {
    super.initState();
    subscribeToMessages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_messages.isEmpty) {
      return const Text('Geen berichten beschikbaar.');
    }

    final currentUserId = supabase.auth.currentUser?.id;

    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final senderId = message['sender_id'];
        final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.parse(message['created_at']));
        final isMyMessage = senderId == currentUserId;

        return Align(
          alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMyMessage ? Colors.blueAccent : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: isMyMessage ? Radius.circular(10) : Radius.zero,
                bottomRight: isMyMessage ? Radius.zero : Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  message['content'] ?? '',
                  style: TextStyle(
                    color: isMyMessage ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMyMessage ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    TextEditingController messageController = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Typ een bericht...',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                final content = messageController.text.trim();
                if (content.isNotEmpty) {
                  _chatService.sendMessage(
                      widget.chatId, supabase.auth.currentUser!.id, content);
                  messageController.clear();
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat met ${widget.chatPartnerName}'),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
