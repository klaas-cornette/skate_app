import 'package:flutter/material.dart';
import 'package:skate_community/screens/widgets/footer_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          // Achtergrondafbeelding
          Positioned.fill(
            child: Image.asset(
              'assets/images/skate-back.jpg', // Zorg ervoor dat dit pad klopt
              fit: BoxFit
                  .cover, // Zorgt dat de afbeelding de volledige achtergrond vult
            ),
          ),
          // Inhoud van de pagina
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Settings Page',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .black, // Zorg dat tekst zichtbaar is op de achtergrond
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Hier kun je instellingen aanpassen',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FooterWidget(currentIndex: 5),
    );
  }
}
