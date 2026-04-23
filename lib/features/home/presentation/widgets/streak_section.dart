import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class StreakSection extends StatefulWidget {
  final int streakDays;

  const StreakSection({super.key, required this.streakDays});

  @override
  State<StreakSection> createState() => _StreakSectionState();
}

class _StreakSectionState extends State<StreakSection> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMilestone(widget.streakDays)) {
        _controller.play();
      }
    });
  }

  bool _isMilestone(int streak) {
    return streak == 7 || streak == 30 || streak == 100;
  }

  String _getMessage(int streak) {
    if (streak == 0) return "Start your streak today!";
    if (streak < 7) return "Keep it going 🔥";
    if (streak == 7) return "1 Week Streak! 🎉";
    if (streak < 30) return "You're on fire 🚀";
    if (streak == 30) return "30 Days! Incredible 💪";
    if (streak < 100) return "Unstoppable 🔥";
    if (streak == 100) return "100 Days! Legend 🏆";
    return "Consistency wins 🔥";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            ),
          ),
          child: Row(
            children: [
              const Text("🔥", style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.streakDays} Day Streak",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMessage(widget.streakDays),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// 🎉 Confetti Layer
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
        ),
      ],
    );
  }
}