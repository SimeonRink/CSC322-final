import 'package:egr423_starter_project/home_page.dart';
import 'package:egr423_starter_project/news_screen.dart';
import 'package:egr423_starter_project/search_screen.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static const routeName = '/main';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List pages = [
    HomePage(),
    SearchScreen(),
  ];

  int curIndex = 0;

  void onTap(int index) {
    setState(() {
      curIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 50, 50, 50),
      body: pages[curIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTap,
        unselectedFontSize: 0,
        selectedFontSize: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
        currentIndex: curIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Theme.of(context).colorScheme.background,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            label: 'home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Stocks',
            icon: Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }
}
