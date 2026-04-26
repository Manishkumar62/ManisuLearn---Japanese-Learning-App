# Performance Optimization

## Startup Performance

### JSON Loading
- All 7 JSON files loaded in parallel via `Future.wait()`
- Parsed and converted to `LearningItem` in a single pass

### Hive Writes
- Uses `putAll(batch)` for bulk writes instead of individual `put()` per item
- Version check skips reload when data hasn't changed

## Goals

- Smooth scrolling
- Fast filtering

## Techniques

- Use ListView.builder
- Avoid full rebuilds
- Cache filtered results
- Parallel asset loading

## BLoC

- Emit minimal states

## Notes

- Optimize after features are stable