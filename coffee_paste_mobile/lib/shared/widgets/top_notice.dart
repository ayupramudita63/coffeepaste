import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum TopNoticeType { success, error, info }

class TopNotice {
  TopNotice._();

  static OverlayEntry? _current;

  /// Lama pesan terlihat penuh, di luar animasi masuk dan keluar.
  static const Duration visibleFor = Duration(milliseconds: 3500);

  static void show(
    BuildContext context,
    String message, {
    TopNoticeType type = TopNoticeType.info,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopNoticeView(
        message: message,
        type: type,
        onDone: () {
          if (identical(_current, entry)) _current = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    final entry = _current;
    _current = null;
    if (entry != null && entry.mounted) entry.remove();
  }
}

class _TopNoticeView extends StatefulWidget {
  final String message;
  final TopNoticeType type;
  final VoidCallback onDone;

  const _TopNoticeView({
    required this.message,
    required this.type,
    required this.onDone,
  });

  @override
  State<_TopNoticeView> createState() => _TopNoticeViewState();
}

class _TopNoticeViewState extends State<_TopNoticeView>
    with SingleTickerProviderStateMixin {
  static const Duration _fade = Duration(milliseconds: 250);

  late final AnimationController _controller;
  late final double _fadeFraction;

  @override
  void initState() {
    super.initState();
    final total = TopNotice.visibleFor + _fade + _fade;
    _fadeFraction = _fade.inMilliseconds / total.inMilliseconds;
    // Tanpa Timer: seluruh masa tampil dijalankan oleh satu AnimationController.
    _controller = AnimationController(vsync: this, duration: total)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 0 -> 1 saat masuk, tetap 1 saat tampil, 1 -> 0 saat keluar.
  double _presence(double t) {
    if (t < _fadeFraction) return t / _fadeFraction;
    if (t > 1 - _fadeFraction) return (1 - t) / _fadeFraction;
    return 1;
  }

  Color get _color {
    switch (widget.type) {
      case TopNoticeType.success:
        return AppColors.primary;
      case TopNoticeType.error:
        return const Color(0xFFB3382C);
      case TopNoticeType.info:
        // Teks pesan selalu putih, jadi latarnya harus tetap gelap di kedua mode.
        return AppPalette.light.textPrimary;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case TopNoticeType.success:
        return Icons.check_circle_outline;
      case TopNoticeType.error:
        return Icons.error_outline;
      case TopNoticeType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 12,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final p = _presence(_controller.value).clamp(0.0, 1.0);
          return Opacity(
            opacity: p,
            child: Transform.translate(
              offset: Offset(0, -24 * (1 - p)),
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Semantics(
            liveRegion: true,
            child: GestureDetector(
              onTap: widget.onDone,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(_icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
