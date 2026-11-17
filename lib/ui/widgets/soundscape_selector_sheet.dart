import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'bouncing_button.dart';

class SoundscapeSelectorSheet extends StatefulWidget {
  final AmbientSound? selectedSound;
  final ValueChanged<AmbientSound?> onSelect;

  const SoundscapeSelectorSheet({
    super.key,
    required this.selectedSound,
    required this.onSelect,
  });

  @override
  State<SoundscapeSelectorSheet> createState() => _SoundscapeSelectorSheetState();
}

class _SoundscapeSelectorSheetState extends State<SoundscapeSelectorSheet> {
  late AmbientSound? _current;
  late double _volume;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedSound ?? AudioService.instance.availableSounds.first;
    _volume = AudioService.instance.ambientVolume;
    _isPlaying = AudioService.instance.isPlayingAmbient;
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'drop_fill':
        return CupertinoIcons.drop_fill;
      case 'leaf_arrow_circlepath':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'wind':
        return CupertinoIcons.wind;
      case 'bolt_fill':
        return CupertinoIcons.bolt_fill;
      case 'moon_stars_fill':
        return CupertinoIcons.moon_stars_fill;
      default:
        return CupertinoIcons.music_note_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
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
            const SizedBox(height: 18),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ambient Soundscapes',
                      style: AppTypography.titleLarge.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'High-fidelity acoustic loops for flow state',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                BouncingButton(
                  onTap: () async {
                    HapticService.instance.medium();
                    if (_isPlaying) {
                      await AudioService.instance.stopAmbient();
                      setState(() => _isPlaying = false);
                    } else if (_current != null) {
                      await AudioService.instance.playAmbient(_current!);
                      setState(() => _isPlaying = true);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPlaying
                          ? const Color(0xFF0284C7)
                          : (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9)),
                    ),
                    child: Icon(
                      _isPlaying
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                      color: _isPlaying ? Colors.white : const Color(0xFF0284C7),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Volume Slider Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.volume_down,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  Expanded(
                    child: CupertinoSlider(
                      value: _volume,
                      activeColor: const Color(0xFF0284C7),
                      onChanged: (val) {
                        setState(() => _volume = val);
                        AudioService.instance.setVolume(val);
                      },
                    ),
                  ),
                  Icon(
                    CupertinoIcons.volume_up,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Soundscape list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AudioService.instance.availableSounds.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sound = AudioService.instance.availableSounds[index];
                final isSelected = _current?.id == sound.id;

                return BouncingButton(
                  onTap: () {
                    HapticService.instance.selection();
                    setState(() {
                      _current = sound;
                    });
                    widget.onSelect(sound);
                    if (_isPlaying) {
                      AudioService.instance.playAmbient(sound);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? const Color(0x330284C7)
                              : const Color(0x1A0284C7))
                          : (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0)),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF0284C7)
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0)),
                          ),
                          child: Icon(
                            _getIconData(sound.icon),
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sound.name,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sound.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: Color(0xFF0284C7),
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
