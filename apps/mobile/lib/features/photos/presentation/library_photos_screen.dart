import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/chintamani_logo.dart';

class LibraryPhotosScreen extends StatefulWidget {
  const LibraryPhotosScreen({super.key});

  @override
  State<LibraryPhotosScreen> createState() => _LibraryPhotosScreenState();
}

class _LibraryPhotosScreenState extends State<LibraryPhotosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const String khalilabadMapUrl = 'https://maps.app.goo.gl/RjjdGmMsiEKkJn7F7';
  static const String mehdawalMapUrl = 'https://maps.app.goo.gl/6snL6CTrmxak4zsa8';

  final List<_PhotoItem> khalilabadPhotos = const [
    _PhotoItem(
      title: 'Main AC Study Hall',
      description: 'Soundproof silent study hall with optimum 22°C inverter climate control',
      category: 'Study Zone',
      assetPath: 'assets/images/khalilabad_hall.jpg',
    ),
    _PhotoItem(
      title: 'Ergonomic 3D Study Desks',
      description: '72 individual partitioned desks with orthopedic lumbar chairs for 12+ hr focus',
      category: 'Desks & Seating',
      assetPath: 'assets/images/khalilabad_desks.jpg',
    ),
    _PhotoItem(
      title: 'Secure Student Lockers',
      description: 'Personal key lockable steel storage units for books, laptops and bags',
      category: 'Storage',
      assetPath: 'assets/images/khalilabad_lockers.jpg',
    ),
  ];

  final List<_PhotoItem> mehdawalPhotos = const [
    _PhotoItem(
      title: 'Premier Digital Study Hall',
      description: '65 ergonomic study seats with warm non-glare LED illumination and pin-drop silence',
      category: 'Study Zone',
      assetPath: 'assets/images/mehdawal_hall.jpg',
    ),
    _PhotoItem(
      title: 'Private Isolated Reading Cabins',
      description: 'Individual acoustic partitioned booths for civil services and medical aspirants',
      category: 'Study Cabins',
      assetPath: 'assets/images/mehdawal_cabins.jpg',
    ),
    _PhotoItem(
      title: 'Reception & Smart Attendance Hub',
      description: 'Biometric fingerprint scanner & digital check-in counter',
      category: 'Entrance & Tech',
      assetPath: 'assets/images/mehdawal_reception.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openMap(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showFullScreenImage(BuildContext context, _PhotoItem photo) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.95),
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      photo.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.asset(
                  photo.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1E1E24),
                    child: const Center(
                      child: Icon(Icons.photo_library_outlined, color: AppColors.goldPrimary, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                photo.description,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const ChintaManiLogo(size: 34, showGlow: true),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHINTA MANI PHOTOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            'Official Library Campus Gallery',
                            style: TextStyle(
                              color: AppColors.goldPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Branch Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xF2121216),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: AppColors.goldBright,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    tabs: const [
                      Tab(text: 'Khalilabad (72 Seats)'),
                      Tab(text: 'Mehdawal (65 Seats)'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Gallery View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGalleryList(
                      branchTitle: 'Khalilabad Campus (72 Seats)',
                      mapUrl: khalilabadMapUrl,
                      photos: khalilabadPhotos,
                    ),
                    _buildGalleryList(
                      branchTitle: 'Mehdawal Campus (65 Seats)',
                      mapUrl: mehdawalMapUrl,
                      photos: mehdawalPhotos,
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

  Widget _buildGalleryList({
    required String branchTitle,
    required String mapUrl,
    required List<_PhotoItem> photos,
  }) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      children: [
        // Clean Location Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xF216141F),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.goldPrimary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  branchTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              GestureDetector(
                onTap: () => _openMap(mapUrl),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Maps',
                    style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Photo Cards - 100% Guaranteed Display using bundled assets!
        ...photos.map((photo) {
          return GestureDetector(
            onTap: () => _showFullScreenImage(context, photo),
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0xF214121A),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Image.asset(
                            photo.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF1E1E24),
                              child: const Center(
                                child: Icon(Icons.photo_library_outlined, color: AppColors.goldPrimary, size: 40),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            photo.category,
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          photo.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          photo.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _PhotoItem {
  final String title;
  final String description;
  final String category;
  final String assetPath;

  const _PhotoItem({
    required this.title,
    required this.description,
    required this.category,
    required this.assetPath,
  });
}
