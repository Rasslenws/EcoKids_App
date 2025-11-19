import 'package:flutter/material.dart';

class EcoBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const EcoBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: onChanged,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFFA726),  // orange
      unselectedItemColor: const Color(0xFFBDBDBD),
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_rounded),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz_outlined),
          label: 'Quizzes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
