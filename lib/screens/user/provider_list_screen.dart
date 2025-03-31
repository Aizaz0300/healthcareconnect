import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/screens/user/provider_profile_screen.dart';

class ProviderListScreen extends StatelessWidget {
  final String serviceType;

  const ProviderListScreen({
    super.key,
    required this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceType),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _ProviderCard(
            name: 'Dr. John Doe',
            specialty: 'General Practitioner',
            rating: 4.5,
            experience: '10 years',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProviderProfileScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String experience;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      specialty,
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(rating.toString()),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.work,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(experience),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}