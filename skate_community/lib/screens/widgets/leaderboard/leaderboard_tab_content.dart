import 'package:flutter/material.dart';
import 'podium_widget.dart';
import 'leaderboard_card.dart';

class LeaderboardTabContent extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;
  final ScrollController scrollController;
  final bool isLoading;

  const LeaderboardTabContent({
    super.key,
    required this.leaderboard,
    required this.scrollController,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        children: [
          PodiumWidget(leaderboard: leaderboard),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              return LeaderboardCard(
                entry: leaderboard[index],
                index: index,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
