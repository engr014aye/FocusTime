import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/models/routine_item.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'bouncing_button.dart';

class AddRoutineSheet extends StatefulWidget {
  final ValueChanged<RoutineItem> onSave;

  const AddRoutineSheet({super.key, required this.onSave});

  @override
  State<AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends State<AddRoutineSheet> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();

  String _selectedBlock = 'Morning';
  String _selectedCategory = 'Deep Work';
  int _targetMinutes = 15;
  String _selectedIcon = 'star_fill';
  int _selectedColorHex = 0xFF4F46E5;

  final List<String> _categories = [
    'Deep Work',
    'Health & Vitality',
    'Mindset',
    'Creative Flow',
    'Vitality',
  ];

  final List<Map<String, dynamic>> _icons = [
    {'name': 'star_fill', 'icon': CupertinoIcons.star_fill},
    {'name': 'flame_fill', 'icon': CupertinoIcons.flame_fill},
    {'name': 'bolt_fill', 'icon': CupertinoIcons.bolt_fill},
    {'name': 'drop_fill', 'icon': CupertinoIcons.drop_fill},
    {'name': 'wind', 'icon': CupertinoIcons.wind},
    {'name': 'book_fill', 'icon': CupertinoIcons.book_fill},
    {'name': 'timer', 'icon': CupertinoIcons.timer},
    {'name': 'moon_stars_fill', 'icon': CupertinoIcons.moon_stars_fill},
  ];

  final List<int> _colors = [
    0xFF4F46E5, // Indigo
    0xFF0284C7, // Cyan
    0xFF0D9488, // Teal
    0xFF059669, // Emerald
    0xFFD97706, // Amber
    0xFFEC4899, // Pink
    0xFF8B5CF6, // Violet
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      HapticService.instance.medium();
      return;
    }

    HapticService.instance.success();
    final now = DateTime.now();
    final routine = RoutineItem(
      id: 'custom_${now.millisecondsSinceEpoch}',
      title: title,
      subtitle: _subtitleController.text.trim(),
      category: _selectedCategory,
      block: _selectedBlock,
      icon: _selectedIcon,
      targetMinutes: _targetMinutes,
      colorHex: _selectedColorHex,
      isArchived: false,
      createdAt: now,
    );

    widget.onSave(routine);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + keyboardHeight),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'New Micro-Habit or Routine',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 18),

              // Title Field
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'Routine Title (e.g. 15-Min Focused Reading)',
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                placeholderStyle: TextStyle(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle Field
              CupertinoTextField(
                controller: _subtitleController,
                placeholder: 'Purpose / Micro-cue (e.g. Expand mental models)',
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                placeholderStyle: TextStyle(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 18),

              // Time Block Segmented Control
              Text(
                'TIME OF DAY BLOCK',
                style: AppTypography.overline.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<String>(
                  groupValue: _selectedBlock,
                  backgroundColor:
                      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  thumbColor:
                      isDark ? const Color(0xFF334155) : Colors.white,
                  children: {
                    'Morning': Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Morning',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    'Afternoon': Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Afternoon',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    'Evening': Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Evening',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (val) {
                    if (val != null) {
                      HapticService.instance.selection();
                      setState(() => _selectedBlock = val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Target Duration Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TARGET DURATION',
                    style: AppTypography.overline.copyWith(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                  Text(
                    '$_targetMinutes Minutes',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              CupertinoSlider(
                value: _targetMinutes.toDouble(),
                min: 2,
                max: 90,
                divisions: 88,
                activeColor: Color(_selectedColorHex),
                onChanged: (val) {
                  setState(() => _targetMinutes = val.round());
                },
              ),
              const SizedBox(height: 14),

              // Category Selector Pills
              Text(
                'CATEGORY',
                style: AppTypography.overline.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: BouncingButton(
                        onTap: () {
                          HapticService.instance.selection();
                          setState(() => _selectedCategory = cat);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel
                                ? Color(_selectedColorHex)
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSel
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Icon Selector
              Text(
                'ROUTINE ICON',
                style: AppTypography.overline.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _icons.map((item) {
                    final name = item['name'] as String;
                    final icon = item['icon'] as IconData;
                    final isSel = _selectedIcon == name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: BouncingButton(
                        onTap: () {
                          HapticService.instance.selection();
                          setState(() => _selectedIcon = name);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSel
                                ? Color(_selectedColorHex)
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9)),
                            border: Border.all(
                              color: isSel
                                  ? Color(_selectedColorHex)
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: isSel
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Color Palette Picker
              Text(
                'ACCENT COLOR',
                style: AppTypography.overline.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _colors.map((hex) {
                  final isSel = _selectedColorHex == hex;
                  return BouncingButton(
                    onTap: () {
                      HapticService.instance.selection();
                      setState(() => _selectedColorHex = hex);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(hex),
                        border: isSel
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: Color(hex).withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: isSel
                          ? const Center(
                              child: Icon(
                                CupertinoIcons.checkmark,
                                color: Colors.white,
                                size: 18,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Save Action Button
              BouncingButton(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(_selectedColorHex),
                        Color(_selectedColorHex).withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Color(_selectedColorHex).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Save Routine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
