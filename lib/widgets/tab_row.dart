import 'package:flutter/material.dart';

class TabRow extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;

  const TabRow({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: selectedIndex == index
                          ? Theme.of(context).primaryColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: selectedIndex == index ? 12 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selectedIndex == index
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Alternative 1: Modern Chip Style with Badge
class ModernTabRow extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;
  final List<int>? badgeCounts; // Optional badge counts

  const ModernTabRow({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.badgeCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          final hasBadge =
              badgeCounts != null &&
              badgeCounts!.length > index &&
              badgeCounts![index] > 0;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.4)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: isSelected ? 15 : 10,
                      offset: Offset(0, isSelected ? 5 : 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                    if (hasBadge) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.3)
                              : Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          '${badgeCounts![index]}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Alternative 2: Underline Style (Minimalist)
class UnderlineTabRow extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;

  const UnderlineTabRow({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: isSelected ? 16.0 : 15.0,
                    ),
                    child: Text(tabs[index]),
                  ),
                  const SizedBox(height: 8.0),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 3.0,
                    width: isSelected ? 30.0 : 0.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Alternative 3: Segmented Control Style (iOS-like)
class SegmentedTabRow extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;

  const SegmentedTabRow({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Example Usage Widget
class TabRowExamples extends StatefulWidget {
  const TabRowExamples({Key? key}) : super(key: key);

  @override
  State<TabRowExamples> createState() => _TabRowExamplesState();
}

class _TabRowExamplesState extends State<TabRowExamples> {
  int selectedIndex1 = 0;
  int selectedIndex2 = 0;
  int selectedIndex3 = 0;
  int selectedIndex4 = 0;

  final tabs = ['All', 'Main', 'Appetizer', 'Dessert'];
  final badgeCounts = [12, 8, 5, 3];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tab Row Examples'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enhanced Default',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TabRow(
              tabs: tabs,
              selectedIndex: selectedIndex1,
              onTap: (index) {
                setState(() {
                  selectedIndex1 = index;
                });
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Modern with Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ModernTabRow(
              tabs: tabs,
              selectedIndex: selectedIndex2,
              badgeCounts: badgeCounts,
              onTap: (index) {
                setState(() {
                  selectedIndex2 = index;
                });
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Underline Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            UnderlineTabRow(
              tabs: tabs,
              selectedIndex: selectedIndex3,
              onTap: (index) {
                setState(() {
                  selectedIndex3 = index;
                });
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Segmented Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: SegmentedTabRow(
                tabs: tabs,
                selectedIndex: selectedIndex4,
                onTap: (index) {
                  setState(() {
                    selectedIndex4 = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
