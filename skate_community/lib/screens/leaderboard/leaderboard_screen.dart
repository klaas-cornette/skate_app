import 'package:flutter/material.dart';
import 'package:skate_community/services/leaderboard_service.dart';
import 'package:skate_community/screens/widgets/background_wrapper.dart';
import 'package:skate_community/screens/widgets/footer_widget.dart';
import 'package:skate_community/screens/widgets/leaderboard_tab_content.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final LeaderboardService _leaderboardService = LeaderboardService();
  late TabController _tabController;
  List<Map<String, dynamic>> _globalLeaderboard = [];
  List<Map<String, dynamic>> _friendsLeaderboard = [];
  bool _isLoading = false;
  String? _error;
  final ScrollController _globalScrollController = ScrollController();
  final ScrollController _friendsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLeaderboards();
  }

  Future<void> _fetchLeaderboards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Haal zowel het globale als het vrienden leaderboard op
      final globalData = await _leaderboardService.getLeaderboard();
      final friendsData = await _leaderboardService.getFriendsLeaderboard();
      setState(() {
        _globalLeaderboard = (globalData['leaderboard'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _friendsLeaderboard = (friendsData['leaderboard'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $_error')));
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
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C1033), Color(0xFF9AC4F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'Leaderboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white,
              tabs: const [
                Tab(text: 'Globaal'),
                Tab(text: 'Vrienden'),
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
            LeaderboardTabContent(
              leaderboard: _globalLeaderboard,
              scrollController: _globalScrollController,
              isLoading: _isLoading,
            ),
            LeaderboardTabContent(
              leaderboard: _friendsLeaderboard,
              scrollController: _friendsScrollController,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FooterWidget(currentIndex: 1),
    );
  }
}
