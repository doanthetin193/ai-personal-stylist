import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Services
import 'services/firebase_service.dart';
import 'services/groq_service.dart';
import 'services/weather_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/wardrobe_provider.dart';

// Utils
import 'utils/theme.dart';
import 'utils/constants.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Thiết lập persistence cho Firebase Auth trước khi runApp
  // Điều này giúp giữ phiên đăng nhập giữa các lần reload/restart
  final firebaseService = FirebaseService();
  await firebaseService.ensurePersistence();

  runApp(MyApp(firebaseService: firebaseService));
}

class MyApp extends StatefulWidget {
  final FirebaseService firebaseService;

  const MyApp({super.key, required this.firebaseService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Services
  late final GroqService _groqService;
  late final WeatherService _weatherService;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  void _initServices() {
    _groqService = GroqService();
    _weatherService = WeatherService();

    // Initialize Groq with API key
    _groqService.initialize(AppConstants.groqApiKey);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services - cần Provider để các screen khác access được
        Provider<GroqService>.value(value: _groqService),
        Provider<WeatherService>.value(value: _weatherService),
        Provider<FirebaseService>.value(value: widget.firebaseService),
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(widget.firebaseService),
        ),
        // Wardrobe Provider
        ChangeNotifierProvider(
          create: (_) => WardrobeProvider(
            widget.firebaseService,
            _groqService,
            _weatherService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AI Personal Stylist',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget wrapper để handle authentication state changes
/// Sử dụng widget riêng để đảm bảo rebuild khi auth state thay đổi
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Show loading while checking auth state
        if (auth.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate based on auth state
        if (auth.isAuthenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
