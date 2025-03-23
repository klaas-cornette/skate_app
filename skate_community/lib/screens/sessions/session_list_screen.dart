import 'package:flutter/material.dart';
import 'package:skate_community/screens/sessions/session_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skate_community/services/sesion_service.dart';
import 'package:skate_community/screens/widgets/main/background_wrapper.dart';
import 'package:skate_community/screens/widgets/main/footer_widget.dart';
import 'package:skate_community/screens/widgets/session/my_session_list_widget.dart';
import 'package:skate_community/screens/widgets/session/friend_session_list_widget.dart';
import 'package:skate_community/middleware/middleware.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  _SessionListScreenState createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> with SingleTickerProviderStateMixin {
  final SesionService _sesionService = SesionService();
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = false;
  String? _error;
  late TabController _tabController;

  List<Map<String, dynamic>> _mySessions = [];
  List<Map<String, dynamic>> _friendSessions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSessions();
  }

  Future<void> _navigateToSessions() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SessionScreen()),
    );
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final user = _client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'Niet ingelogd';
      });
      return;
    }

    try {
      final mySessions = await _sesionService.getUserSession();
      final friendSessions = await _sesionService.getFriendSessions();

      setState(() {
        _mySessions = mySessions;
        _friendSessions = friendSessions;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTabContent(bool isMySessions) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final sessions = isMySessions ? _mySessions : _friendSessions;
    if (sessions.isEmpty) {
      return const Center(child: Text('Geen sessies gevonden.'));
    }

    return isMySessions
        ? MySessionListWidget(sessions: sessions)
        : FriendSessionListWidget(
            sessions: sessions,
            onJoinSession: (sessionId) async {
              setState(() => _isLoading = true);
              try {
                final sesion = await _sesionService.getSessionById(sessionId);
                final startTime = sesion['start_time'];
                final endTime = sesion['end_time'];
                final selectedSkatepark = sesion['skatepark_id'];
                await _sesionService.createSession(startTime, endTime, selectedSkatepark);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sessie succesvol gejoined')),
                );
                await _loadSessions();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fout bij joinen: $e')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return AuthMiddleware(
        child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF0C1033),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Sessies',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _navigateToSessions,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white,
              tabs: const [
                Tab(text: 'Mijn Sessies'),
                Tab(text: 'Vrienden Sessies'),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: BackgroundWrapper(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(true),
            _buildTabContent(false),
          ],
        ),
      ),
      bottomNavigationBar: const FooterWidget(currentIndex: 3),
    ));
  }
}
