import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/models/service_provider.dart';
import 'service_provider_profile_screen.dart';
import '/services/appwrite_service.dart';

class ServiceProviderListingScreen extends StatefulWidget {
  final String categoryName;

  const ServiceProviderListingScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<ServiceProviderListingScreen> createState() => _ServiceProviderListingScreenState();
}

class _ServiceProviderListingScreenState extends State<ServiceProviderListingScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _appwriteService = AppwriteService();
  bool _showElevation = false;
  bool _isLoading = true;
  List<ServiceProvider> _providers = [];
  List<ServiceProvider> _allProviders = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchServiceProviders();
  }

  Future<void> _fetchServiceProviders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final providers = await _appwriteService.getServiceProviders(widget.categoryName);

      setState(() {
        _allProviders = providers;
        _providers = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterProviders(String query) {
    setState(() {
      if (query.isEmpty) {
        _providers = _allProviders;
      } else {
        _providers = _allProviders
            .where((provider) =>
                provider.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_showElevation) {
      setState(() => _showElevation = true);
    } else if (_scrollController.offset <= 10 && _showElevation) {
      setState(() => _showElevation = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 220, // Increased height to accommodate header content
                floating: true,
                pinned: true,
                elevation: _showElevation ? 4 : 0,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(),
                  collapseMode: CollapseMode.parallax,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: _buildSearchBar(),
                ),
                title: Text(
                  widget.categoryName,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.grey[800], size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ];
          },
          body: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24), // Adjusted top padding to prevent overlap
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.gradientEnd,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
       // mainAxisSize: MainAxisSize.min, // Add this to prevent expansion
        children: [
          Text(
            'Find the best ${widget.categoryName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              'Browse through our list of verified and experienced healthcare providers',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _filterProviders,
        decoration: InputDecoration(
          hintText: 'Search providers...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchServiceProviders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_providers.isEmpty) {
      return const Center(
        child: Text('No service providers found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        return _ProviderCard(
          provider: _providers[index],
          categoryName: widget.categoryName,
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final String categoryName;

  const _ProviderCard({
    required this.provider,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: provider.imageUrl == 'placeholder_url'
                        ? const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 36,
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.network(
                        provider.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.rating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${provider.reviewCount})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items properly
              crossAxisAlignment: CrossAxisAlignment.center, // Center items vertically
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Minimize height
                    children: [
                      // Wrap chips in a flexible layout
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildInfoChip(
                            Icons.work,
                            '${provider.experience} years',
                            Colors.blue[700]!,
                            Colors.blue[100]!,
                          ),
                          _buildInfoChip(
                            Icons.location_on,
                            provider.address,
                            Colors.red[700]!,
                            Colors.red[100]!,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 8), // Add space between price and button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceProviderProfileScreen(
                          provider: provider,
                          selectedService: categoryName, // Pass the categoryName as selectedService
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4), // Add bottom margin for when they wrap
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}