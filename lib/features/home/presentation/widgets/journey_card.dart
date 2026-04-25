import 'package:flutter/material.dart';

class JourneyCard extends StatelessWidget {
  final int learnedItems;
  final int totalItems;
  final double retentionRate;
  final int streakDays;
  final int totalReviews;

  const JourneyCard({
    super.key,
    required this.learnedItems,
    required this.totalItems,
    required this.retentionRate,
    required this.streakDays,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalItems == 0 ? 0.0 : learnedItems / totalItems;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text("Your Journey", style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),

          /// Progress bar
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$learnedItems of $totalItems items mastered',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          /// Stat chips
          Row(
            children: [
              _JourneyChip(
                icon: Icons.local_fire_department_outlined,
                label: '$streakDays day streak',
                color: streakDays > 0 ? Colors.orange : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              _JourneyChip(
                icon: Icons.psychology_outlined,
                label: '${retentionRate.toStringAsFixed(0)}% retention',
                color: retentionRate >= 80
                    ? Colors.green
                    : retentionRate >= 50
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              _JourneyChip(
                icon: Icons.replay_outlined,
                label: '$totalReviews reviews',
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _JourneyChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
