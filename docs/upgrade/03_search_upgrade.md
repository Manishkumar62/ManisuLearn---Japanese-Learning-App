# Search Upgrade

## Current Problem
Simple contains() is weak

## Improvements

### Normalize Input

- lowercase
- trim spaces

### Match Fields

- japanese
- romaji
- hindi
- english

## Ranking Logic

Score based on:

- Exact match → +100
- Starts with → +50
- Contains → +20

Sort by highest score

## BLoC

Event:
- SearchQueryChanged

State:
- SearchResults

## Optional Upgrade

- Fuzzy matching (later)
- Token matching

## Notes

- Keep it fast (local only)