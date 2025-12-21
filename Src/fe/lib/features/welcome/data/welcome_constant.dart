import '../../../core/utils/data/image_constant.dart';
import '../../../../core/extension/context_extensions.dart';
import 'package:flutter/material.dart';

class WelcomeSlide {
  final String titleKey;
  final String descriptionKey;

  const WelcomeSlide({
    required this.titleKey,
    required this.descriptionKey,
  });

  String getTitle(BuildContext context) {
    final t = context.i18n;
    switch (titleKey) {
      case 'welcomeToNoZie':
        return t.welcome.title;
      case 'discoverNewMovies':
        return t.welcome.slides.discover.title;
      case 'trackYourWatchlist':
        return t.welcome.slides.track.title;
      case 'joinTheCommunity':
        return t.welcome.slides.community.title;
      default:
        return titleKey;
    }
  }

  String getDescription(BuildContext context) {
    final t = context.i18n;
    switch (descriptionKey) {
      case 'welcomeDescription':
        return t.welcome.description;
      case 'discoverDescription':
        return t.welcome.slides.discover.description;
      case 'trackDescription':
        return t.welcome.slides.track.description;
      case 'joinDescription':
        return t.welcome.slides.community.description;
      default:
        return descriptionKey;
    }
  }
}

class WelcomeData {
  static const List<WelcomeSlide> slides = [
    WelcomeSlide(
      titleKey: 'welcomeToNoZie',
      descriptionKey: 'welcomeDescription',
    ),
    WelcomeSlide(
      titleKey: 'discoverNewMovies',
      descriptionKey: 'discoverDescription',
    ),
    WelcomeSlide(
      titleKey: 'trackYourWatchlist',
      descriptionKey: 'trackDescription',
    ),
    WelcomeSlide(
      titleKey: 'joinTheCommunity',
      descriptionKey: 'joinDescription',
    ),
  ];
}

class WelcomeBackgroundImages {
  static final List<String> images = [
    ImageConstant.imgBackground1,
    ImageConstant.imgBackground2,
    ImageConstant.imgBackground3,
    ImageConstant.imgBackground4,
  ];
}

class WelcomeResponsiveValues {
  // ratios
  static const double topSpacingRatio = 0.35;
  static const double horizontalPaddingRatio = 0.06;
  static const double titleFontSizeRatio = 0.075;
  static const double iconSizeRatio = 0.06;
  static const double buttonHeightRatio = 0.065;
  static const double spaceBetweenRatio = 0.02;
  static const double bottomSpacingRatio = 0.04;
  
  // Font
  static const double maxTitleFontSize = 32;
  static const double maxIconSize = 24;
  
  // text
  static const double descriptionFontSizeRatio = 0.45;
  static const double descriptionLineHeight = 1.5;
  static const int maxDescriptionLines = 4;
  
  // Page indicator
  static const double pageIndicatorWidthRatio = 0.02;
  static const double pageIndicatorHeightRatio = 0.02;
  static const double pageIndicatorMarginRatio = 0.01;
  
  // flex
  static const int welcomeContentFlex = 3;
  static const int actionsAreaFlex = 4;
  
  // Spacing
  static const double topSpacingAdjustment = 0.9;
  static const double pageIndicatorSpacingRatio = 0.5;
  static const double pageIndicatorBottomSpacing = 2.0;
}

class WelcomeAnimationValues {
  static const int backgroundChangeInterval = 3;
  static const int fadeTransitionDuration = 1200;
}

class WelcomeGradientValues {
  static const List<double> overlayGradientStops = [0.1, 0.6, 1.0];
  static const List<double> overlayGradientAlpha = [0.0, 0.8, 0.95];
}

class WelcomeButtonTexts {
  static String getSignUpText(BuildContext context) => context.i18n.welcome.getStarted;
  static String getGoogleText(BuildContext context) => context.i18n.welcome.continueWithGoogle;
  static String getLoginText(BuildContext context) => context.i18n.welcome.iAlreadyHaveAnAccount;
}
