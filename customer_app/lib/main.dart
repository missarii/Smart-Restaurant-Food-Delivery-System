import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()..loginDemoUser(UserRole.customer)),
        ChangeNotifierProvider(create: (_) => SocketService()..connect()),
        ChangeNotifierProvider(create: (_) => TranslationService()),
      ],
      child: const CustomerApp(),
    ),
  );
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translation = Provider.of<TranslationService>(context);
    return MaterialApp(
      title: translation.translate('app_title'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Defaulting to dark theme for maximum premium visual impact
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
