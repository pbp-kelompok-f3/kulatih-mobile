import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';

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
        height: 52,
        width: MediaQuery.of(context).size.width * 0.88, // ⬅ biar nggak kepanjangan
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.indigoDark, // ⬅ warna container luar SAMA FIGMA
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            _tab("Upcoming", 0),
            _tab("Booking History", 1),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    bool selected = selectedIndex == index;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 4), // ⬅ kasih jarak biar bubble bagus
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: selected
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 2,
                ),
        ),
        child: GestureDetector(
          onTap: () => onTabSelected(index),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: selected ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
