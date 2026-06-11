import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shajra/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      Get.offAllNamed(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111211) : const Color(0xFFF9F9F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/app logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 28),
            // English app name
            Text(
              'Shajra',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.primary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            // Arabic app name
            Text(
              'شجرة',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.onSurface.withValues(alpha: 0.7),
                height: 1.1,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
