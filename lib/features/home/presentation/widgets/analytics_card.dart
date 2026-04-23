import 'package:flutter/material.dart';
import '../bloc/analytics_insight.dart';

class AnalyticsCard extends StatefulWidget {
  final int learned;
  final int total;
  final int due;
  final double retention;

  final List<AnalyticsInsight> insights;
  final List<double> weeklyProgress;

  const AnalyticsCard({
    super.key,
    required this.learned,
    required this.total,
    required this.due,
    required this.retention,
    required this.insights,
    required this.weeklyProgress,
  });

  @override
  State<AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<AnalyticsCard> {
  bool showChart = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 HEADER
          Row(
            children: [
              Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text("Your Progress", style: theme.textTheme.titleMedium),
            ],
          ),

          const SizedBox(height: 16),

          /// 📊 STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: "Learned",
                value: "${widget.learned}/${widget.total}",
              ),
              _StatItem(label: "Due", value: "${widget.due}"),
              _StatItem(
                label: "Retention",
                value: "${widget.retention.toStringAsFixed(0)}%",
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🔄 TOGGLE
          Row(
            children: [
              _ToggleButton(
                label: "Chart",
                selected: showChart,
                onTap: () => setState(() => showChart = true),
              ),
              const SizedBox(width: 8),
              _ToggleButton(
                label: "Insights",
                selected: !showChart,
                onTap: () => setState(() => showChart = false),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🎯 SWITCH CONTENT
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: showChart
                ? _WeeklyChart(
                    key: const ValueKey('chart'),
                    data: widget.weeklyProgress,
                  )
                : Column(
                    key: const ValueKey('insights'),
                    children: widget.insights
                        .map((e) => _InsightTile(insight: e))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  _ToggleButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.black : Colors.white70),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatefulWidget {
  final List<double> data;

  const _WeeklyChart({super.key, required this.data});

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart> {
  int? selectedIndex;

  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 📊 TITLE
        Text(
          "Weekly Reviews",
          style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
        ),

        const SizedBox(height: 12),

        /// 📊 BARS
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.data.length, (index) {
              final value = widget.data[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = index);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// BAR
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: (value * 60).clamp(6, 60),
                        width: 10,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary.withValues(
                                  alpha: 0.7,
                                ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// DAY LABEL
                      Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        /// 📊 SELECTED INFO
        if (selectedIndex != null)
          Text(
            "${days[selectedIndex!]}: ${(widget.data[selectedIndex!] * 100).toStringAsFixed(0)}% activity",
            style: const TextStyle(color: Colors.white70),
          ),
      ],
    );
  }
}

class _InsightTile extends StatefulWidget {
  final AnalyticsInsight insight;

  _InsightTile({
    super.key, // ✅ add
    required this.insight,
  });

  @override
  State<_InsightTile> createState() => _InsightTileState();
}

class _InsightTileState extends State<_InsightTile> {
  bool expanded = false;

  Color _getColor() {
    switch (widget.insight.type) {
      case InsightType.success:
        return Colors.green;
      case InsightType.warning:
        return Colors.orange;
      case InsightType.danger:
        return Colors.red;
      case InsightType.info:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (widget.insight.type) {
      case InsightType.success:
        return Icons.check_circle;
      case InsightType.warning:
        return Icons.warning;
      case InsightType.danger:
        return Icons.error;
      case InsightType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(_getIcon(), color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.insight.message,
                maxLines: expanded ? 3 : 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60)),
      ],
    );
  }
}
