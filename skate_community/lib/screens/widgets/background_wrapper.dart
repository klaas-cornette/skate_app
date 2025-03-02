import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Achtergrondafbeelding met volledige lengte en breedte
            SizedBox(
              height: constraints.maxHeight, // Gebruik maximale hoogte
              width: constraints.maxWidth,   // Gebruik maximale breedte
              child: Opacity(
                opacity: 0.25, // Transparantie van de achtergrondafbeelding
                child: Image.asset(
                  'assets/images/skate-back.jpg', 
                  repeat: ImageRepeat.repeatY, // Herhaal afbeelding verticaal
                ),
              ),
            ),
            // Voorgrondinhoud
            child,
          ],
        );
      },
    );
  }
}
