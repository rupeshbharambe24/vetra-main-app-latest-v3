import 'package:flutter/material.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  // sample data (scores over last 8 sessions)
  List<double> get data => [72, 78, 85, 80, 88, 90, 86, 92];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = _avg(data).toStringAsFixed(1);

    return VetraGradientScaffold(
      appBar: AppBar(
        leading: const VetraBackButton(color: Colors.white),
        title: const Text('Analysis', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: Column(
          children: [
            // header card with mini chart
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Recent performance', style: theme.textTheme.titleLarge),
                    Text('Avg: $avg', style: theme.textTheme.titleLarge),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: _SimpleLineChart(
                      data: data,
                      lineColor: theme.colorScheme.primary,
                      fillColor: theme.colorScheme.primary.withOpacity(0.08),
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // stat cards
            Row(
              children: [
                _statCard(context, 'Total Reports', '12'),
                const SizedBox(width: 10),
                _statCard(context, 'This Month', '3'),
                const SizedBox(width: 10),
                _statCard(context, 'Avg Score', avg),
              ],
            ),

            const SizedBox(height: 12),

            // recent reports list (placeholder) - visible Card/ListTile needs no special global text change if inside Card
            // However, the list is directly on the background? No, we need to wrap it or let it float.
            // The design shows ListTile directly on background.
            // ListTiles directly on dark gradient will be unreadable unless styled. 
            // Better to wrap list items in Cards to keep the white-card aesthetic consistent.
            Expanded(
              child: ListView(
                children: const [
                  Card(child: ListTile(
                    leading: Icon(Icons.assignment_turned_in, color: Colors.green),
                    title: Text('CATTLE00173'),
                    subtitle: Text('Score: 83 — 29 Sep 2025'),
                    trailing: CircleAvatar(radius: 16, backgroundColor: Color(0xFFe6f7ef), child: Text('83', style: TextStyle(color: Colors.green))),
                  )),
                  Card(child: ListTile(
                    leading: Icon(Icons.assignment_turned_in, color: Colors.green),
                    title: Text('BUFFALO00170'),
                    subtitle: Text('Score: 76 — 14 Sep 2025'),
                    trailing: CircleAvatar(radius: 16, backgroundColor: Color(0xFFeef6ff), child: Text('76', style: TextStyle(color: Colors.blue))),
                  )),
                  Card(child: ListTile(
                    leading: Icon(Icons.assignment_turned_in, color: Colors.green),
                    title: Text('CATTLE00160'),
                    subtitle: Text('Score: 89 — 10 Sep 2025'),
                    trailing: CircleAvatar(radius: 16, backgroundColor: Color(0xFFe6f7ef), child: Text('89', style: TextStyle(color: Colors.green))),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  double _avg(List<double> d) => d.fold(0.0, (p, e) => p + e) / d.length;
}

/// Simple custom painter-based line chart.
class _SimpleLineChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  const _SimpleLineChart({required this.data, required this.lineColor, required this.fillColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(data: data, lineColor: lineColor, fillColor: fillColor),
      size: Size.infinite,
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter({required this.data, required this.lineColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintLine = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()..color = fillColor..style = PaintingStyle.fill;

    // compute horizontal spacing
    final dx = size.width / (data.length - 1);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);

    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // map data to points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      // invert y: larger values should be higher on screen
      final normalized = (data[i] - minVal) / range;
      final y = size.height - (normalized * size.height);
      points.add(Offset(x, y));
    }

    // draw filled area (polygon)
    final path = Path();
    path.moveTo(points.first.dx, size.height);
    for (final p in points) path.lineTo(p.dx, p.dy);
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, paintFill);

    // draw smooth-ish polyline using quadratic beziers
    final pathLine = Path();
    pathLine.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      pathLine.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    // connect last segment
    final last = points.last;
    pathLine.lineTo(last.dx, last.dy);
    canvas.drawPath(pathLine, paintLine);

    // draw dots
    final dotPaint = Paint()..color = lineColor..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 3.0, dotPaint);
    }

    // draw y-grid labels (optional simple labels)
    final textStyle = TextStyle(color: Colors.grey[600], fontSize: 10);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final steps = 4;
    for (int i = 0; i <= steps; i++) {
      final v = minVal + (range * (i / steps));
      final label = v.toStringAsFixed(0);
      textPainter.text = TextSpan(text: label, style: textStyle);
      textPainter.layout();
      final y = size.height - (i / steps) * size.height - textPainter.height / 2;
      textPainter.paint(canvas, Offset(4, y));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor || oldDelegate.fillColor != fillColor;
  }
}
