import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailList extends StatelessWidget {
  final Map<String, dynamic>? skatepark;

  const DetailList({super.key, required this.skatepark});

  void _openMaps(BuildContext context, String latitude, String longitude) async {
  String url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not launch maps')),
    );
  }
}

  void _showObstaclesOverlay(BuildContext context, List obstacles) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        // Achtergrond en vormgeving
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        
        // Titel
        title: Text(
          'Obstakels',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        
        // Inhoud
        content: obstacles.isNotEmpty
            ? SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: obstacles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      // Klein icoontje als bullet
                      leading: const Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.grey,
                      ),
                      title: Text(
                        obstacles[index].toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      dense: true, // compactere weergave
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              )
            : const Text('Geen obstakels beschikbaar.'),
        
        // Actieknoppen
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor, 
            ),
            child: const Text('Sluiten'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final obstacles = skatepark!['obstacles'] ?? [];

    return Container(
      color: Colors.grey[200], // Achtergrondkleur
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          children: [
            // Adres
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: Text(
                skatepark!['address'] ?? 'Onbekend adres',
                style: const TextStyle(fontSize: 18),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openMaps(context, skatepark!['latitude'].toString(), skatepark!['longitude'].toString()),
            ),
            const Divider(),
            // Opstakels
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.skateboarding_sharp, color: Colors.brown),
              title: const Text(
                'Obstakels',
                style: TextStyle(fontSize: 18),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showObstaclesOverlay(context, obstacles),
            ),
            const Divider(),
            // Verlichting (alleen als niet indoor)
            if (!skatepark!['indoor']) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lightbulb, color: Colors.yellow),
                title: Text(
                  skatepark!['lightedUntil'],
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const Divider(),
            ],
            // Grootte
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.straighten, color: Colors.green),
              title: Text(
                '${skatepark!['size']} oppervlakte',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const Divider(),
            // WC
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.wc, color: Colors.purple),
              title: Text(
                skatepark!['hasWc'] ? 'Ja' : 'Nee',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const Divider(),
            // Buiten
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.toggle_on, color: Colors.blue),
              title: Text(
                skatepark!['indoor'] ? 'Binnen' : 'Buiten',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
