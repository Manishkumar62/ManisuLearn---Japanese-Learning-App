import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/item_type.dart';

import '../bloc/add_data_bloc.dart';
import '../bloc/add_data_event.dart';
import '../bloc/add_data_state.dart';

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController(text: ItemType.word.value);
  final _japaneseController = TextEditingController();
  final _romajiController = TextEditingController();
  final _hindiController = TextEditingController();
  final _englishController = TextEditingController();
  final _tagsController = TextEditingController();
  final _jsonController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _japaneseController.dispose();
    _romajiController.dispose();
    _hindiController.dispose();
    _englishController.dispose();
    _tagsController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  void _addManualItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AddDataBloc>().add(
      AddManualLearningItem(
        type: _typeController.text,
        japanese: _japaneseController.text,
        romaji: _romajiController.text,
        hindi: _hindiController.text,
        english: _englishController.text,
        tags: _parseTags(_tagsController.text),
      ),
    );
  }

  void _importJson() {
    context.read<AddDataBloc>().add(
      ImportLearningItemsFromJson(_jsonController.text),
    );
  }

  List<String> _parseTags(String value) {
    return value
        .split(',')
        .map((String tag) => tag.trim())
        .where((String tag) => tag.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocListener<AddDataBloc, AddDataState>(
        listener: (BuildContext context, AddDataState state) {
          if (state is AddDataSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            _formKey.currentState?.reset();
            _typeController.text = ItemType.word.value;
            _japaneseController.clear();
            _romajiController.clear();
            _hindiController.clear();
            _englishController.clear();
            _tagsController.clear();
            _jsonController.clear();
          }

          if (state is AddDataError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add data'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(text: 'Manual'),
                Tab(text: 'JSON import'),
              ],
            ),
          ),
          body: BlocBuilder<AddDataBloc, AddDataState>(
            builder: (BuildContext context, AddDataState state) {
              final isSaving = state is AddDataSaving;

              return TabBarView(
                children: <Widget>[
                  _ManualEntryForm(
                    formKey: _formKey,
                    typeController: _typeController,
                    japaneseController: _japaneseController,
                    romajiController: _romajiController,
                    hindiController: _hindiController,
                    englishController: _englishController,
                    tagsController: _tagsController,
                    isSaving: isSaving,
                    onSubmit: _addManualItem,
                  ),
                  _JsonImportForm(
                    controller: _jsonController,
                    isSaving: isSaving,
                    onSubmit: _importJson,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ManualEntryForm extends StatelessWidget {
  const _ManualEntryForm({
    required this.formKey,
    required this.typeController,
    required this.japaneseController,
    required this.romajiController,
    required this.hindiController,
    required this.englishController,
    required this.tagsController,
    required this.isSaving,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController typeController;
  final TextEditingController japaneseController;
  final TextEditingController romajiController;
  final TextEditingController hindiController;
  final TextEditingController englishController;
  final TextEditingController tagsController;
  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _RequiredTextField(controller: typeController, labelText: 'Type'),
          const SizedBox(height: 12),
          _RequiredTextField(
            controller: japaneseController,
            labelText: 'Japanese',
          ),
          const SizedBox(height: 12),
          _RequiredTextField(controller: romajiController, labelText: 'Romaji'),
          const SizedBox(height: 12),
          _RequiredTextField(controller: hindiController, labelText: 'Hindi'),
          const SizedBox(height: 12),
          _RequiredTextField(
            controller: englishController,
            labelText: 'English',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: tagsController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Tags',
              hintText: 'greeting, beginner',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isSaving ? null : onSubmit,
            child: Text(isSaving ? 'Saving...' : 'Add item'),
          ),
        ],
      ),
    );
  }
}

class _JsonImportForm extends StatelessWidget {
  const _JsonImportForm({
    required this.controller,
    required this.isSaving,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        TextField(
          controller: controller,
          minLines: 10,
          maxLines: 18,
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            labelText: 'JSON items',
            hintText:
                '[{"type":"word","japanese":"こんにちは","romaji":"konnichiwa","hindi":"नमस्ते","english":"Hello"}]',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: isSaving ? null : onSubmit,
          child: Text(isSaving ? 'Importing...' : 'Import JSON'),
        ),
      ],
    );
  }
}

class _RequiredTextField extends StatelessWidget {
  const _RequiredTextField({required this.controller, required this.labelText});

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
      ),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return '$labelText is required';
        }

        return null;
      },
    );
  }
}
