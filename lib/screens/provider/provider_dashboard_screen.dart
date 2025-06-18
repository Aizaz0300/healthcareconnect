import 'package:flutter/material.dart';
import 'package:healthcare/screens/provider/edit_provider_profile_screen.dart';
import 'package:healthcare/screens/provider/provider_reviews_screen.dart';
import 'package:healthcare/screens/user/ai_chat.dart';
import 'package:healthcare/services/appointment_service.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/providers/service_provider_provider.dart';
import 'package:healthcare/screens/provider/appointments_screen.dart';
import 'package:healthcare/screens/provider/manage_availability_screen.dart';
import '/constants/app_colors.dart';
import 'dart:math' as math;
import 'package:healthcare/screens/provider/provider_chat_list_screen.dart';
import '/widgets/action_card.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  String _upcomingAppointments = "0";
  String _completedAppointments = "0";
  int _upcomingPercentage = 0;
  int _completedPercentage = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointmentsData();
  }

  Future<void> _loadAppointmentsData() async {
    final AppointmentService appointmentService = AppointmentService();
    final provider =
        Provider.of<ServiceProviderProvider>(context, listen: false).provider;

    try {
      final results = await Future.wait([
        appointmentService.getProviderUpcomingAppointments(provider?.id ?? ''),
        appointmentService.getProviderCompletedAppointments(provider?.id ?? ''),
      ]);

      int upcoming = results[0].length;
      int completed = results[1].length;
      int total = upcoming + completed;

      setState(() {
        _upcomingAppointments = upcoming.toString();
        _completedAppointments = completed.toString();
        _upcomingPercentage =
            total > 0 ? ((upcoming / total) * 100).round() : 0;
        _completedPercentage =
            total > 0 ? ((completed / total) * 100).round() : 0;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 90.0,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Provider Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withBlue(150),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Transform.rotate(
                          angle: -math.pi / 6,
                          child: Icon(
                            Icons.medical_services_outlined,
                            size: 120,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                      onPressed: () {
                        // TODO: Navigate to notifications
                      },
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatisticsCards(),
                          const SizedBox(height: 24),
                          _buildQuickActions(context),
                          const SizedBox(height: 24),
                          _buildProviderTips()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildProfileHeader() {
    final providerData = Provider.of<ServiceProviderProvider>(context).provider;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: providerData?.imageUrl != null
                    ? NetworkImage(providerData!.imageUrl)
                    : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      providerData?.name ?? "",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            providerData?.rating.toStringAsFixed(1) ?? "0.0",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  providerData?.services.join(', ') ?? "No services",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildProfileStat(
                        '${providerData?.experience ?? 0}', 'Years Exp.'),
                    _buildProfileStat(
                        providerData?.services.length.toString() ?? "0",
                        'Services'),
                    _buildProfileStat(
                        providerData?.reviewCount.toString() ?? "0", 'Reviews'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            title: 'Appointments',
            subtitle: 'Upcoming',
            value: _isLoading ? '-' : _upcomingAppointments,
            icon: Icons.calendar_today,
            color: Colors.blue,
            bgColor: Colors.blue.withOpacity(0.1),
            percentage: _isLoading ? 0 : _upcomingPercentage,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatisticCard(
            title: 'Appointments',
            subtitle: 'Completed',
            value: _isLoading ? '-' : _completedAppointments,
            icon: Icons.medical_services,
            color: Colors.green,
            bgColor: Colors.green.withOpacity(0.1),
            percentage: _isLoading ? 0 : _completedPercentage,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required int percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - percentage,
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // First Row
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  icon: Icons.local_hospital,
                  title: 'Appointments',
                  subtitle: 'View appointments',
                  color: Colors.lightBlue.shade50,
                  iconColor: Colors.lightBlue.shade800,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AppointmentScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ActionCard(
                  icon: Icons.access_time,
                  title: 'Availability',
                  subtitle: 'Manage service slots',
                  color: Colors.indigo.shade50,
                  iconColor: Colors.indigo.shade700,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageAvailabilityScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Second Row
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  icon: Icons.message_outlined,
                  title: 'Chats',
                  subtitle: 'Conversations',
                  color: Colors.green.shade50,
                  iconColor: Colors.green.shade800,
                  onTap: () {
                    final providerData = Provider.of<ServiceProviderProvider>(
                            context,
                            listen: false)
                        .provider;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProviderChatListScreen(
                          providerId: providerData?.id ?? '',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ActionCard(
                  icon: Icons.rate_review_outlined,
                  title: 'Reviews',
                  subtitle: 'View feedback',
                  color: Colors.amber.shade50,
                  iconColor: Colors.amber.shade800,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProviderReviewsScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Third Row
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  icon: Icons.lightbulb_outline,
                  title: 'HealthChat AI',
                  subtitle: 'Smart Care',
                  color: Colors.teal.shade50,
                  iconColor: Colors.teal.shade800,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SmartCareConnect()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ActionCard(
                  icon: Icons.account_circle,
                  title: 'Settings',
                  subtitle: 'Customize Profile',
                  color: Colors.deepPurple.shade50,
                  iconColor: Colors.deepPurple.shade700,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProviderProfileScreen(
                        provider: Provider.of<ServiceProviderProvider>(
                          context,
                          listen: false,
                        ).provider!,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      top: false, // We only care about the bottom here
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', true),
              _buildNavItem(Icons.calendar_today_outlined, 'Appointments', false),
              _buildNavItem(Icons.message_outlined, 'Messages', false),
              _buildNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {
        if (label == 'Home') {
          Navigator.pushReplacementNamed(context, '/provider_dashboard');
        } else if (label == 'Appointments') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentScreen(),
            ),
          );
        } else if (label == 'Messages') {
          final providerData =
              Provider.of<ServiceProviderProvider>(context, listen: false)
                  .provider;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderChatListScreen(
                providerId: providerData?.id ?? '',
              ),
            ),
          );
        } else if (label == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProviderProfileScreen(
                  provider: Provider.of<ServiceProviderProvider>(context,
                          listen: false)
                      .provider!),
            ),
          );
        }
        // TODO: Handle other navigation items
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.primary : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Wellness Tips for You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildTipCard(
          icon: Icons.self_improvement,
          title: 'Take Short Breaks',
          subtitle:
              'Short mental breaks between appointments help reduce burnout.',
          gradientColors: [
            AppColors.primary.withOpacity(0.8),
            Colors.teal.shade700,
          ],
          iconColor: AppColors.primary,
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          icon: Icons.fitness_center,
          title: 'Stretch Often',
          subtitle:
              'Light stretching prevents stiffness during long service hours.',
          gradientColors: [
            AppColors.primary.withOpacity(0.8),
            const Color.fromARGB(255, 57, 87, 171),
          ],
          iconColor: Colors.deepPurple.shade700,
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
