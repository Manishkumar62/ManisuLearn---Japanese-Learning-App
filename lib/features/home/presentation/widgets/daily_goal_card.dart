import 'dart:math';

import 'package:flutter/material.dart';

class DailyGoalCard extends StatelessWidget {
  final int done;
  final int goal;

  const DailyGoalCard({super.key, required this.done, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = goal == 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);
    final isComplete = done >= goal && goal > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_outlined, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Daily Goal', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: ratio),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CustomPaint(
                          painter: _RingPainter(
                            progress: value,
                            color: isComplete ? Colors.green : theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            strokeWidth: 7,
                          ),
                        );
                      },
                    ),
                    Center(
                      child: isComplete
                          ? Icon(Icons.check_circle, color: Colors.green, size: 28)
                          : Text(
                              '$done/$goal',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isComplete) ...[
                      Text(
                        'Goal reached!',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You\'ve completed your daily target. Keep it up!',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '${goal - done} more to go',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review ${goal - done} more items to hit your daily goal.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
      center, radius,
      Paint()..color = backgroundColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, 2 * pi * progress, false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
