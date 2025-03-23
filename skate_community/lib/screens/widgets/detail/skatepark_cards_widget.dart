import 'package:flutter/material.dart';
import 'package:skate_community/screens/park/skatepark_detail_screen.dart';
import 'package:skate_community/services/sesion_service.dart';
import 'package:skate_community/services/rating_service.dart';

class SkateparkCardsWidget extends StatefulWidget {
  final List<dynamic> skateparks;

  const SkateparkCardsWidget({super.key, required this.skateparks});

  @override
  _SkateparkCardsWidgetState createState() => _SkateparkCardsWidgetState();
}

class _SkateparkCardsWidgetState extends State<SkateparkCardsWidget> {
  final SesionService _sesionService = SesionService();
  final RatingService _ratingService = RatingService();
  Map<dynamic, int> _sessionCounts = {};
  Map<dynamic, double> _ratingOverAll = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCardInfo();
  }

  Future<void> _initializeCardInfo() async {
    try {
      final friendSessions = await _sesionService.getFriendSessions();
      Map<dynamic, double> ratings = {};
      Map<dynamic, int> counts = {};

      for (var park in widget.skateparks) {
        final id = park['id'];

        final ratingData = await _ratingService.getRatingsForSkatepark(id);

        final obstacles = ratingData['obstacles'] as double;
        final maintenance = ratingData['maintenance'] as double;
        final weather = ratingData['weather'] as double;
        final community = ratingData['community'] as double;

        final overall = double.parse(((obstacles + maintenance + weather + community) / 4.0).toStringAsFixed(1));
        ratings[id] = overall;

        final count = friendSessions.where((session) => session['skatepark_id'] == id).toList().length;
        counts[id] = count;
      }
      setState(() {
        _sessionCounts = counts;
        _ratingOverAll = ratings;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching: $error');
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
                final ratingOverAll = _ratingOverAll[park['id']] ?? 0;
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
                                            ratingOverAll.toString(),
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
