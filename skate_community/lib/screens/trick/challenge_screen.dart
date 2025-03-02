import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:skate_community/services/trick_service.dart';
import 'package:skate_community/screens/widgets/footer_widget.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final TrickService trickService = TrickService();
  List<Map<String, dynamic>> dailyChallenges = [];
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final response = await trickService.getDailyChallenges();
      if (mounted) {
        setState(() {
          dailyChallenges = response;
        });
      }
    } catch (e) {
      print("Fout bij het laden van uitdagingen: $e");
    }
    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  Future<void> toggleChallenge(
      String challengeId, String trickName, int points) async {
    final challenge = await trickService.getActiveChallengById(challengeId);

    if (challenge['completed']) {
      await removeChallenge(challengeId);
    } else {
      await addChallenge(challengeId, trickName, points);
    }
    await loadChallenges();
    setState(() {
    _isLoading = false; // Stop loading
  });
  }

  Future<void> addChallenge(
      String challengeId, String trickName, int points) async {
    try {
      await trickService.addUserChallenge(challengeId, trickName, points);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge "$trickName" toegevoegd!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Fout bij het toevoegen van challenge: $e");
    }
  }

  Future<void> removeChallenge(String challengeId) async {
    try {
      await trickService.removeUserChallenge(challengeId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge verwijderd!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Fout bij het verwijderen van challenge: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C1033), Color(0xFF9AC4F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text(
              'Dagelijkse Challenges',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dailyChallenges.length,
              itemBuilder: (context, index) {
                final trick = dailyChallenges[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      trick['name'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Punten: ${trick['points']}"),
                    trailing: Icon(
                      Icons.check_circle_outline,
                      color: trick["completed"] ? Colors.green : Colors.red,
                    ),
                    onTap: () {
                      int points = trick['points'].toInt();
                      toggleChallenge(
                          trick['trick_id'].toString(), trick['name'], points);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: FooterWidget(currentIndex: 4),
    );
  }
}
