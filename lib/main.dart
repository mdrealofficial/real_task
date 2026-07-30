import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/navigation_provider.dart';
import 'services/alarm_service.dart';
import 'services/auth_service.dart';
import 'services/network_sync_service.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, NetworkSyncService>(
          create: (context) => NetworkSyncService(Provider.of<AuthService>(context, listen: false)),
          update: (context, authService, previous) => previous ?? NetworkSyncService(authService),
        ),
        ChangeNotifierProxyProvider<AuthService, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (context, authService, taskProvider) {
            final tp = taskProvider ?? TaskProvider();
            tp.updateAuthService(authService);
            return tp;
          },
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AlarmService()),
      ],
      child: Consumer2<NavigationProvider, AuthService>(
        builder: (context, navProvider, authService, child) {
          Widget homeScreen;

          if (authService.isLoading) {
            homeScreen = const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (authService.isLoggedIn) {
            homeScreen = const MainScreen();
          } else {
            homeScreen = const LoginScreen();
          }

          return MaterialApp(
            title: '',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: navProvider.themeMode,
            home: homeScreen,
          );
        },
      ),
    );
  }
}
