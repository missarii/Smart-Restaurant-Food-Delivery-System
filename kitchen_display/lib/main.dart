import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'screens/queue_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()..loginDemoUser(UserRole.kitchen)),
        ChangeNotifierProvider(create: (_) => SocketService()..connect()),
        ChangeNotifierProvider(create: (_) => TranslationService()),
      ],
      child: const KitchenDisplayApp(),
    ),
  );
}

class KitchenDisplayApp extends StatelessWidget {
  const KitchenDisplayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen display System',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const QueueScreen(),
    );
  }
}
