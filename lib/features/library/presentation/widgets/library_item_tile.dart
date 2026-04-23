import 'package:flutter/material.dart';

import '../../../../data/models/learning_item.dart';

class LibraryItemTile extends StatelessWidget {
  const LibraryItemTile({super.key, required this.item, this.onTap});

  final LearningItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              /// 🔥 LEFT ACCENT
              Container(
                width: 5,
                height: 90,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
              ),

              /// CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TOP ROW
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.japanese,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          /// STATUS BADGE
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
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      /// ROMAJI
                      Text(
                        item.romaji,
                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 8),

                      /// ENGLISH
                      Text(item.english, style: const TextStyle(fontSize: 13)),

                      if (item.hindi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.hindi,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      /// META + ACTION
                      Row(
                        children: [
                          _metaChip(context, item.type),
                          const SizedBox(width: 8),
                          _metaChip(context, "Rev ${item.revisionCount}"),

                          const Spacer(),

                          Text(
                            isLearned ? "Revise ↻" : "Learn →",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
    );
  }

  Widget _metaChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.white70),
      ),
    );
  }
}

// class _StatusBadge extends StatelessWidget {
//   const _StatusBadge({required this.isLearned, required this.isRevised});

//   final bool isLearned;
//   final bool isRevised;

//   @override
//   Widget build(BuildContext context) {
//     Color color;
//     String text;

//     if (!isLearned) {
//       color = Colors.orange;
//       text = "New";
//     } else if (isRevised) {
//       color = Colors.blue;
//       text = "Revised";
//     } else {
//       color = Colors.green;
//       text = "Learned";
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(text, style: TextStyle(color: color, fontSize: 12)),
//     );
//   }
// }

// class _MetaChip extends StatelessWidget {
//   const _MetaChip({required this.label});

//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         child: Text(label),
//       ),
//     );
//   }
// }
