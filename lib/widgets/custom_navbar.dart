import 'package:flutter/material.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({Key? key}) : super(key: key);

  @override
  CustomNavBarState createState() => CustomNavBarState();
}

// NOTE: make the State class public so it can be referenced in a safe way.
class CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0;

  // Backwards-compatibility: expose the old public getter name `selectedIndex`.
  // Some tools or hot-reload state may try to read `selectedIndex` on the
  // state object (formerly named `_CustomNavBarState`). Providing this
  // accessor prevents "Lookup failed: selectedIndex" errors.
  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    if (value == _selectedIndex) return;
    setState(() => _selectedIndex = value);
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (index) => GlobalKey<NavigatorState>(),
  );

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      // If tapping the active tab, pop to first route
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(int index) {
    Widget child;
    switch (index) {
      case 0:
        child = const HomeScreen();
        break;
      case 1:
        child = const CategoryScreen();
        break;
      case 2:
        child = const SavedScreen();
        break;
      case 3:
        child = const ProfileScreen();
        break;
      default:
        child = const HomeScreen();
    }

    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (_) => child);
        },
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab = !await _navigatorKeys[_selectedIndex]
        .currentState!
        .maybePop();
    if (isFirstRouteInCurrentTab) {
      // If not on the 'home' tab, go to it.
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
        return false;
      }
    }
    // Let system handle back button if we're on the first route of home tab
    return isFirstRouteInCurrentTab;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 4.0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          selectedFontSize: 10.0.sp,
          iconSize: 18.sp,
          showUnselectedLabels: true,
          selectedItemColor: Theme.of(context).iconTheme.color,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(UniconsLine.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(UniconsLine.apps),
              label: 'Category',
            ),
            BottomNavigationBarItem(
              icon: Icon(UniconsLine.bookmark),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(UniconsLine.user),
              label: 'Profile',
            ),
          ],
        ),
        body: Stack(
          children: List.generate(4, (index) => _buildOffstageNavigator(index)),
        ),
      ),
    );
  }
}

class _CustomNavBarState extends CustomNavBarState {}
