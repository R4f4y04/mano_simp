import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/providers/editor_provider.dart';
import 'package:mano_simp/screens/simulation_screen.dart';
import 'package:mano_simp/screens/editor_screen.dart';
import 'package:mano_simp/config/theme_config.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SimulationProvider()),
        ChangeNotifierProvider(create: (context) => EditorProvider()),
      ],
      child: const ManoSimpApp(),
    ),
  );
}

class ManoSimpApp extends StatelessWidget {
  const ManoSimpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ThemeConfig.config['appName'],
      theme: ThemeData(
        primaryColor: ThemeConfig.getColorFromHex(
            ThemeConfig.config['theme']['primaryColor']),
        scaffoldBackgroundColor: ThemeConfig.getColorFromHex(
            ThemeConfig.config['theme']['backgroundColor']),
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          bodyMedium: GoogleFonts.getFont(
            'Roboto',
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SimulationScreen(),
    const EditorScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize simulation data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimulationProvider>().initRegisters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navConfig = ThemeConfig.config['layout']['navBar'];

    return Scaffold(
      appBar: AppBar(
        title: Text(ThemeConfig.config['appName']),
        backgroundColor: ThemeConfig.getColorFromHex(
            ThemeConfig.config['theme']['primaryColor']),
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: List.generate(
          navConfig['tabs'].length,
          (index) => BottomNavigationBarItem(
            icon: Icon(
              index == 0 ? Icons.memory : Icons.code,
              size: _selectedIndex == index
                  ? navConfig['activeIconSize'].toDouble()
                  : navConfig['inactiveIconSize'].toDouble(),
            ),
            label: navConfig['tabs'][index],
          ),
        ),
      ),
    );
  }
}
