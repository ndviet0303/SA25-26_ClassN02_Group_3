import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';
import '../data/welcome_constant.dart';

class WelcomeContent extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final List<WelcomeSlide> welcomeData;
  final Function(int) onPageChanged;
  final double horizontalPadding;
  final double titleFontSize;
  final double spaceBetween;

  const WelcomeContent({
    super.key,
    required this.pageController,
    required this.currentPage,
    required this.welcomeData,
    required this.onPageChanged,
    required this.horizontalPadding,
    required this.titleFontSize,
    required this.spaceBetween,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: welcomeData.length,
        itemBuilder: (context, index) {
          final data = welcomeData[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding * 0.5,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(context, data),

                SizedBox(height: spaceBetween),

                _buildDescription(context, data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(BuildContext context, WelcomeSlide data) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTypography.h3.copyWith(
            color: AppColors.getText(context),
            fontSize: titleFontSize,
          ),
          children: [
            if (data.titleKey == 'welcomeToNoZie') ...[
              TextSpan(text: context.i18n.welcome.titlePrefix),
              TextSpan(
                text: 'NoZie 👋',
                style: AppTypography.h3.copyWith(
                  color: AppColors.primary500,
                  fontSize: titleFontSize,
                ),
              ),
            ] else
              TextSpan(text: data.getTitle(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, WelcomeSlide data) {
    return Text(
      data.getDescription(context),
      style: AppTypography.bodyLRegular.copyWith(
        color: AppColors.getTextSecondary(context),
        height: 1.5,
        fontSize: titleFontSize * 0.45,
      ),
      textAlign: TextAlign.center,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }
}
