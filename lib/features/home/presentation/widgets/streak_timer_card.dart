import 'dart:async';

import 'package:flutter/material.dart';

class StreakTimerCard extends StatefulWidget {
  final int streakDays;
  final bool hasActivityToday;

  const StreakTimerCard({
    super.key,
    required this.streakDays,
    required this.hasActivityToday,
  });

  @override
  State<StreakTimerCard> createState() => _StreakTimerCardState();
}

class _StreakTimerCardState extends State<StreakTimerCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateRemaining());
  }

  @override
  void didUpdateWidget(covariant StreakTimerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRemaining();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    setState(() => _remaining = midnight.difference(now));
  }

  String get _timeLeft {
    final h = _remaining.inHours;
    final m = _remaining.inMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.streakDays == 0) return const SizedBox.shrink();

    final isSafe = widget.hasActivityToday;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSafe
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSafe
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSafe ? Icons.local_fire_department : Icons.timer_outlined,
            color: isSafe ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: isSafe
                ? Text(
                    'Streak safe! ${widget.streakDays} day streak maintained.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: '${widget.streakDays}-day streak at risk! ',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '$_timeLeft left today.'),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
