import 'package:flutter/material.dart';

class PhotoSection extends StatelessWidget {
  final String? imageUrl;

  const PhotoSection({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl ?? '', // Plaatsvervanger als er geen afbeelding is
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error, color: Colors.red, size: 40),
              ),
            );
          },
        ),
      ),
    );
  }
}
