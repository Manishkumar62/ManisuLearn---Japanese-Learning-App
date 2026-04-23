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

    /// 🧠 DAYS AGO
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

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔝 TOP ROW
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

                          /// STATUS
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

                      /// 🧾 ROMAJI
                      Text(
                        item.romaji,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 🌍 MEANING
                      Text(item.english, style: const TextStyle(fontSize: 12)),

                      if (item.hindi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.hindi,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),

                      /// 🔻 META ROW (compact + powerful)
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

                          /// CTA
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
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.white70),
      ),
    );
  }
}
