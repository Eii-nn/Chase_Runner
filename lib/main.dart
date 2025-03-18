import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/run_setup_screen.dart';
import 'screens/active_run_screen.dart';
import 'screens/run_summary_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/ai_coach_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/email_verification_screen.dart';
import 'providers/run_provider.dart';
import 'providers/settings_provider.dart';
import 'services/auth_service.dart';

void main() async {
  try {
    // Initialize logging
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // In development, you might want to see the logs in the console
      if (const bool.fromEnvironment('dart.vm.product')) {
        // In production, you might want to send logs to a logging service
        // For now, we'll just suppress the output
      } else {
        debugPrint('${record.level.name}: ${record.time}: ${record.message}');
      }
    });

    final log = Logger('Main');

    WidgetsFlutterBinding.ensureInitialized();
    log.info('Flutter binding initialized');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log.info('Firebase initialized successfully');

    runApp(const RunningApp());
    log.info('App started running');
  } catch (e, stackTrace) {
    final log = Logger('Main');
    log.severe('Error in initialization', e, stackTrace);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}

class RunningApp extends StatelessWidget {
  const RunningApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        primary: Colors.blue,
        secondary: Colors.orange,
        tertiary: Colors.green,
        brightness: brightness,
        surface:
            brightness == Brightness.light ? Colors.white : Colors.grey[900],
      ),
      fontFamily: 'Montserrat',
      useMaterial3: true,
      // Add consistent text styles
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
      ),
      // Add card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<AuthService, RunProvider>(
          create: (context) => RunProvider(
            userId: context.read<AuthService>().currentUser?.uid ?? '',
            settingsProvider: context.read<SettingsProvider>(),
          ),
          update: (context, auth, previousRunProvider) => RunProvider(
            userId: auth.currentUser?.uid ?? '',
            settingsProvider: context.read<SettingsProvider>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Chase Runner',
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/setup': (context) => const RunSetupScreen(),
          '/active_run': (context) => const ActiveRunScreen(),
          '/active': (context) => const ActiveRunScreen(),
          '/summary': (context) => const RunSummaryScreen(),
          '/history': (context) => const HistoryScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/ai_coach': (context) => const AiCoachScreen(),
          '/email-verification': (context) => const EmailVerificationScreen(),
        },
      ),
    );
  }
}
