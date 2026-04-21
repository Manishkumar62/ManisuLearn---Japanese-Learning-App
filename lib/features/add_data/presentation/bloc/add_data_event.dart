import 'package:equatable/equatable.dart';

abstract class AddDataEvent extends Equatable {
  const AddDataEvent();

  @override
  List<Object?> get props => const [];
}

class AddManualLearningItem extends AddDataEvent {
  const AddManualLearningItem({
    required this.type,
    required this.japanese,
    required this.romaji,
    required this.hindi,
    required this.english,
    required this.tags,
  });

  final String type;
  final String japanese;
  final String romaji;
  final String hindi;
  final String english;
  final List<String> tags;

  @override
  List<Object?> get props => <Object?>[
    type,
    japanese,
    romaji,
    hindi,
    english,
    tags,
  ];
}

class ImportLearningItemsFromJson extends AddDataEvent {
  const ImportLearningItemsFromJson(this.jsonText);

  final String jsonText;

  @override
  List<Object?> get props => <Object?>[jsonText];
}

class ResetAddDataStatus extends AddDataEvent {
  const ResetAddDataStatus();
}
