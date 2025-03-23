import 'package:flutter/material.dart';

class PodiumWidget extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;

  const PodiumWidget({super.key, required this.leaderboard});

  double _getStepHeightForIndex(int index) {
    const double firstStepHeight = 170.0;
    const double secondStepHeight = 140.0;
    const double thirdStepHeight = 110.0;
    switch (index) {
      case 0:
        return secondStepHeight;
      case 1:
        return firstStepHeight;
      case 2:
        return thirdStepHeight;
      default:
        return secondStepHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (leaderboard.length < 3) return const SizedBox.shrink();
    final topThree = leaderboard.take(3).toList();
    final podiumOrder = [topThree[1], topThree[0], topThree[2]];
    const double stepWidth = 100.0;
    const double avatarRadius = 50.0;

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (index) {
              final double stepHeight = _getStepHeightForIndex(index);
              String rankLabel;
              if (index == 1) {
                rankLabel = '#1';
              } else if (index == 0) {
                rankLabel = '#2';
              } else {
                rankLabel = '#3';
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: stepWidth,
                    height: stepHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Text(
                    rankLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            }),
          ),
          // Voorgrond: avatars en spelersnamen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (index) {
              final entry = podiumOrder[index];
              final double stepHeight = _getStepHeightForIndex(index);
              final double avatarOffset = -(stepHeight - avatarRadius - 30);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(0, avatarOffset),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: entry['avatar_url'] != null
                          ? NetworkImage(entry['avatar_url'])
                          : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ((entry['username'] ?? 'Onbekend').toString().length > 10)
                        ? '${(entry['username'] ?? 'Onbekend').toString().substring(0, 8)}...'
                        : (entry['username'] ?? 'Onbekend').toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
