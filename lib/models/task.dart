import 'package:flutter/material.dart';

/// How urgent a task is. Stored by [name] so the order of the enum can change safely.
enum Priority {
  low('Low', Color(0xFF43A047)),
  medium('Medium', Color(0xFFFB8C00)),
  high('High', Color(0xFFE53935));

  const Priority(this.label, this.color);
  final String label;
  final Color color;

  static Priority fromName(String? name) => Priority.values
      .firstWhere((p) => p.name == name, orElse: () => Priority.medium);
}

/// A fixed set of categories, each with its own icon and colour.
enum TaskCategory {
  personal('Personal', Icons.person_outline, Color(0xFF5C6BC0)),
  work('Work', Icons.work_outline, Color(0xFF00897B)),
  study('Study', Icons.school_outlined, Color(0xFF8E24AA)),
  health('Health', Icons.favorite_outline, Color(0xFFD81B60)),
  shopping('Shopping', Icons.shopping_bag_outlined, Color(0xFFF4511E));

  const TaskCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;

  static TaskCategory fromName(String? name) => TaskCategory.values
      .firstWhere((c) => c.name == name, orElse: () => TaskCategory.personal);
}

/// One to-do item. Immutable: changes go through [copyWith].
@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    this.note = '',
    this.done = false,
    this.priority = Priority.medium,
    this.category = TaskCategory.personal,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
    this.position = 0,
  });

  final String id;
  final String title;
  final String note;
  final bool done;
  final Priority priority;
  final TaskCategory category;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Manual order set by drag-and-drop (lower comes first).
  final int position;

  /// A task is overdue when it is not done and its due day is before today.
  bool isOverdueOn(DateTime now) {
    if (done || dueDate == null) return false;
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.isBefore(today);
  }

  bool isDueOn(DateTime day) =>
      dueDate != null &&
      dueDate!.year == day.year &&
      dueDate!.month == day.month &&
      dueDate!.day == day.day;

  Task copyWith({
    String? title,
    String? note,
    bool? done,
    Priority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    int? position,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      done: done ?? this.done,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'done': done,
        'priority': priority.name,
        'category': category.name,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'position': position,
      };

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    DateTime? date(Object? v) =>
        v == null ? null : DateTime.tryParse(v as String);
    return Task(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      note: map['note'] as String? ?? '',
      done: map['done'] as bool? ?? false,
      priority: Priority.fromName(map['priority'] as String?),
      category: TaskCategory.fromName(map['category'] as String?),
      dueDate: date(map['dueDate']),
      createdAt: date(map['createdAt']) ?? DateTime.now(),
      completedAt: date(map['completedAt']),
      position: map['position'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.title == title &&
      other.note == note &&
      other.done == done &&
      other.priority == priority &&
      other.category == category &&
      other.dueDate == dueDate &&
      other.createdAt == createdAt &&
      other.completedAt == completedAt &&
      other.position == position;

  @override
  int get hashCode => Object.hash(id, title, note, done, priority, category,
      dueDate, createdAt, completedAt, position);
}
