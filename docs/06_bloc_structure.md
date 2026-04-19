# BLoC Structure

## Blocs

1. LibraryBloc
2. LearnBloc
3. RevisionBloc
4. SearchBloc
5. AddDataBloc

## Example Structure

Bloc
  ├── Event
  ├── State
  ├── Bloc

## Example Events

LoadItems
AddItem
UpdateItem
MarkLearned
ReviseItem
SearchQueryChanged

## Example States

Initial
Loading
Loaded
Error

## Notes

- Keep events granular
- Avoid large monolithic blocs
- One feature = one bloc