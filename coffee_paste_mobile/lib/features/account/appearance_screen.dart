import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_accent.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_style.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/theme_provider.dart';

/// Pengaturan tampilan: mode (ikuti sistem / terang / gelap) dan warna tema.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  /// Label singkat mode, dipakai juga di menu Profil.
  static String labelOf(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      case ThemeMode.system:
        return 'Ikuti sistem';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppStyle.screenPadding,
            10,
            AppStyle.screenPadding,
            28,
          ),
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 36,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Profil',
                      style: AppTextStyles.sectionAction.copyWith(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tampilan',
              style: AppTextStyles.greetingTitle.copyWith(
                fontSize: 32,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Atur mode dan warna tema aplikasi sesukamu.',
              style: AppTextStyles.greetingSubtitle,
            ),
            const SizedBox(height: 24),

            const _SectionLabel('MODE'),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: AppStyle.card(),
              child: Column(
                children: [
                  _ModeRow(
                    key: const Key('theme-system'),
                    icon: Icons.brightness_auto_rounded,
                    title: 'Ikuti sistem',
                    subtitle: 'Sesuai pengaturan terang/gelap perangkat',
                    isSelected: theme.mode == ThemeMode.system,
                    onTap: () =>
                        context.read<ThemeProvider>().setMode(ThemeMode.system),
                  ),
                  AppStyle.hairline(indent: 58),
                  _ModeRow(
                    key: const Key('theme-light'),
                    icon: Icons.light_mode_rounded,
                    title: 'Terang',
                    subtitle: 'Selalu gunakan tampilan terang',
                    isSelected: theme.mode == ThemeMode.light,
                    onTap: () =>
                        context.read<ThemeProvider>().setMode(ThemeMode.light),
                  ),
                  AppStyle.hairline(indent: 58),
                  _ModeRow(
                    key: const Key('theme-dark'),
                    icon: Icons.dark_mode_rounded,
                    title: 'Gelap',
                    subtitle: 'Selalu gunakan tampilan gelap',
                    isSelected: theme.mode == ThemeMode.dark,
                    onTap: () =>
                        context.read<ThemeProvider>().setMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const _SectionLabel('WARNA TEMA'),
            Container(
              padding: const EdgeInsets.all(AppStyle.cardPadding),
              decoration: AppStyle.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.count(
                    key: const Key('accent-grid'),
                    crossAxisCount: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.72,
                    children: [
                      for (final option in AppAccent.presets)
                        _AccentSwatch(
                          key: Key('accent-${option.id}'),
                          label: option.name,
                          color: AppAccent.normalize(option.color),
                          isSelected: AppAccent.same(theme.accent, option.color),
                          onTap: () => context
                              .read<ThemeProvider>()
                              .setAccent(option.color),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppStyle.hairline(),
                  _CustomColorRow(
                    isSelected: !AppAccent.presets
                        .any((o) => AppAccent.same(theme.accent, o.color)),
                    color: theme.accent,
                    onTap: () => _openCustomPicker(context, theme.accent),
                  ),
                ],
              ),
            ),

            if (!AppAccent.isDefault(theme.accent)) ...[
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  key: const Key('accent-reset'),
                  onPressed: () => context.read<ThemeProvider>().resetAccent(),
                  child: const Text('Kembalikan warna bawaan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openCustomPicker(BuildContext context, Color current) async {
    final picked = await showModalBottomSheet<Color>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => _CustomColorSheet(initial: current),
    );
    if (picked != null && context.mounted) {
      await context.read<ThemeProvider>().setAccent(picked);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
      child: Text(
        text,
        style: AppTextStyles.ratingText.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.productName.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.ratingText.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 24,
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 22,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu bulatan warna di grid pilihan. Semua bulatan sama ukuran.
class _AccentSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccentSwatch({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.ratingText.copyWith(
              fontSize: 10.5,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomColorRow extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CustomColorRow({
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('accent-custom'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    for (var h = 0; h <= 360; h += 60)
                      HSLColor.fromAHSL(1, h.toDouble() % 360, 0.8, 0.5)
                          .toColor(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Warna sendiri',
                style: AppTextStyles.productName.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected) ...[
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Lembar pemilih warna sendiri: geser warna, kepekatan, dan kecerahan.
/// Warna baru baru dipakai setelah menekan "Terapkan".
class _CustomColorSheet extends StatefulWidget {
  final Color initial;

  const _CustomColorSheet({required this.initial});

  @override
  State<_CustomColorSheet> createState() => _CustomColorSheetState();
}

class _CustomColorSheetState extends State<_CustomColorSheet> {
  late double _hue;
  late double _saturation;
  late double _lightness;

  @override
  void initState() {
    super.initState();
    final hsl = HSLColor.fromColor(widget.initial);
    _hue = hsl.hue;
    _saturation = hsl.saturation.clamp(0.0, 1.0).toDouble();
    _lightness = hsl.lightness.clamp(0.22, 0.46).toDouble();
  }

  Color get _color => AppAccent.normalize(
        HSLColor.fromAHSL(1, _hue, _saturation, _lightness).toColor(),
      );

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppStyle.screenPadding,
          12,
          AppStyle.screenPadding,
          AppStyle.screenPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Warna sendiri',
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 16),
            Container(
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppStyle.cardRadius),
              ),
              child: const Text(
                'Pesan Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _GradientSlider(
              label: 'Warna',
              value: _hue,
              max: 360,
              colors: [
                for (var h = 0; h <= 360; h += 60)
                  HSLColor.fromAHSL(1, h.toDouble() % 360, 0.8, 0.5).toColor(),
              ],
              onChanged: (v) => setState(() => _hue = v),
            ),
            _GradientSlider(
              label: 'Kepekatan',
              value: _saturation,
              max: 1,
              colors: [
                HSLColor.fromAHSL(1, _hue, 0.05, _lightness).toColor(),
                HSLColor.fromAHSL(1, _hue, 1, _lightness).toColor(),
              ],
              onChanged: (v) => setState(() => _saturation = v),
            ),
            _GradientSlider(
              label: 'Kecerahan',
              value: _lightness,
              min: 0.22,
              max: 0.46,
              colors: [
                HSLColor.fromAHSL(1, _hue, _saturation, 0.22).toColor(),
                HSLColor.fromAHSL(1, _hue, _saturation, 0.46).toColor(),
              ],
              onChanged: (v) => setState(() => _lightness = v),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              key: const Key('accent-apply'),
              onPressed: () => Navigator.of(context).pop(color),
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final List<Color> colors;
  final ValueChanged<double> onChanged;

  const _GradientSlider({
    required this.label,
    required this.value,
    required this.colors,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.ratingText),
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(colors: colors),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                      elevation: 3,
                    ),
                  ),
                  child: Slider(
                    value: value.clamp(min, max).toDouble(),
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
