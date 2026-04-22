import 'package:flutter/material.dart';

class ProgressBarCard extends StatelessWidget {
  final int learned;
  final int total;

  const ProgressBarCard({
    super.key,
    required this.learned,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total == 0 ? 0.0 : learned / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Daily Progress", style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          /// Animated Progress
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(
                    theme.colorScheme.secondary,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          Text("$learned / $total completed",
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}