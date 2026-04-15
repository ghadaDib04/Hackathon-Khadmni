import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_service.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();

  final authProvider = AuthProvider();
  await authProvider.loadUserFromStorage();

  runApp(KhadmliApp(authProvider: authProvider));
}

class KhadmliApp extends StatelessWidget {
  final AuthProvider authProvider;
  const KhadmliApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authProvider)],
      child: MaterialApp(
        title: 'Khadmni',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const MainShell(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}