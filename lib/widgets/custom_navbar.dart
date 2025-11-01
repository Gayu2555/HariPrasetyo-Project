import 'package:flutter/material.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({Key? key}) : super(key: key);

  @override
  CustomNavBarState createState() => CustomNavBarState();
}

class CustomNavBarState extends State<CustomNavBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    if (value == _selectedIndex) return;
    setState(() => _selectedIndex = value);
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (index) => GlobalKey<NavigatorState>(),
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) return;

    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.forward(from: 0.0);
    }
  }

  void _navigateToAddRecipe() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    Widget child;
    switch (index) {
      case 0:
        child = const HomeScreen();
        break;
      case 1:
        child = const CategoryScreen(categoryName: 'All'); // ✅ DIPERBAIKI
        break;
      case 3:
        child = const SavedScreen();
        break;
      case 4:
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
    final isFirstRouteInCurrentTab =
        !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
    if (isFirstRouteInCurrentTab) {
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddRecipe,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(UniconsLine.plus, color: Colors.white),
          elevation: 4.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        extendBody: true,
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              currentIndex:
                  _selectedIndex > 2 ? _selectedIndex + 1 : _selectedIndex,
              onTap: _onItemTapped,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 11.0,
              unselectedFontSize: 10.0,
              iconSize: 24.0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey[400],
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              items: [
                _buildNavItem(icon: UniconsLine.home, label: 'Home', index: 0),
                _buildNavItem(
                    icon: UniconsLine.apps, label: 'Category', index: 1),
                const BottomNavigationBarItem(
                    icon: SizedBox.shrink(), label: ''),
                _buildNavItem(
                    icon: UniconsLine.bookmark, label: 'Saved', index: 3),
                _buildNavItem(
                    icon: UniconsLine.user, label: 'Profile', index: 4),
              ],
            ),
          ),
        ),
        body: Stack(
          children: List.generate(5, (index) => _buildOffstageNavigator(index)),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(icon, size: isSelected ? 26.0 : 24.0),
      ),
      label: label,
    );
  }
}

class MinimalistNavBar extends StatefulWidget {
  const MinimalistNavBar({Key? key}) : super(key: key);

  @override
  MinimalistNavBarState createState() => MinimalistNavBarState();
}

class MinimalistNavBarState extends State<MinimalistNavBar> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (index) => GlobalKey<NavigatorState>(),
  );

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToAddRecipe() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    Widget child;
    switch (index) {
      case 0:
        child = const HomeScreen();
        break;
      case 1:
        child = const CategoryScreen(categoryName: 'All'); // ✅ DIPERBAIKI
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
    final isFirstRouteInCurrentTab =
        !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
    if (isFirstRouteInCurrentTab) {
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        extendBody: true,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(icon: UniconsLine.home, label: 'Home', index: 0),
              _buildNavItem(
                  icon: UniconsLine.apps, label: 'Category', index: 1),
              const SizedBox(width: 56),
              _buildNavItem(
                  icon: UniconsLine.bookmark, label: 'Saved', index: 2),
              _buildNavItem(icon: UniconsLine.user, label: 'Profile', index: 3),
            ],
          ),
        ),
        body: Stack(
          children: [
            ...List.generate(4, (index) => _buildOffstageNavigator(index)),
            Positioned(
              bottom: 90.0,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: _navigateToAddRecipe,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(UniconsLine.plus, color: Colors.white),
                  elevation: 4.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 3.0,
            width: isSelected ? 40.0 : 0.0,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Icon(
            icon,
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[400],
            size: 26.0,
          ),
          const SizedBox(height: 6.0),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 11.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomNavBarState extends CustomNavBarState {}
