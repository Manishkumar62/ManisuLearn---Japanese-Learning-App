enum ItemType {
  hiragana('hiragana'),
  katakana('katakana'),
  kanji('kanji'),
  word('word'),
  sentence('sentence'),
  dialogue('dialogue'),
  grammar('grammar'),
  story('story');

  const ItemType(this.value);

  final String value;

  static ItemType fromString(String value) {
    return ItemType.values.firstWhere(
      (ItemType e) => e.value == value,
      orElse: () => ItemType.word,
    );
  }
}
