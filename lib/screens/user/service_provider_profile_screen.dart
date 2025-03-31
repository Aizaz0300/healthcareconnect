import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '/constants/app_colors.dart';
import '/models/service_provider.dart';
import '/models/review.dart';
import '/widgets/gallery_dialog.dart';
import '/widgets/rating_bar.dart';
import '/widgets/review_card.dart';
import '/widgets/reviews_sheet.dart';
import '/screens/chat/chat_screen.dart';
import 'appointment_booking_screen.dart';

class ServiceProviderProfileScreen extends StatelessWidget {
  final ServiceProvider provider;
  // Sample reviews - in production, this would come from a service
  final List<Review> reviews = [
    Review(
      id: '1',
      userName: 'John Doe',
      userImage: 'https://example.com/user1.jpg',
      rating: 5.0,
      comment: 'Excellent service, very professional.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: '2',
      userName: 'Jane Smith',
      userImage: 'https://example.com/user2.jpg',
      rating: 4.5,
      comment: 'Great experience, would recommend.',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    // Add more sample reviews as needed
  ];

  ServiceProviderProfileScreen({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderInfo(),
                if (provider.gallery.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildGallery(),
                ],
                const SizedBox(height: 24),
                _buildServicesSection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
                const SizedBox(height: 24),
                _buildExperienceSection(),
                const SizedBox(height: 24),
                _buildCredentials(),
                const SizedBox(height: 24),
                _buildLicenseSection(),
                const SizedBox(height: 24),
                _buildAvailabilitySection(),
                const SizedBox(height: 24),
                _buildSocialLinks(),
                const SizedBox(height: 24),
                _buildReviewsSection(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButtons(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 40,
      pinned: true,
      backgroundColor: AppColors.background,


    );
  }

  Widget _buildProviderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  image: provider.imageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(provider.imageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: provider.imageUrl.isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.primary,
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.specialization,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          provider.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' (${provider.reviewCount} reviews)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBar(),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoBarItem(
            Icons.work_outline,
            '${provider.experience} exp',
            AppColors.primary,
          ),
          _buildVerticalDivider(),
          _buildInfoBarItem(
            Icons.location_on_outlined,
            provider.location,
            Colors.redAccent,
          ),
          _buildVerticalDivider(),
          _buildInfoBarItem(
            Icons.attach_money,
            '\$${provider.consultationFee}',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildInfoBarItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget content,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.photo_library, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.gallery.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showImageGallery(context, index),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(provider.gallery[index]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSectionContainer(
      title: 'About',
      icon: Icons.person_outline,
      content: Text(
        provider.about,
        style: TextStyle(
          color: Colors.grey[800],
          height: 1.6,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    // Assuming we have experience data in the provider model
    final experiences = [
      {
        'position': 'Senior Therapist',
        'company': 'Wellness Center',
        'duration': '2018 - Present',
        'description': 'Lead therapy sessions and mentored junior therapists.'
      },
      {
        'position': 'Therapist',
        'company': 'City Hospital',
        'duration': '2014 - 2018',
        'description': 'Provided therapeutic services to patients with various conditions.'
      },
    ];

    return _buildSectionContainer(
      title: 'Experience',
      icon: Icons.work_outline,
      content: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: experiences.length,
        itemBuilder: (context, index) {
          final exp = experiences[index];
          return Container(
            margin: EdgeInsets.only(bottom: index < experiences.length - 1 ? 16 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business_center_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp['position']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exp['company']} • ${exp['duration']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exp['description']!,
                        style: TextStyle(
                          color: Colors.grey[800],
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCredentials() {
    return _buildSectionContainer(
      title: 'Certifications',
      icon: Icons.school_outlined,
      content: Column(
        children: provider.credentials.map((credential) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${credential.institute} • ${credential.year}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (credential.certificationUrl != null)
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    onPressed: () => _launchUrl(credential.certificationUrl!),
                    color: AppColors.primary,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLicenseSection() {
    // Assuming we add license information to the provider model
    final licenseInfo = {
      'licenseNo': 'LIC-2023-78945',
      'issuedBy': 'State Medical Board',
      'validUntil': 'December 31, 2025',
      'status': 'Active',
    };

    return _buildSectionContainer(
      title: 'License Information',
      icon: Icons.badge_outlined,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            _buildLicenseRow('License No', licenseInfo['licenseNo']!),
            _buildLicenseRow('Issued By', licenseInfo['issuedBy']!),
            _buildLicenseRow('Valid Until', licenseInfo['validUntil']!),
            _buildLicenseRow('Status', licenseInfo['status']!, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return _buildSectionContainer(
      title: 'Services',
      icon: Icons.medical_services_outlined,
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: provider.services.map((service) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              service,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return _buildSectionContainer(
      title: 'Availability',
      icon: Icons.access_time_outlined,
      content: Column(
        children: provider.availability.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: index < provider.availability.length - 1 ? 10 : 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return _buildSectionContainer(
      title: 'Connect',
      icon: Icons.link,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: provider.socialLinks.map((social) {
          return InkWell(
            onTap: () => _launchUrl(social.url),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                social.icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return _buildSectionContainer(
      title: 'Reviews',
      icon: Icons.star_outline,
      content: Column(
        children: [
          _buildRatingSummary(),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: min(2, reviews.length),
            itemBuilder: (context, index) => _buildReviewItem(reviews[index]),
          ),
          if (reviews.length > 2)
            TextButton(
              onPressed: () => _showAllReviews(context),
              child: Text(
                'View All ${reviews.length} Reviews',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.userImage),
                backgroundColor: Colors.grey[300],
                child: review.userImage.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${review.date.day}/${review.date.month}/${review.date.year}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.rating.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < provider.rating.floor() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 12,
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${5 - index}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: index == 0
                              ? 0.8
                              : index == 1
                              ? 0.15
                              : 0.05,
                          backgroundColor: Colors.grey[200],
                          color: index == 0
                              ? Colors.green
                              : index == 1
                              ? Colors.amber
                              : Colors.redAccent,
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    providerId: provider.chatId,
                    providerName: provider.name,
                    providerImage: provider.imageUrl,
                  ),
                ),
              ),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentBookingScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Book Appointment',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await url_launcher.canLaunchUrl(url)) {
      await url_launcher.launchUrl(url);
    }
  }

  void _showImageGallery(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => GalleryDialog(
        images: provider.gallery,
        initialIndex: initialIndex,
      ),
    );
  }

  void _showAllReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => ReviewsSheet(
          reviews: reviews,
          controller: controller,
        ),
      ),
    );
  }
}