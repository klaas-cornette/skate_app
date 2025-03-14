import 'package:flutter/material.dart';
import 'package:skate_community/screens/park/skatepark_detail_screen.dart';
import 'package:skate_community/services/sesion_service.dart';

class SkateparkCardsWidget extends StatefulWidget {
  final List<dynamic> skateparks;

  const SkateparkCardsWidget({super.key, required this.skateparks});

  @override
  _SkateparkCardsWidgetState createState() => _SkateparkCardsWidgetState();
}

class _SkateparkCardsWidgetState extends State<SkateparkCardsWidget> {
  final SesionService _sesionService = SesionService();
  Map<dynamic, int> _sessionCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSessionCounts();
  }

  Future<void> _initializeSessionCounts() async {
    try {
      final friendSessions = await _sesionService.getFriendSessions();
      Map<dynamic, int> counts = {};
      for (var park in widget.skateparks) {
        final id = park['id'];
        final count = friendSessions.where((session) => session['skatepark_id'] == id).toList().length;
        counts[id] = count;
      }
      setState(() {
        _sessionCounts = counts;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching session counts: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: widget.skateparks.length,
              itemBuilder: (context, index) {
                final park = widget.skateparks[index];
                final sessionCount = _sessionCounts[park['id']] ?? 0;
                final stars = park['stars'] ?? 0;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SkateparkDetailScreen(
                          skateparkId: park['id'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            child: park['imageUrl'] != null
                                ? Image.network(
                                    park['imageUrl'],
                                    width: 100,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 100,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                          ),
                          // Resterende ruimte met de parknaam bovenaan en onderaan de rating en sessies
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Parknaam bovenaan
                                  Text(
                                    park['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  // Onderste rij met rating links en sessies rechts
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            stars.toString(),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            sessionCount.toString(),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.calendar_month_outlined,
                                            size: 16,
                                            color: Color(0xFF0C1033),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
