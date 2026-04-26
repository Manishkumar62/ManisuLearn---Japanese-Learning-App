# Feature-Based Clean Architecture

## Structure

/lib
  /core
    /constants
      item_type.dart
    /navigation
      app_shell.dart
    /services
      json_loader.dart
      app_meta_service.dart
    /theme
      app_theme.dart
  /features
    /home
      /presentation
        /bloc
        /widgets
    /library
      /presentation
        /bloc
        /pages
        /widgets
    /learn
      /presentation
        /bloc
        /pages
        /widgets
    /revision
      /presentation
        /bloc
    /search
      /presentation
        /bloc
  /data
    /models
      learning_item.dart
      learning_item_adapter.dart
    /repositories
      hive_learning_item_repository.dart

## Per Feature Structure

feature/
  ├── presentation/
      ├── bloc/
      ├── pages/
      ├── widgets/

## Principles

- Separation of concerns
- UI independent from data layer
- BLoC for state management (flutter_bloc)
- Hive for persistence with versioned data migration

## Dependency Flow

UI → BLoC → Repository → Hive Box

## Key Services

- `JsonLoader` — loads all JSON data files in parallel, converts to LearningItem list
- `AppMetaService` — stores data version for migration control
- `HiveLearningItemRepository` — CRUD operations on Hive box