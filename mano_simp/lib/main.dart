import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/simulation_provider.dart';
import 'package:mano_simp/screens/simulation_screen.dart';
import 'package:mano_simp/config/theme_config.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SimulationProvider()),
      ],
      child: const ManoSimpApp(),
    ),
  );
}

class ManoSimpApp extends StatelessWidget {
  const ManoSimpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Minimal black and white color scheme
    final blackColor = Color(0xFF000000);
    final darkGrayColor = Color(0xFF333333);
    final mediumGrayColor = Color(0xFF666666);
    final lightGrayColor = Color(0xFFDDDDDD);
    final whiteColor = Color(0xFFFFFFFF);

    return MaterialApp(
      title: ThemeConfig.config['appName'],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: blackColor,
          secondary: darkGrayColor,
          background: whiteColor,
          onBackground: blackColor,
          surface: whiteColor,
          onSurface: blackColor,
        ),
        scaffoldBackgroundColor: whiteColor,
        appBarTheme: AppBarTheme(
          backgroundColor: blackColor,
          foregroundColor: whiteColor,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: blackColor,
            foregroundColor: whiteColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: blackColor,
            side: BorderSide(color: blackColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: blackColor,
          ),
        ),
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: const SimulationScreen(),
    );
  }
}
