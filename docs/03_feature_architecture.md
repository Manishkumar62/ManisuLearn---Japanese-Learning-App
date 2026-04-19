# Feature-Based Clean Architecture

## Structure

/lib
  /core
    /utils
    /constants
  /features
    /home
    /library
    /learn
    /revision
    /search
    /add_data
  /data
    /models
    /local
  /domain
    /entities
    /repositories

## Per Feature Structure

feature/
  ├── data/
  ├── domain/
  ├── presentation/
      ├── bloc/
      ├── pages/
      ├── widgets/

## Principles

- Separation of concerns
- UI independent from data layer
- BLoC for state management
- Hive for persistence

## Dependency Flow

UI → BLoC → UseCase → Repository → Hive