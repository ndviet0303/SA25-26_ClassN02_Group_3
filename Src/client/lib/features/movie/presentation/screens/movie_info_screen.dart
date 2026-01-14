import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  
  // Use a static list of images for now as a fallback
  final List<String> _backdrops = [
    'https://image.tmdb.org/t/p/original/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
    'https://image.tmdb.org/t/p/original/mXLOHHc1Z3vslZPPiQDDoubleXP.jpg',
    'https://image.tmdb.org/t/p/original/rM5YpT2N65E5K4zAnY9DscQ4R3M.jpg',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.i18n.movie.info.images,
          style: theme.textTheme.titleMedium?.copyWith(
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
                    setState(() => _current = i.clamp(0, _backdrops.length - 1));
                  },
                  itemCount: _backdrops.length,
                  itemBuilder: (context, index) {
                    final url = _backdrops[index];
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
                        child: Text(
                          context.i18n.movie.info.cannotLoadImage,
                          style: theme.textTheme.bodySmall?.copyWith(color: secondaryText),
                        ),
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
                      '${_current + 1}/${_backdrops.length}',
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
  }
}
