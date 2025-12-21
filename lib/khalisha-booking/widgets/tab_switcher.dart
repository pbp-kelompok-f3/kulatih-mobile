import 'package:flutter/material.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/style/text.dart';

class TabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.navBarBg,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: AppColors.textPrimary.withOpacity(0.25),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            /// GOLD SLIDER
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: selectedIndex == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: (MediaQuery.of(context).size.width * 0.9 - 8) / 2,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
            ),

            /// TAB LABELS
            Row(
              children: [
                _tab("Upcoming", 0),
                _tab("History", 1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final bool selected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            label,
            style: heading(
              14,
              color: selected ? AppColors.buttonText : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
