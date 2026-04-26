# Add Data Feature

## Modes

1. Manual Entry
2. JSON Import

## Fields

- Type (hiragana, katakana, kanji, word, sentence, dialogue, grammar)
- Japanese
- Romaji
- Hindi
- English
- Tags

## JSON Format

```json
[
  {
    "type": "word",
    "japanese": "こんにちは",
    "romaji": "konnichiwa",
    "hindi": "नमस्ते",
    "english": "hello",
    "tags": ["greeting"],
    "id": "word_2"
  }
]
```

## Data Update Flow

1. Edit JSON files in `assets/data/`
2. Bump `currentDataVersion` in `main.dart`
3. On app start, version mismatch triggers reload
4. Existing user progress is preserved (isLearned, revisionCount, SM-2 fields)
5. New items get default values