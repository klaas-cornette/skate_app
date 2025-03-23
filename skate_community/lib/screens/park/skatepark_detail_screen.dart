// lib/screens/skatepark/skatepark_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:skate_community/screens/sessions/session_screen.dart';
import 'package:skate_community/screens/widgets/main/background_wrapper.dart';
import 'package:skate_community/screens/widgets/detail/detail_list_widget.dart';
import 'package:skate_community/screens/widgets/detail/foto_section_widget.dart';
import 'package:skate_community/screens/widgets/session/session_list_widget.dart';
import 'package:skate_community/services/skatepark_service.dart';
import 'package:skate_community/services/sesion_service.dart';
import 'package:skate_community/services/rating_service.dart';
import 'package:skate_community/screens/widgets/detail/rating_display_widget.dart';
import 'package:skate_community/screens/widgets/detail/rating_input_overlay_widget.dart';
import 'package:skate_community/middleware/middleware.dart';
import 'package:skate_community/screens/widgets/main/footer_widget.dart';

class SkateparkDetailScreen extends StatefulWidget {
  final String skateparkId;

  const SkateparkDetailScreen({super.key, required this.skateparkId});

  @override
  _SkateparkDetailScreenState createState() => _SkateparkDetailScreenState();
}

class _SkateparkDetailScreenState extends State<SkateparkDetailScreen> {
  Map<String, dynamic>? skatepark;
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;
  String? error;

  final SesionService _sesionService = SesionService();
  final RatingService _ratingService = RatingService();

  double obstacles = 0.0;
  double maintenance = 0.0;
  double weather = 0.0;
  double community = 0.0;
  int ratingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSkateparkDetailsAndSessions();
  }

  Future<void> _fetchSkateparkDetailsAndSessions() async {
    setState(() => isLoading = true);

    try {
      final skateparkService = SkateparkService();
      final data = await skateparkService.fetchSkateparkById(widget.skateparkId);

      final sessionData = await _sesionService.getFriendSessions();
      final skateparkSessionFriendlist = sessionData.where((s) => s['skatepark_id'] == widget.skateparkId).toList();

      final ratingData = await _ratingService.getRatingsForSkatepark(widget.skateparkId);
      print(ratingData);

      setState(() {
        skatepark = data.cast<String, dynamic>();
        sessions = skateparkSessionFriendlist;
        obstacles = (ratingData['obstacles'] as double);
        maintenance = (ratingData['maintenance'] as double);
        weather = (ratingData['weather'] as double);
        community = (ratingData['community'] as double);
        ratingCount = (ratingData['count'] as int);

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _showRatingOverlay() {
    showDialog(
      context: context,
      builder: (context) => RatingInputOverlay(
        onSubmit: (obs, maint, weath, comm) async {
          setState(() => isLoading = true);
          try {
            await _ratingService.saveRating(
              skateparkId: widget.skateparkId,
              obstacles: obs,
              maintenance: maint,
              weather: weath,
              community: comm,
            );
            await _fetchSkateparkDetailsAndSessions();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rating opgeslagen!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fout bij rating opslaan: $e')),
            );
          } finally {
            setState(() => isLoading = false);
          }
        },
      ),
    );
  }

  Future<void> _joinSession(String sessionId) async {
    setState(() => isLoading = true);
    try {
      final sesion = await _sesionService.getSessionById(sessionId);
      final startTime = sesion['start_time'];
      final endTime = sesion['end_time'];
      final selectedSkatepark = sesion['skatepark_id'];

      // Nieuwe sessie aanmaken op basis van deze data
      await _sesionService.createSession(startTime, endTime, selectedSkatepark);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessie succesvol gejoined')),
      );

      // Lijst verversen
      await _fetchSkateparkDetailsAndSessions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij joinen: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthMiddleware(
        child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF0C1033),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              skatepark != null ? skatepark!['name'] : 'Skatepark Details',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: BackgroundWrapper(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (error != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Fout bij het laden van details:\n$error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Foto
                        PhotoSection(
                          imageUrl: skatepark?['imageUrl'],
                        ),
                        DetailList(skatepark: skatepark),
                        Container(
                          decoration: const BoxDecoration(color: Color(0xFF0C1033)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: const Text(
                            'Sessies',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SessionList(
                          sessions: sessions,
                          onJoin: _joinSession,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SessionScreen(skateparkId: widget.skateparkId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 8,
                                shadowColor: Colors.black45,
                                backgroundColor: const Color(0xFF0C1033),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Sessie'),
                                  SizedBox(width: 8),
                                  Image(
                                    image: AssetImage('assets/images/icon/add_sessie.png'),
                                    height: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: const Text(
                            'Rating',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        RatingDisplayWidget(
                          obstacles: obstacles,
                          maintenance: maintenance,
                          weather: weather,
                          community: community,
                          ratingCount: ratingCount,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: _showRatingOverlay,
                              style: ElevatedButton.styleFrom(
                                elevation: 8,
                                shadowColor: Colors.black45,
                                backgroundColor: const Color(0xFF0C1033),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.star, color: Colors.white, size: 24),
                                  SizedBox(width: 8),
                                  Text('Rating Geven'),
                                  SizedBox(width: 8),
                                  Icon(Icons.star, color: Colors.white, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const FooterWidget(currentIndex: 999),
    ));
  }
}
