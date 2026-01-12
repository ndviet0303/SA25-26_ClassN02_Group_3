import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie.dart';
import '../widgets/movie_info_panel.dart';

class MovieInfoScreen extends ConsumerWidget {
  const MovieInfoScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getText(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          movie.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.getText(context),
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MovieInfoPanel(movie: movie),
            const Gap(24),
            _ImagesCarousel(movie: movie),
            const Gap(48),
          ],
        ),
      ),
    );
  }
}

class _ImagesCarousel extends StatefulWidget {
  const _ImagesCarousel({required this.movie});

  final Movie movie;

  @override
  State<_ImagesCarousel> createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<_ImagesCarousel> {
  final PageController _controller = PageController(viewportFraction: 1.0);
  int _current = 0;
  late final FirebaseFirestore _db;
  late final Future<Map<String, dynamic>?> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _db = FirebaseFirestore.instance;
    _imagesFuture = _fetchImagesDoc();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchImagesDoc() async {
    // Movie.id is the slug (document key in /images)
    final doc = await _db.collection('images').doc(widget.movie.id).get();
    if (doc.exists) return doc.data();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data;
        if (data == null) {
          return const SizedBox.shrink();
        }

        final List<dynamic> backdropsRaw = (data['backdrops'] as List?) ?? const [];
        final backdropsAll = backdropsRaw
            .map((e) => (e is Map && e['url'] is String) ? e['url'] as String : null)
            .whereType<String>()
            .toList();

        if (backdropsAll.isEmpty) return const SizedBox.shrink();

        final backdrops = backdropsAll.toList();

        // Manual swipe only (no auto-scroll)

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.i18n.movie.info.images,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Gap(8),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _controller,
                      onPageChanged: (i) {
                        if (!mounted) return;
                        setState(() => _current = i.clamp(0, backdrops.length - 1));
                      },
                      itemCount: backdrops.length,
                      itemBuilder: (context, index) {
                        final url = backdrops[index];
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.getSurface(context),
                            alignment: Alignment.center,
                            child: Text(context.i18n.movie.info.cannotLoadImage, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryText)),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_current + 1}/${backdrops.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


