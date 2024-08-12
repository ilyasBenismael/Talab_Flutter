import 'package:ecommerce/screens/tabs/home_tab.dart';
import 'package:ecommerce/screens/tabs/profile_tab.dart';
import 'package:ecommerce/screens/tabs/search_tab.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  final List<Widget> pages = [
    ProfilTab(),
    HomeTab(),
    SearchTab(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Current tab index
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: Colors.grey[850], // Dark-grey background color
        selectedItemColor: Colors.white, // Color of the selected item
        unselectedItemColor: Colors.grey[400], // Color of unselected items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
