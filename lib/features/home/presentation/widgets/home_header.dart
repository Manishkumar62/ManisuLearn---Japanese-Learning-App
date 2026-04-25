import 'package:flutter/material.dart';

class HomeHeader extends StatefulWidget {
  final int streakDays;

  const HomeHeader({super.key, required this.streakDays});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  int? _previousStreak;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _previousStreak = widget.streakDays;
  }

  @override
  void didUpdateWidget(covariant HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.streakDays > (_previousStreak ?? 0)) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }

    _previousStreak = widget.streakDays;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? "Good Morning 👋" : hour < 18 ? "Good Afternoon 👋" : "Good Evening 👋";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// LEFT
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Manisu Learn",
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),

        /// RIGHT (🔥 ANIMATED STREAK)
        AnimatedBuilder(
          animation: _scale,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (widget.streakDays > 0)
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
              ],
            ),
            child: Row(
              children: [
                const Text("🔥"),
                const SizedBox(width: 6),
                Text(
                  "${widget.streakDays}",
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
