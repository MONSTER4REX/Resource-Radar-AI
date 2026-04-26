import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_theme.dart';
import 'providers/signal_provider.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Explicitly check for Web to avoid getter issues in some environments
    final firebaseOptions = kIsWeb 
        ? DefaultFirebaseOptions.web 
        : DefaultFirebaseOptions.currentPlatform;

    await Firebase.initializeApp(options: firebaseOptions);
    print('Firebase initialized successfully on ${kIsWeb ? "Web" : "Native"}');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const ResourceRadarApp());
}

class ResourceRadarApp extends StatelessWidget {
  const ResourceRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignalProvider()),
      ],
      child: MaterialApp(
        title: 'ResourceRadar Field Agent',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
