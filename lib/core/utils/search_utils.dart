class SearchUtils {
  static List<T> rankedSearch<T>({
    required List<T> items,
    required String query,
    required List<String Function(T)> fields,
  }) {
    if (query.trim().isEmpty) return items;

    final q = query.toLowerCase().trim();

    final List<_ScoredItem<T>> scored = [];

    for (final item in items) {
      int score = 0;

      for (final field in fields) {
        final value = field(item).toLowerCase();

        if (value == q) {
          score += 100;
        } else if (value.startsWith(q)) {
          score += 50;
        } else if (value.contains(q)) {
          score += 10;
        }
      }

      if (score > 0) {
        scored.add(_ScoredItem(item, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((e) => e.item).toList();
  }
}

class _ScoredItem<T> {
  final T item;
  final int score;

  _ScoredItem(this.item, this.score);
}