import 'dart:math';

import 'package:flutter/material.dart';

class TodayProgressCard extends StatelessWidget {
  final int reviewedToday;
  final int learnedToday;
  final int dueToday;
  final int learnedItems;
  final int totalItems;

  const TodayProgressCard({
    super.key,
    required this.reviewedToday,
    required this.learnedToday,
    required this.dueToday,
    required this.learnedItems,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActivity = reviewedToday > 0 || learnedToday > 0;

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
              Icon(Icons.today_outlined, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text("Today's Activity", style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),

          if (hasActivity)
            _buildActiveState(context)
          else
            _buildIdleState(context),
        ],
      ),
    );
  }

  Widget _buildActiveState(BuildContext context) {
    final theme = Theme.of(context);
    final total = reviewedToday + learnedToday;
    final goalTarget = (total + dueToday).clamp(total, total + dueToday);
    final activityRatio = goalTarget == 0 ? 0.0 : (total / goalTarget).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: activityRatio),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _RingPainter(
                      progress: value,
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      strokeWidth: 8,
                    ),
                  );
                },
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'done',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _TodayStat(
                icon: Icons.replay_outlined,
                label: 'Reviewed',
                value: '$reviewedToday',
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _TodayStat(
                icon: Icons.school_outlined,
                label: 'Learned',
                value: '$learnedToday',
                color: theme.colorScheme.secondary,
              ),
              if (dueToday > 0) ...[
                const SizedBox(height: 12),
                _TodayStat(
                  icon: Icons.schedule_outlined,
                  label: 'Due',
                  value: '$dueToday',
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdleState(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = totalItems - learnedItems;

    if (remaining == 0) {
      return Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _RingPainter(
                    progress: 1.0,
                    color: Colors.green,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    strokeWidth: 8,
                  ),
                ),
                Center(
                  child: Icon(Icons.emoji_events_outlined, color: Colors.green, size: 36),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All caught up!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No reviews due today. Come back later for more.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _RingPainter(
                  progress: 0,
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  strokeWidth: 8,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$remaining',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'left',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to practice?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dueToday > 0
                    ? '$dueToday reviews waiting for you today.'
                    : 'Keep going — $remaining items left to master.',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TodayStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
        ),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        )),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
