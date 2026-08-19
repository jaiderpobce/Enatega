import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';

class FoodDeliveryApp extends StatefulWidget {
  const FoodDeliveryApp({super.key});

  @override
  State<FoodDeliveryApp> createState() => _FoodDeliveryAppState();
}

class _FoodDeliveryAppState extends State<FoodDeliveryApp> {
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    // AuthController was already initialized in `main`. Yield to the
    // event loop to ensure providers are mounted, then stop booting.
    await Future.microtask(() {});
    if (mounted) setState(() => _booting = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _booting
          ? const SplashScreen()
          : Consumer<AuthController>(
              builder: (context, auth, _) {
                if (auth.isAuthenticated) {
                  return const HomeScreen();
                }
                return const LoginScreen();
              },
            ),
    );
  }
}
