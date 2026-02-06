import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';

/// Widget with no source
class NoVideoMessage extends StatelessWidget {
  const NoVideoMessage({
    super.key,
    required this.movieTitle,
  });

  final String movieTitle;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 64,
                  color: AppColors.greyscale400,
                ),
                const Gap(24),
                Text(
                  movieTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                Text(
                  'Hiện tại chưa có nguồn phát cho phim này.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.greyscale300,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                Text(
                  'Vui lòng quay lại sau hoặc chọn server khác.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.greyscale400,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
