import 'package:flutter/material.dart';

class ProgressChartCard extends StatefulWidget {
  final List<int> reviewedData;
  final List<int> learnedData;
  final ChartPeriod period;

  const ProgressChartCard({
    super.key,
    required this.reviewedData,
    required this.learnedData,
    required this.period,
  });

  @override
  State<ProgressChartCard> createState() => _ProgressChartCardState();
}

class _ProgressChartCardState extends State<ProgressChartCard> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant ProgressChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _selectedIndex = null;
    }
  }

  List<String> get _labels {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (widget.period) {
      case ChartPeriod.weekly:
        return List.generate(7, (i) {
          final day = today.subtract(Duration(days: 6 - i));
          return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1];
        });
      case ChartPeriod.monthly:
        return List.generate(4, (w) {
          final weekStart = today.subtract(Duration(days: (3 - w) * 7 + 6));
          return '${weekStart.day}/${weekStart.month}';
        });
      case ChartPeriod.yearly:
        return List.generate(12, (i) {
          final month = DateTime(now.year, now.month - 11 + i, 1);
          return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month.month - 1];
        });
    }
  }

  String get _title {
    switch (widget.period) {
      case ChartPeriod.weekly:
        return 'Last 7 Days';
      case ChartPeriod.monthly:
        return 'Last 4 Weeks';
      case ChartPeriod.yearly:
        return 'Last 12 Months';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewed = widget.reviewedData;
    final learned = widget.learnedData;
    final labels = _labels;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(_title, style: theme.textTheme.titleMedium),
                ],
              ),
              Row(
                children: [
                  _LegendDot(color: theme.colorScheme.primary, label: 'Reviewed'),
                  const SizedBox(width: 10),
                  _LegendDot(color: theme.colorScheme.secondary, label: 'Learned'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onHorizontalDragUpdate: (details) {
              final box = context.findRenderObject() as RenderBox;
              final chartArea = _chartRect(box.size);
              final localX = details.localPosition.dx;
              if (localX >= chartArea.left && localX <= chartArea.right) {
                final count = reviewed.length;
                final step = chartArea.width / (count - 1).clamp(1, count);
                final idx = ((localX - chartArea.left) / step).round().clamp(0, count - 1);
                if (_selectedIndex != idx) setState(() => _selectedIndex = idx);
              }
            },
            onTapUp: (details) {
              final box = context.findRenderObject() as RenderBox;
              final chartArea = _chartRect(box.size);
              final localX = details.localPosition.dx;
              if (localX >= chartArea.left && localX <= chartArea.right) {
                final count = reviewed.length;
                final step = chartArea.width / (count - 1).clamp(1, count);
                final idx = ((localX - chartArea.left) / step).round().clamp(0, count - 1);
                setState(() => _selectedIndex = _selectedIndex == idx ? null : idx);
              }
            },
            child: CustomPaint(
              painter: _LineChartPainter(
                reviewedData: reviewed,
                learnedData: learned,
                labels: labels,
                reviewedColor: theme.colorScheme.primary,
                learnedColor: theme.colorScheme.secondary,
                gridColor: theme.colorScheme.surfaceContainerHighest,
                textColor: theme.colorScheme.onSurfaceVariant,
                selectedIndex: _selectedIndex,
              ),
              size: const Size(double.infinity, 140),
            ),
          ),

          // Selected detail — shows actual counts
          if (_selectedIndex != null && _selectedIndex! < reviewed.length) ...[
            const SizedBox(height: 8),
            Text(
              '${labels[_selectedIndex!]}: '
              '${reviewed[_selectedIndex!]} reviewed, '
              '${learned[_selectedIndex!]} learned',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Rect _chartRect(Size boxSize) {
    const horizontalPadding = 16.0;
    const verticalPadding = 24.0;
    final w = boxSize.width - horizontalPadding * 2;
    final h = 140.0 - verticalPadding * 2;
    return Rect.fromLTWH(horizontalPadding, verticalPadding, w, h);
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> reviewedData;
  final List<int> learnedData;
  final List<String> labels;
  final Color reviewedColor;
  final Color learnedColor;
  final Color gridColor;
  final Color textColor;
  final int? selectedIndex;

  _LineChartPainter({
    required this.reviewedData,
    required this.learnedData,
    required this.labels,
    required this.reviewedColor,
    required this.learnedColor,
    required this.gridColor,
    required this.textColor,
    required this.selectedIndex,
  });

  static const double _padH = 16;
  static const double _padV = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _padH * 2;
    final chartH = size.height - _padV * 2;
    final count = reviewedData.length;
    if (count == 0) return;

    // Find max across both datasets for normalization
    int maxVal = 0;
    for (final v in reviewedData) {
      if (v > maxVal) maxVal = v;
    }
    for (final v in learnedData) {
      if (v > maxVal) maxVal = v;
    }

    final stepX = count > 1 ? chartW / (count - 1) : 0.0;

    // Grid lines
    final gridPaint = Paint()..color = gridColor;
    for (int i = 0; i <= 3; i++) {
      final y = _padV + (chartH / 3) * i;
      canvas.drawLine(Offset(_padH, y), Offset(size.width - _padH, y), gridPaint);
    }

    // Grid labels (actual counts)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    if (maxVal > 0) {
      for (int i = 0; i <= 3; i++) {
        final val = (maxVal * (3 - i) / 3).round();
        final y = _padV + (chartH / 3) * i;
        textPainter.text = TextSpan(
          text: '$val',
          style: TextStyle(fontSize: 8, color: textColor.withValues(alpha: 0.5)),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
      }
    }

    // Build normalized points
    List<Offset> reviewedPoints = [];
    List<Offset> learnedPoints = [];
    for (int i = 0; i < count; i++) {
      final x = _padH + stepX * i;
      final rNorm = maxVal == 0 ? 0.0 : reviewedData[i] / maxVal;
      final lNorm = maxVal == 0 ? 0.0 : learnedData[i] / maxVal;
      reviewedPoints.add(Offset(x, _padV + chartH * (1 - rNorm)));
      learnedPoints.add(Offset(x, _padV + chartH * (1 - lNorm)));
    }

    // Filled area under learned
    if (learnedData.any((v) => v > 0)) {
      final path = Path();
      path.moveTo(learnedPoints.first.dx, _padV + chartH);
      for (final p in learnedPoints) {
        path.lineTo(p.dx, p.dy);
      }
      path.lineTo(learnedPoints.last.dx, _padV + chartH);
      path.close();
      canvas.drawPath(path, Paint()..color = learnedColor.withValues(alpha: 0.1));
    }

    // Filled area under reviewed
    if (reviewedData.any((v) => v > 0)) {
      final path = Path();
      path.moveTo(reviewedPoints.first.dx, _padV + chartH);
      for (final p in reviewedPoints) {
        path.lineTo(p.dx, p.dy);
      }
      path.lineTo(reviewedPoints.last.dx, _padV + chartH);
      path.close();
      canvas.drawPath(path, Paint()..color = reviewedColor.withValues(alpha: 0.1));
    }

    // Lines
    _drawLine(canvas, learnedPoints, learnedColor.withValues(alpha: 0.7), 2);
    _drawLine(canvas, reviewedPoints, reviewedColor, 2.5);

    // Dots
    for (int i = 0; i < count; i++) {
      final isSelected = selectedIndex == i;
      final r = isSelected ? 5.0 : 3.0;

      canvas.drawCircle(reviewedPoints[i], r, Paint()..color = reviewedColor);

      if (learnedData[i] > 0) {
        canvas.drawCircle(learnedPoints[i], r, Paint()..color = learnedColor);
      }
    }

    // Selected vertical line
    if (selectedIndex != null && selectedIndex! < count) {
      final x = reviewedPoints[selectedIndex!].dx;
      canvas.drawLine(
        Offset(x, _padV), Offset(x, _padV + chartH),
        Paint()..color = reviewedColor.withValues(alpha: 0.3)..strokeWidth = 1,
      );
    }

    // X-axis labels
    for (int i = 0; i < count; i++) {
      final isSelected = selectedIndex == i;
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(fontSize: 9, color: isSelected ? reviewedColor : textColor),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(reviewedPoints[i].dx - textPainter.width / 2, size.height - 14),
      );
    }
  }

  void _drawLine(Canvas canvas, List<Offset> points, Color color, double strokeWidth) {
    if (points.length < 2) {
      if (points.length == 1) {
        canvas.drawCircle(points[0], 3, Paint()..color = color);
      }
      return;
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.reviewedData != reviewedData ||
      old.learnedData != learnedData ||
      old.selectedIndex != selectedIndex;
}

enum ChartPeriod { weekly, monthly, yearly }

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
