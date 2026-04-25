import 'package:flutter/material.dart';

import '../../../../data/models/learning_item.dart';

class LibraryItemTile extends StatefulWidget {
  const LibraryItemTile({super.key, required this.item, this.onTap});

  final LearningItem item;
  final VoidCallback? onTap;

  @override
  State<LibraryItemTile> createState() => _LibraryItemTileState();
}

class _LibraryItemTileState extends State<LibraryItemTile> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;

    final isLearned = item.isLearned;
    final isRevised = item.revisionCount > 0;

    Color accentColor;
    String status;

    if (!isLearned) {
      accentColor = Colors.orange;
      status = "New";
    } else if (isRevised) {
      accentColor = Colors.blue;
      status = "Revised";
    } else {
      accentColor = Colors.green;
      status = "Learned";
    }

    final daysAgo = item.lastReviewed == null
        ? null
        : DateTime.now().difference(item.lastReviewed!).inDays;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => scale = 0.97),
      onTapUp: (_) => setState(() => scale = 1.0),
      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.japanese,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          item.romaji,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          item.english,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        if (item.hindi.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.hindi,
                            style: TextStyle(
                              fontSize: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            _chip(context, item.type),

                            const SizedBox(width: 6),

                            _chip(context, "Rev ${item.revisionCount}"),

                            const SizedBox(width: 6),

                            _chip(
                              context,
                              daysAgo == null ? "New" : "$daysAgo d ago",
                            ),

                            const Spacer(),

                            Text(
                              isLearned ? "↻ Revise" : "→ Learn",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
