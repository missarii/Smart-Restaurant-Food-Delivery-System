import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()..loginDemoUser(UserRole.rider)),
        ChangeNotifierProvider(create: (_) => SocketService()..connect()),
        ChangeNotifierProvider(create: (_) => TranslationService()),
      ],
      child: const RiderApp(),
    ),
  );
}

class RiderApp extends StatelessWidget {
  const RiderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rider Portal',
      theme: AppTheme.darkTheme, // Premium dark theme by default
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
