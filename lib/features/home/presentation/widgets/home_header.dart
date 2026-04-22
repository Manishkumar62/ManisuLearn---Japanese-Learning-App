import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? "Good Morning 👋" : hour < 18 ? "Good Afternoon 👋" : "Good Evening 👋";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manisu Learn",
          style: theme.textTheme.headlineMedium,
        ),
      ],
    );
  }
}