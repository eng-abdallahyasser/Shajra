import 'package:flutter/material.dart';

/// A single observation category (e.g., Irrigation, Insects, etc.).
class ObservationCategory {
  /// Unique key: 'irrigation', 'insects', 'pruning', 'nutrition', 'fungal'.
  final String key;

  /// Arabic label displayed in the UI.
  final String labelAr;

  /// English label (fallback).
  final String labelEn;

  /// Material icon for the category.
  final IconData icon;

  /// Available problems to select from.
  final List<String> problems;

  /// Available corrective actions to select from.
  final List<String> correctiveActions;

  /// Whether a photo is required/recommended for this category.
  final bool requiresPhoto;

  const ObservationCategory({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.icon,
    required this.problems,
    required this.correctiveActions,
    this.requiresPhoto = false,
  });
}

/// Static registry of all tree observation categories.
///
/// Contains problems and corrective actions for both mango and blueberry trees
/// (and serves as a unified set for all tree types per the user's choice).
class TreeObservationData {
  TreeObservationData._();

  /// All 5 categories.
  static List<ObservationCategory> get all => [
        irrigation,
        insects,
        pruning,
        nutrition,
        fungal,
      ];

  /// Find a category by its key.
  static ObservationCategory? byKey(String key) {
    try {
      return all.firstWhere((c) => c.key == key);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────
  //  1. الري (Irrigation)
  // ────────────────────────────────────────────────────────
  static const irrigation = ObservationCategory(
    key: 'irrigation',
    labelAr: 'الري',
    labelEn: 'Irrigation',
    icon: Icons.water_drop,
    problems: [
      'ملوحة في المياه / التربة (Salinity)',
      'نقص كمية المياه (Water shortage)',
      'زيادة كمية المياه / غمر (Over-irrigation)',
      'انسداد خطوط التنقيط (Clogged drip lines)',
      'عدم انتظام الري / جدول خاطئ',
      'مشكلة في مصدر المياه',
    ],
    correctiveActions: [
      'محلول معالجة الملوحة / غسيل التربة',
      'زيادة كمية الري أو تعديل الجدول',
      'تقليل الكمية + تحسين الصرف',
      'تنظيف الخطوط والفلاتر',
      'إعادة ضبط جدول الري',
      'فحص وتعديل مصدر المياه',
    ],
  );

  // ────────────────────────────────────────────────────────
  //  2. الإصابات الحشرية (Insect Infestations)
  // ────────────────────────────────────────────────────────
  static const insects = ObservationCategory(
    key: 'insects',
    labelAr: 'الإصابات الحشرية',
    labelEn: 'Insect Infestations',
    icon: Icons.bug_report,
    problems: [
      'تربس (Thrips)',
      'ذبابة الفاكهة (Fruit fly)',
      'الحشرات القشرية (Scale insects)',
      'العنكبوت الأحمر (Red spider mite)',
      'نمل أو حشرات أخرى',
    ],
    correctiveActions: [
      'رش مبيد مناسب حسب نوع الإصابة',
      'إزالة يدوية للأجزاء المصابة',
      'تركيب فخاخ',
      'استخدام مكافحة بيولوجية',
    ],
  );

  // ────────────────────────────────────────────────────────
  //  3. التربية (التقليم) (Training & Pruning)
  // ────────────────────────────────────────────────────────
  static const pruning = ObservationCategory(
    key: 'pruning',
    labelAr: 'التربية (التقليم)',
    labelEn: 'Training & Pruning',
    icon: Icons.content_cut,
    problems: [
      'نمو زائد وكثيف (Excessive growth)',
      'فروع ميتة أو جافة (Dead/dry branches)',
      'شكل الشجرة غير متوازن',
      'فروع متشابكة',
      'حاجة لتقليم هيكلي أو خفيف',
    ],
    correctiveActions: [
      'تقليم هيكلي',
      'تقليم خفيف (تنظيف)',
      'ربط وتوجيه الفروع',
      'إزالة الفروع الميتة',
    ],
  );

  // ────────────────────────────────────────────────────────
  //  4. حالة الشجرة الغذائية (Nutritional Status)
  // ────────────────────────────────────────────────────────
  static const nutrition = ObservationCategory(
    key: 'nutrition',
    labelAr: 'حالة الشجرة الغذائية',
    labelEn: 'Nutritional Status',
    icon: Icons.eco,
    problems: [
      'نقص حديد (Iron deficiency)',
      'نقص نيتروجين',
      'نقص بوتاسيوم',
      'نقص فوسفور',
      'أعراض سوء تغذية عامة',
    ],
    correctiveActions: [
      'تسميد ورقي بمحلول محدد',
      'تسميد أرضي',
      'تعديل برنامج التسميد',
      'محلول معالجة نقص عنصر معين',
    ],
  );

  // ────────────────────────────────────────────────────────
  //  5. الأعفان (Fungal & Mold Issues)
  // ────────────────────────────────────────────────────────
  static const fungal = ObservationCategory(
    key: 'fungal',
    labelAr: 'الأعفان',
    labelEn: 'Fungal & Mold Issues',
    icon: Icons.yard,
    problems: [
      'عفن أسود (Sooty Mold)',
      'عفن الجذور (Root rot)',
      'بياض دقيقي (Powdery Mildew)',
      'عفن الثمار',
      'أمراض فطرية أخرى',
    ],
    correctiveActions: [
      'رش مبيد فطري مناسب',
      'إزالة الأجزاء المصابة يدوياً',
      'تحسين التهوية والصرف',
      'تعديل مستوى الرطوبة',
    ],
    requiresPhoto: true,
  );
}
