import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/task_provider.dart';

/// Progress overview: completion ring, key numbers, open tasks by priority, tasks by category.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<TaskProvider>().stats;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 72, title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: stats.completionRate),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => CustomPaint(
                        painter: _RingPainter(
                          value: v,
                          color: scheme.primary,
                          track: scheme.primary.withValues(alpha: 0.12),
                        ),
                        child: Center(
                          child: Text(
                            '${(v * 100).round()}%',
                            style: text.headlineSmall!
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Completion', style: text.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          stats.total == 0
                              ? 'Add a few tasks to see your progress.'
                              : '${stats.done} done, ${stats.active} to go.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _NumberTile(
                  label: 'Total',
                  value: stats.total,
                  icon: Icons.list_alt,
                  color: scheme.primary),
              const SizedBox(width: 12),
              _NumberTile(
                  label: 'Due today',
                  value: stats.dueToday,
                  icon: Icons.today,
                  color: scheme.tertiary),
              const SizedBox(width: 12),
              _NumberTile(
                  label: 'Overdue',
                  value: stats.overdue,
                  icon: Icons.warning_amber_rounded,
                  color: scheme.error),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Open tasks by priority',
            children: [
              for (final p in Priority.values.reversed)
                _Bar(
                  label: p.label,
                  value: stats.activeByPriority[p] ?? 0,
                  max: max(1, stats.active),
                  color: p.color,
                  icon: Icons.flag,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Tasks by category',
            children: [
              for (final c in TaskCategory.values)
                _Bar(
                  label: c.label,
                  value: stats.byCategory[c] ?? 0,
                  max: max(1, stats.total),
                  color: c.color,
                  icon: c.icon,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 10),
              Text('$value',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w800)),
              Text(label,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(
      {required this.label,
      required this.value,
      required this.max,
      required this.color,
      required this.icon});

  final String label;
  final int value;
  final int max;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          SizedBox(width: 72, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value / max,
                minHeight: 10,
                color: color,
                backgroundColor: color.withValues(alpha: 0.12),
              ),
            ),
          ),
          SizedBox(width: 32, child: Text('$value', textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(arcRect, 0, 2 * pi, false, base);
    if (value > 0) canvas.drawArc(arcRect, -pi / 2, 2 * pi * value, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
