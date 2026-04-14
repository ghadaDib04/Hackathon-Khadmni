import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_service.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';

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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Khadmli',
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
        routes: {
          '/home': (_) => const Scaffold(body: Center(child: Text('Home — bientôt'))),
          '/register': (_) => const Scaffold(body: Center(child: Text('Register — bientôt'))),
        },
      ),
    );
  }
}