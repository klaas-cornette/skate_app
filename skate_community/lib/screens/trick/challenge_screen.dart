import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    loadChallenges();
  }

  Future<void> loadChallenges() async {
  try {
    final response = await trickService.getDailyChallenges();
    if (mounted) { // Check of widget nog bestaat voordat je setState aanroept
      setState(() {
        dailyChallenges = response;
      });
    }
  } catch (e) {
    print("❌ Fout bij het laden van uitdagingen: $e");
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
      body: dailyChallenges.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dailyChallenges.length,
              itemBuilder: (context, index) {
                final trick = dailyChallenges[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(trick['name'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text("Moeilijkheid: ${trick['difficulty']}"),
                    trailing:
                        Icon(Icons.check_circle_outline, color: Colors.green),
                  ),
                );
              },
            ),
      bottomNavigationBar: FooterWidget(currentIndex: 4),
    );
  }
}
