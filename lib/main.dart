import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/user/user_dashboard_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_admin_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/pasien_provider.dart';
import 'providers/paket_mcu_provider.dart';
import 'providers/pendaftaran_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);

    // Setup logging
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });

    final logger = Logger('main');

    // Load .env file
    await dotenv.load(fileName: ".env");

    // Validate environment variables
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Missing Supabase configuration');
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    runApp(const MyApp());
  } catch (e) {
    Logger('main').severe('Error initializing app: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, AuthProvider>(
          create: (_) => AuthProvider(),
          update: (_, userProvider, authProvider) =>
              authProvider!..initialize(userProvider),
        ),
        ChangeNotifierProvider(create: (_) => PasienProvider()),
        ChangeNotifierProvider(create: (_) => PaketMCUProvider()),
        ChangeNotifierProvider(create: (_) => PendaftaranProvider()),
      ],
      child: MaterialApp(
        title: 'MedCheck Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF40E0D0),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF40E0D0),
            primary: const Color(0xFF40E0D0),
          ),
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF40E0D0)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF40E0D0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/register-admin': (context) => const RegisterAdminScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
          '/user': (context) => const UserDashboardScreen(),
        },
      ),
    );
  }
}
