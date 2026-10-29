import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoOffset;

  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineOffset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Logo: fade-in sambil geser naik tipis
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _logoOffset = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Teks (nama brand + tagline): muncul sedikit belakangan, overlap dengan logo
    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    );
    _taglineOffset = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _continueAfterSplash();
  }

  /// Tunggu animasi selesai dan sesi tersimpan selesai dipulihkan,
  /// lalu masuk ke Home (sudah login) atau Login.
  Future<void> _continueAfterSplash() async {
    final auth = context.read<AuthProvider>();

    await Future.wait<void>([
      Future<void>.delayed(const Duration(milliseconds: 2400)),
      auth.restoreSession(),
    ]);
    if (!mounted) return;

    context.go(auth.isAuthenticated ? AppRoutes.home : AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _logoOffset,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.local_cafe,
                    size: 90,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _taglineOffset,
              child: FadeTransition(
                opacity: _taglineOpacity,
                child: Column(
                  children: [
                    const Text(
                      'Coffee Paste',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'GOOD COFFEE, BETTER DAYS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}