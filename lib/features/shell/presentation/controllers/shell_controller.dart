import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../tasks/presentation/views/tasks_page.dart';
import '../../../reports/presentation/views/reports_page.dart';
import '../../../settings/presentation/views/settings_page.dart';
import '../../../home/presentation/views/home_page.dart';

class ShellController extends GetxController {
  final currentIndex = 0.obs;

  final List<Widget> pages = [
    const HomePage(),
    const TasksPage(),
    const ReportsPage(),
    const SettingsPage(),
  ];

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
