import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shell_controller.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShellController>();

    return Obx(
      () => Scaffold(
        body: controller.pages[controller.currentIndex.value],
        bottomNavigationBar: _ShajraBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}

class _ShajraBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ShajraBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 2),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6.63),
          _NavItem(
            index: 0,
            currentIndex: currentIndex,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'nav_home'.tr,
            onTap: onTap,
          ),
          const SizedBox(width: 13.3),
          _NavItem(
            index: 1,
            currentIndex: currentIndex,
            icon: Icons.checklist_outlined,
            activeIcon: Icons.checklist,
            label: 'nav_tasks'.tr,
            onTap: onTap,
          ),
          const SizedBox(width: 13.3),
          _NavItem(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
            label: 'nav_reports'.tr,
            onTap: onTap,
          ),
          const SizedBox(width: 13.3),
          _NavItem(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'settings'.tr,
            onTap: onTap,
          ),
          const SizedBox(width: 6.64),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  bool get isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.5,
                  color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
