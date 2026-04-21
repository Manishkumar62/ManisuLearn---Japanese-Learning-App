import 'package:flutter/material.dart';

import '../../../../data/models/learning_item.dart';

class LibraryItemTile extends StatelessWidget {
  const LibraryItemTile({super.key, required this.item});

  final LearningItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.japanese,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(isLearned: item.isLearned),
                ],
              ),
              const SizedBox(height: 6),
              Text(item.romaji, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(item.english),
              if (item.hindi.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(item.hindi),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _MetaChip(label: item.type),
                  _MetaChip(label: 'Revisions ${item.revisionCount}'),
                  _MetaChip(label: 'Difficulty ${item.difficulty}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isLearned});

  final bool isLearned;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isLearned ? colorScheme.primary : colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          isLearned ? 'Learned' : 'New',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label),
      ),
    );
  }
}
