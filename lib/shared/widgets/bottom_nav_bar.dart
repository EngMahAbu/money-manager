import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onQuickAdd;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, TablerIcons.home, context),
            _buildNavItem(1, TablerIcons.list, context),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(2, TablerIcons.chart_pie, context),
            _buildNavItem(3, TablerIcons.settings, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, BuildContext context) {
    final isActive = currentIndex == index;
    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        size: 22,
        color: isActive ? AppColors.accent : AppColors.textMuted,
      ),
    );
  }
}

// In a real app, the Quick-Add FAB would be positioned separately in the Scaffold
class QuickAddFab extends StatelessWidget {
  final VoidCallback onPressed;

  const QuickAddFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(TablerIcons.plus, color: Colors.white, size: 24),
      ),
    );
  }
}
