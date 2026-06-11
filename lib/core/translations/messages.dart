import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'app_title': 'Shajra',
          'settings': 'Settings',
          'dark_mode': 'Dark Mode',
          'dark_mode_desc': 'Switch between light and dark theme',
          'language': 'Arabic Language',
          'language_desc': 'Toggle between English and Arabic',
        },
        'ar': {
          'app_title': 'شجرة',
          'settings': 'الإعدادات',
          'dark_mode': 'الوضع الليلي',
          'dark_mode_desc': 'التبديل بين السمة الفاتحة والداكنة',
          'language': 'اللغة العربية',
          'language_desc': 'التبديل بين الإنجليزية والعربية',
        },
      };
}
