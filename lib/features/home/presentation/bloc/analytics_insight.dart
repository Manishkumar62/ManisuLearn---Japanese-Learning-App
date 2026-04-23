enum InsightType {
  success,
  warning,
  danger,
  info,
}

class AnalyticsInsight {
  final String message;
  final InsightType type;

  const AnalyticsInsight({
    required this.message,
    required this.type,
  });
}