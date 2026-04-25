class AppError {
  AppError._();

  static String userMessage(Object error) {
    final msg = error.toString();

    if (msg.contains('FormatException')) {
      return 'Invalid data format. Please check your input.';
    }

    if (msg.contains('HiveError') || msg.contains('Box')) {
      return 'Storage error. Please restart the app.';
    }

    final cleaned = msg.replaceFirst(RegExp(r'^Exception:\s*'), '');

    return cleaned.isEmpty
        ? 'Something went wrong. Please try again.'
        : cleaned;
  }
}
