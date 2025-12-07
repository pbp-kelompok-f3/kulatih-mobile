import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0x111024),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            index: 0,
            icon: Icons.star_border,
            label: "Coach",
            activeColor: const Color(0xFFF1C448), // BIAR KUNING SAAT AKTIF
          ),
          _navItem(
            index: 1,
            icon: Icons.emoji_events_outlined,
            label: "Tournament",
            activeColor: const Color(0xFFF1C448),
          ),
          _navItem(
            index: 2,
            icon: Icons.calendar_month_outlined,
            label: "Bookings",
            activeColor: const Color(0xFFF1C448),
          ),
          _navItem(
            index: 3,
            icon: Icons.chat_bubble_outline,
            label: "Forum",
            activeColor: const Color(0xFFF1C448),
          ),
          _navItem(
            index: 4,
            icon: Icons.group_outlined,
            label: "Community",
            activeColor: const Color(0xFFF1C448),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
    Color activeColor = Colors.white,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: isActive ? activeColor : Colors.white,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : Colors.white,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
