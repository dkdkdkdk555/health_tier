import 'package:flutter/material.dart';

class FloatingNavBarPage extends StatefulWidget {
  const FloatingNavBarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FloatingNavBarPageState createState() => _FloatingNavBarPageState();
}

class _FloatingNavBarPageState extends State<FloatingNavBarPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('홈')),
    const Center(child: Text('검색')),
    const Center(child: Text('설정')),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 바디 아래까지 확장해서 그림자 등 자연스럽게
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTap,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            elevation: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: '검색',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: '설정',
              ),
            ],
          ),
        ),
      ),
    );
  }
}