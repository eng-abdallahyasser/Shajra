import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/themes/app_theme.dart';
import 'core/translations/messages.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';
import 'routes/app_pages.dart';

class ShajraApp extends StatelessWidget {
  const ShajraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return GetMaterialApp(
      title: 'app_title'.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode:
          settings.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      locale:
          settings.isArabic.value ? const Locale('ar') : const Locale('en'),
      translations: Messages(),
      fallbackLocale: const Locale('en'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('ar'),
      ],
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
    );
  }
}
