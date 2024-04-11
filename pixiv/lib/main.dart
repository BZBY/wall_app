import 'dart:io';
import 'package:flutter/material.dart';
import 'pages/app_settings.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/favorites_page.dart';
import 'pages/settings_page.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    HomePage(),
    SearchPage(),
    FavoritesPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // 使用 ColorScheme 替代直接设置 accentColor
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.amber[800],
        ),
      ),
      home: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '收藏'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800], // 依然可以直接设置
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
