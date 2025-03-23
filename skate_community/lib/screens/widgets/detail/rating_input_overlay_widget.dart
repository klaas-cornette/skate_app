import 'package:flutter/material.dart';

class RatingInputOverlay extends StatefulWidget {
  final Function(double obstacles, double maintenance, double weather, double community) onSubmit;

  const RatingInputOverlay({
    super.key,
    required this.onSubmit,
  });

  @override
  _RatingInputOverlayState createState() => _RatingInputOverlayState();
}

class _RatingInputOverlayState extends State<RatingInputOverlay> {
  double _obstacles = 3;
  double _maintenance = 3;
  double _weather = 3;
  double _community = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Wat minder padding rondom, zodat er meer ruimte overblijft voor de content
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      backgroundColor: Colors.transparent, // Zo kan de gradient-container de achtergrond vormen
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Container(
        // Breder dialoogvenster
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Past de hoogte aan de inhoud aan
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Geef je Rating',
                style: TextStyle(
                  fontSize: 24, // Groter gemaakt
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C1033),
                ),
              ),
              const SizedBox(height: 16),

              _buildRatingColumn(
                label: 'Obstacles',
                value: _obstacles,
                onChanged: (val) => setState(() => _obstacles = val),
              ),
              const SizedBox(height: 16),

              _buildRatingColumn(
                label: 'Maintenance',
                value: _maintenance,
                onChanged: (val) => setState(() => _maintenance = val),
              ),
              const SizedBox(height: 16),

              _buildRatingColumn(
                label: 'Weather',
                value: _weather,
                onChanged: (val) => setState(() => _weather = val),
              ),
              const SizedBox(height: 16),

              _buildRatingColumn(
                label: 'Community',
                value: _community,
                onChanged: (val) => setState(() => _community = val),
              ),
              const SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSubmit(_obstacles, _maintenance, _weather, _community);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C1033),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Opslaan'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingColumn({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // Labels iets groter
          ),
        ),
        const SizedBox(height: 8),
        _buildStarSelector(value, onChanged),
      ],
    );
  }

  Widget _buildStarSelector(double rating, ValueChanged<double> onChanged) {
    final currentInt = rating.round();
    List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      final isSelected = i <= currentInt;
      stars.add(
        GestureDetector(
          onTap: () => onChanged(i.toDouble()),
          child: Icon(
            isSelected ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 24, // Sterren groter
          ),
        ),
      );
    }

    return Row(children: stars);
  }
}
