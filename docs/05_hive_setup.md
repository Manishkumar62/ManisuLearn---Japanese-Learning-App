# Hive Setup

## Packages
- hive
- hive_flutter

## Initialization (main.dart)

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Hive.initFlutter()`
3. Register `LearningItemAdapter` (typeId: 0)
4. Open box: `learning_items`

## Data Versioning

- Current version stored via `AppMetaService`
- On version bump: reload JSON, preserve user progress, batch-write to Hive
- Uses `learningBox.putAll(batch)` for fast bulk writes

## Box Structure

`Box<LearningItem>` — key is `item.id`

## Repository

`HiveLearningItemRepository` provides:
- Get all items
- Get by type
- Get by id
- Filter by tags / learned status
- Update item (progress, SM-2 fields)
- Watch items (reactive stream)

## Performance Notes

- JSON files loaded in parallel via `Future.wait()`
- Batch Hive writes via `putAll()` instead of individual `put()`
- Version check skips reload on subsequent launches