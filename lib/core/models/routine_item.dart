import 'package:flutter/cupertino.dart';

class RoutineItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String block; // "Morning", "Afternoon", "Evening"
  final String icon;
  final int targetMinutes;
  final int colorHex;
  final bool isArchived;
  final int orderIndex;
  final DateTime createdAt;

  const RoutineItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.block,
    required this.icon,
    required this.targetMinutes,
    required this.colorHex,
    this.isArchived = false,
    this.orderIndex = 0,
    required this.createdAt,
  });

  Color get color => Color(colorHex);

  IconData get iconData {
    switch (icon) {
      case 'drop_fill':
        return CupertinoIcons.drop_fill;
      case 'wind':
        return CupertinoIcons.wind;
      case 'sun_max_fill':
        return CupertinoIcons.sun_max_fill;
      case 'target':
        return CupertinoIcons.scope;
      case 'timer':
        return CupertinoIcons.timer;
      case 'figure_walk':
        return CupertinoIcons.play_arrow_solid;
      case 'leaf_arrow_circlepath':
        return CupertinoIcons.refresh_circled_solid;
      case 'flame_fill':
        return CupertinoIcons.flame_fill;
      case 'checkmark_seal_fill':
        return CupertinoIcons.checkmark_seal_fill;
      case 'moon_stars_fill':
        return CupertinoIcons.moon_stars_fill;
      case 'book_fill':
        return CupertinoIcons.book_fill;
      case 'bolt_fill':
        return CupertinoIcons.bolt_fill;
      case 'heart_fill':
        return CupertinoIcons.heart_fill;
      case 'star_fill':
        return CupertinoIcons.star_fill;
      default:
        return CupertinoIcons.circle_grid_hex_fill;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'block': block,
      'icon': icon,
      'target_minutes': targetMinutes,
      'color_hex': colorHex,
      'is_archived': isArchived ? 1 : 0,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RoutineItem.fromMap(Map<String, dynamic> map) {
    return RoutineItem(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: (map['subtitle'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Focus',
      block: (map['block'] as String?) ?? 'Morning',
      icon: (map['icon'] as String?) ?? 'star_fill',
      targetMinutes: (map['target_minutes'] as int?) ?? 10,
      colorHex: (map['color_hex'] as int?) ?? 0xFF4F46E5,
      isArchived: (map['is_archived'] as int?) == 1,
      orderIndex: (map['order_index'] as int?) ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  RoutineItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    String? block,
    String? icon,
    int? targetMinutes,
    int? colorHex,
    bool? isArchived,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return RoutineItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      block: block ?? this.block,
      icon: icon ?? this.icon,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      colorHex: colorHex ?? this.colorHex,
      isArchived: isArchived ?? this.isArchived,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
