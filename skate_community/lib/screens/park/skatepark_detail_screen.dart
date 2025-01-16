// lib/screens/skatepark_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:skate_community/services/skatepark_service.dart'; // Adjust the path as necessary

class SkateparkDetailScreen extends StatefulWidget {
  final String skateparkId;

  const SkateparkDetailScreen({super.key, required this.skateparkId});

  @override
  _SkateparkDetailScreenState createState() => _SkateparkDetailScreenState();
}

class _SkateparkDetailScreenState extends State<SkateparkDetailScreen> {
  Map<String, dynamic>? skatepark;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchSkateparkDetail();
  }

  Future<void> _fetchSkateparkDetail() async {
    try {
      // Probeer het skatepark op te halen
      final SkateparkService skateparkService = SkateparkService();
      final Map data = await skateparkService.fetchSkateparkById(widget.skateparkId);

      setState(() {
        skatepark = data.cast<String, dynamic>();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching skatepark details: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Naam van het skatepark
            Text(
              skatepark!['name'],
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            SizedBox(height: 10),
            // Locatie
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    skatepark!['locationName'],
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            Divider(height: 30, thickness: 1.5),
            // Binnen/Buiten
            Row(
              children: [
                Icon(Icons.toggle_on, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Buiten: ${skatepark!['indoor'] ? 'Nee' : 'Ja'}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            // WC aanwezig
            Row(
              children: [
                Icon(Icons.wc, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'WC: ${skatepark!['hasWc'] ? 'Ja' : 'Nee'}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Verlichting
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow[700]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verlichting: ${skatepark!['lightedUntil']}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Grootte
            Row(
              children: [
                Icon(Icons.aspect_ratio, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Grootte: ${skatepark!['size']}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Placeholder voor extra details (zoals geplande sessies)
            // Je kunt hier extra widgets toevoegen zoals knoppen of foto's
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://shop.thrashermagazine.com/cdn/shop/files/TH0324-Cover_cp14-1200.jpg?v=1704485795',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[300],
              child:
                  Center(child: Icon(Icons.error, color: Colors.red, size: 40)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(skatepark != null ? skatepark!['name'] : 'Skatepark Details'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Fout bij het laden van details:\n$error',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      _buildPhotoSection(),
                      _buildDetailCard(),
                      // Voeg hier extra widgets toe zoals reviews, geplande sessies, etc.
                      // Bijvoorbeeld een sectie voor gebruikersreviews:
                    
                      SizedBox(height: 10),
                      // Placeholder voor reviews
                     
                    ],
                  ),
                ),
    );
  }
}
