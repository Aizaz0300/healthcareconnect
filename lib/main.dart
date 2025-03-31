import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';
import '/theme/app_theme.dart';
import '/screens/role_selection_screen.dart';
import 'services/appwrite_auth_service.dart';
import 'providers/user_provider.dart';

void main() {
  final client = Client();
  final storage = Storage(client);
  final appwriteService = AppwriteService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider.value(value: appwriteService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare Connect',
      theme: AppTheme.light(),
      home: const RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
