import 'package:flutter/material.dart';
import 'modern_card.dart';

class AnalyticsCard extends StatelessWidget {
  final int learned;
  final int total;
  final int due;
  final double retention;

  const AnalyticsCard({
    super.key,
    required this.learned,
    required this.total,
    required this.due,
    required this.retention,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      icon: Icons.insights_outlined,
      title: "Your Progress",
      body:
          "Learned $learned/$total\nDue: $due\nRetention: ${retention.toStringAsFixed(1)}%",
    );
  }
}