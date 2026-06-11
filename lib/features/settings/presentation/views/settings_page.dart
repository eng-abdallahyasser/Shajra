import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      title: Text('dark_mode'.tr),
                      subtitle: Text('dark_mode_desc'.tr),
                      value: controller.isDarkMode.value,
                      onChanged: (_) => controller.toggleDarkMode(),
                      secondary: Icon(
                        controller.isDarkMode.value
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Obx(
                    () => SwitchListTile(
                      title: Text('language'.tr),
                      subtitle: Obx(
                        () => Text(
                          controller.isArabic.value ? 'العربية' : 'English',
                        ),
                      ),
                      value: controller.isArabic.value,
                      onChanged: (_) => controller.toggleLanguage(),
                      secondary: const Icon(Icons.translate),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
