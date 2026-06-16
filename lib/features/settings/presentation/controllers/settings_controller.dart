import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();

  final isDarkMode = false.obs;
  final isArabic = true.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read('isDarkMode') ?? false;
    isArabic.value = _box.read('isArabic') ?? true;
  }

  void toggleDarkMode() {
    isDarkMode.toggle();
    _box.write('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void toggleLanguage() {
    isArabic.toggle();
    _box.write('isArabic', isArabic.value);
    Get.updateLocale(
      isArabic.value ? const Locale('ar') : const Locale('en'),
    );
  }
}
