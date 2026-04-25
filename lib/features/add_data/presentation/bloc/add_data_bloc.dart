import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_utils.dart';
import '../../../../data/models/learning_item.dart';
import '../../../../domain/repositories/learning_item_repository.dart';
import 'add_data_event.dart';
import 'add_data_state.dart';

class AddDataBloc extends Bloc<AddDataEvent, AddDataState> {
  AddDataBloc({required LearningItemRepository repository})
    : _repository = repository,
      super(const AddDataInitial()) {
    on<AddManualLearningItem>(_onAddManualLearningItem);
    on<ImportLearningItemsFromJson>(_onImportLearningItemsFromJson);
    on<ResetAddDataStatus>(_onResetAddDataStatus);
  }

  final LearningItemRepository _repository;

  Future<void> _onAddManualLearningItem(
    AddManualLearningItem event,
    Emitter<AddDataState> emit,
  ) async {
    emit(const AddDataSaving());

    try {
      final item = _createLearningItem(
        type: event.type,
        japanese: event.japanese,
        romaji: event.romaji,
        hindi: event.hindi,
        english: event.english,
        tags: event.tags,
      );

      await _repository.addItem(item);
      emit(const AddDataSuccess(message: 'Learning item added.'));
    } catch (error) {
      emit(AddDataError(AppError.userMessage(error)));
    }
  }

  Future<void> _onImportLearningItemsFromJson(
    ImportLearningItemsFromJson event,
    Emitter<AddDataState> emit,
  ) async {
    emit(const AddDataSaving());

    try {
      final decoded = json.decode(event.jsonText);
      if (decoded is! List) {
        throw const FormatException('JSON must be a list of items.');
      }

      final items = decoded.map(_learningItemFromJson).toList(growable: false);

      for (final item in items) {
        await _repository.addItem(item);
      }

      emit(AddDataSuccess(message: '${items.length} items imported.'));
    } catch (error) {
      emit(AddDataError(AppError.userMessage(error)));
    }
  }

  void _onResetAddDataStatus(
    ResetAddDataStatus event,
    Emitter<AddDataState> emit,
  ) {
    emit(const AddDataInitial());
  }

  LearningItem _learningItemFromJson(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Each JSON entry must be an object.');
    }

    return _createLearningItem(
      type: value['type'] as String? ?? '',
      japanese: value['japanese'] as String? ?? '',
      romaji: value['romaji'] as String? ?? '',
      hindi: value['hindi'] as String? ?? '',
      english: value['english'] as String? ?? '',
      tags: (value['tags'] as List?)?.cast<String>() ?? <String>[],
    );
  }

  LearningItem _createLearningItem({
    required String type,
    required String japanese,
    required String romaji,
    required String hindi,
    required String english,
    required List<String> tags,
  }) {
    final normalizedType = type.trim().toLowerCase();
    final normalizedJapanese = japanese.trim();
    final normalizedRomaji = romaji.trim();
    final normalizedHindi = hindi.trim();
    final normalizedEnglish = english.trim();
    final normalizedTags = tags
        .map((String tag) => tag.trim())
        .where((String tag) => tag.isNotEmpty)
        .toList(growable: false);

    if (normalizedType.isEmpty ||
        normalizedJapanese.isEmpty ||
        normalizedRomaji.isEmpty ||
        normalizedHindi.isEmpty ||
        normalizedEnglish.isEmpty) {
      throw const FormatException('Type and translations are required.');
    }

    return LearningItem(
      id: _createId(normalizedType, normalizedJapanese),
      type: normalizedType,
      japanese: normalizedJapanese,
      romaji: normalizedRomaji,
      hindi: normalizedHindi,
      english: normalizedEnglish,
      tags: normalizedTags,
    );
  }

  String _createId(String type, String japanese) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final normalizedJapanese = japanese.replaceAll(RegExp(r'\s+'), '_');

    return '${type}_${timestamp}_$normalizedJapanese';
  }
}
