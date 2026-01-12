import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double screenWidth;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          width: screenWidth * 0.02,
          height: screenWidth * 0.02,
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.01,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getIndicatorColor(context, index),
          ),
        ),
      ),
    );
  }

  Color _getIndicatorColor(BuildContext context, int index) {
    return currentPage == index
        ? AppColors.primary500
        : AppColors.getTextSecondary(context);
  }
}
