import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/theme/app_theme.dart';
import '/screens/role_selection_screen.dart';
import 'services/appwrite_service.dart';
import 'providers/user_provider.dart';
import 'providers/service_provider_provider.dart';

void main() {
  final appwriteService = AppwriteService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider.value(value: appwriteService),
        ChangeNotifierProvider(create: (_) => ServiceProviderProvider()),
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
