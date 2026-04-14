import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_service.dart';
import 'providers/auth_provider.dart';

// Écrans Auth (B)
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/task/task_detail_screen.dart';
// Écrans principaux (C) - Home avec navigation
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const KhadmliApp());
}

class KhadmliApp extends StatelessWidget {
  const KhadmliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Khadmli',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Ajoute ici ton AppTheme si tu l'as défini globalement
          useMaterial3: true,
        ),
        initialRoute: '/', // Démarre sur Splash
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const MainShell(),
          '/task-detail': (_) => const TaskDetailScreen(), // Nouveau
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
