import 'package:flutter/material.dart';
import 'presentation/views/home_view.dart';
void main() {
  runApp(const CasaDivisasApp());
}

class CasaDivisasApp extends StatelessWidget {
  const CasaDivisasApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casa de Divisas & IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0052FF),
          background: const Color(0xFFF8F9FA),
        ),
        fontFamily: 'Roboto', // Fuente estándar limpia
      ),
      home: const MainContainerScreen(),
    );
  }
}

// Contenedor principal con la barra de navegación inferior (BottomNavigationBar)
class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({Key? key}) : super(key: key);

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;

  // Lista temporal de pantallas principales (las iremos conectando una a una)
  final List<Widget> _screens = [
    const Center(child: Text("Pantalla Home (Dashboard)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    const Center(child: Text("Pantalla AI Advisor (IA)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    const Center(child: Text("Pantalla Analytics / About Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF0052FF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'AI Advisor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}