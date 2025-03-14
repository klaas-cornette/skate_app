import 'package:flutter/material.dart';
import 'package:skate_community/screens/widgets/background_wrapper.dart';
import 'package:skate_community/screens/widgets/detail_list_widget.dart';
import 'package:skate_community/screens/widgets/foto_section_widget.dart';
import 'package:skate_community/screens/widgets/session_list_widget.dart';
import 'package:skate_community/services/skatepark_service.dart';
import 'package:skate_community/services/sesion_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchSkateparkDetailsAndSessions();
  }

  Future<void> _fetchSkateparkDetailsAndSessions() async {
    try {
      final SesionService sesionService = SesionService();
      final SkateparkService skateparkService = SkateparkService();
      final Map data =
          await skateparkService.fetchSkateparkById(widget.skateparkId);

      final List<Map<String, dynamic>> sessionData =
          await sesionService.getFilteredSessions(widget.skateparkId);

      setState(() {
        skatepark = data.cast<String, dynamic>();
        sessions = sessionData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C1033), Color(0xFF9AC4F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
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
            : error != null
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
                        PhotoSection(
                          imageUrl: skatepark?['imageUrl'],
                        ),
                        DetailList(skatepark: skatepark),
                        Card(
                          color: Color(0xFF9AC4F5), // Nieuwe achtergrondkleur
                          child: SizedBox(
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Geplande Sessies',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0C1033), // Tekstkleur wit
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SessionList(sessions: sessions),
                      ],
                    ),
                  ),
      ),
    );
  }
}
