import 'package:flutter/material.dart';
import '../../../../domain/models/analytics_data.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final List<CategoryProgress> categories;

  const CategoryBreakdownCard({super.key, required this.categories});

  static const _typeConfig = {
    'word': (Icons.translate, 'Words'),
    'sentence': (Icons.short_text, 'Sentences'),
    'grammar': (Icons.auto_stories, 'Grammar'),
    'dialogue': (Icons.chat_bubble_outline, 'Dialogues'),
    'story': (Icons.menu_book, 'Stories'),
  };

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
          Row(
            children: [
              Icon(Icons.category_outlined, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Categories', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          ...categories.map((cat) => _CategoryRow(
                config: _typeConfig[cat.type] ?? (Icons.label_outline, cat.type),
                progress: cat.progress,
                learned: cat.learned,
                total: cat.total,
              )),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final (IconData, String) config;
  final double progress;
  final int learned;
  final int total;

  const _CategoryRow({
    required this.config,
    required this.progress,
    required this.learned,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(config.$1, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(config.$2, style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            child: Text(
              '$learned/$total',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
