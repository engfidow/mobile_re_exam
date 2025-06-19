import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';



import 'package:reexam/screens/home_screen.dart';
import 'package:reexam/screens/profile_screen.dart';
import 'package:reexam/screens/re_exam_list_screen.dart';
import 'package:reexam/screens/schedule_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final _iconList = <IconData>[
    IconlyLight.home,
    IconlyLight.bookmark,
    IconlyLight.calendar,
    IconlyLight.profile,
  ];

  final _labelList = ['Home', 'Re_Exans', 'Schedule', 'Profile'];

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReExamListScreen(),
    const Schedule(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? const Color(0xFFDC143C) : Colors.grey;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconList[index], color: color, size: 24),
              Text(
                _labelList[index],
                style: TextStyle(color: color),
              )
            ],
          );
        },
        backgroundColor: Colors.white,
        activeIndex: _selectedIndex,
        splashColor: Colors.purple[300],
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.none, // Removed FAB gap
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
