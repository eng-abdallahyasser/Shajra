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
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        border: Border(
          top: BorderSide(color: Color(0xFFBFCABA), width: 2),
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
            label: 'Home',
            onTap: onTap,
          ),
          const SizedBox(width: 13.3),
          _NavItem(
            index: 1,
            currentIndex: currentIndex,
            icon: Icons.checklist_outlined,
            activeIcon: Icons.checklist,
            label: 'Tasks',
            onTap: onTap,
          ),
          const SizedBox(width: 13.3),
          _NavItem(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
            label: 'Reports',
            onTap: onTap,
          ),
          const SizedBox(width: 13.3),
          _NavItem(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
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
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2E7D32) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? const Color(0xFFCBFFC2) : const Color(0xFF5F5E5E),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.5,
                  color: isActive ? const Color(0xFFCBFFC2) : const Color(0xFF5F5E5E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
