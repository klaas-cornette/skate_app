import 'package:flutter/material.dart';

class RatingDisplayWidget extends StatelessWidget {
  final double obstacles;
  final double maintenance;
  final double weather;
  final double community;
  final int ratingCount;

  const RatingDisplayWidget({
    super.key,
    required this.obstacles,
    required this.maintenance,
    required this.weather,
    required this.community,
    required this.ratingCount,
  });

  double get overall => (obstacles + maintenance + weather + community) / 4.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Skatepark Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C1033),
                  ),
                ),
                Text(
                  '$ratingCount reviews',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildCategoryRow('Obstakels', obstacles),
            _buildCategoryRow('Onderhoud', maintenance),
            _buildCategoryRow('Weer Kwaliteit', weather),
            _buildCategoryRow('Community', community),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Algemeen: ',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const Icon(Icons.star, size: 20, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  overall.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1033),
              ),
            ),
          ),
          const Icon(Icons.star, size: 20, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
