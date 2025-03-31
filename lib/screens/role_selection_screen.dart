import 'package:flutter/material.dart';
import 'package:healthcare/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '/screens/auth/user/user_login_screen.dart';
import '/screens/auth/provider/provider_login_screen.dart';
import '/screens/auth/admin/admin_login_screen.dart';
import '/screens/user/home_screen.dart';
import '/services/appwrite_auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FBFF), Color(0xFFEDF5FF)
              //,  // Very light blue-white
              //,  // Light blue tint
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Container(
                    height: 150,
                    width: 275,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.36),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),


                Center(
                  child: Text(
                    'Please select your role to continue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF536B7E),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _RoleCard(
                        title: 'Patient',
                        description: 'Find and book healthcare services',
                        icon: Icons.person_outlined,
                        color: const Color(0xFF3F77BC),  // Professional blue
                        onTap: () => _navigateToLogin(context, 'user'),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        title: 'Healthcare Provider',
                        description: 'Offer your medical services',
                        icon: Icons.medical_services_outlined,
                        color: const Color(0xFF2D8B85),  // Teal
                        onTap: () => _navigateToLogin(context, 'provider'),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        title: 'Administrator',
                        description: 'Manage the healthcare platform',
                        icon: Icons.admin_panel_settings_outlined,
                        color: const Color(0xFF526880),  // Slate
                        onTap: () => _navigateToLogin(context, 'admin'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, String role) async {
    if (role == 'user') {
      // Check for active session
      final appwriteService = AppwriteService();
      final isLoggedIn = await appwriteService.isLoggedIn();

      if (!context.mounted) return;

      if (isLoggedIn) {
        // Get user data and update provider
        final userData = await appwriteService.getCurrentUser(context);
        if (userData != null && context.mounted) {
          Provider.of<UserProvider>(context, listen: false)
              .setUserData(userData);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          return;
        }
      }

      // If not logged in or failed to get user data, show login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserLoginScreen()),
      );
      return;
    }

    // Handle other roles
    Widget loginScreen;
    switch (role) {
      case 'admin':
        loginScreen = const AdminLoginScreen();
        break;
      case 'provider':
        loginScreen = const ProviderLoginScreen();
        break;
      default:
        loginScreen = const UserLoginScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => loginScreen),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),

        ),
        color: Colors.white,

        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(

                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: const Color(0xFF2D3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF6B7C8B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}