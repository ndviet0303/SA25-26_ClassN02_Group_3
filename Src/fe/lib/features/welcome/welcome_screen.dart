import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_fe/routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/app_export.dart';
import '../../../core/widgets/feedback/toast_notification.dart';
import 'data/welcome_constant.dart';
import 'widgets/welcome_content.dart';
import 'widgets/page_indicator.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _currentBgIndex = 0;
  Timer? _bgTimer;

  final List<String> _backgroundImages = WelcomeBackgroundImages.images;
  final List<WelcomeSlide> _welcomeData = WelcomeData.slides;

  @override
  void initState() {
    super.initState();
    _fadingBackground();
  }

  void _fadingBackground() {
    _bgTimer = Timer.periodic(
      Duration(seconds: WelcomeAnimationValues.backgroundChangeInterval),
      (timer) {
        if (mounted) {
          setState(() {
            _currentBgIndex = (_currentBgIndex + 1) % _backgroundImages.length;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    final double horizontalPadding =
        screenWidth * WelcomeResponsiveValues.horizontalPaddingRatio;
    final double titleFontSize =
        screenWidth * WelcomeResponsiveValues.titleFontSizeRatio >
            WelcomeResponsiveValues.maxTitleFontSize
        ? WelcomeResponsiveValues.maxTitleFontSize
        : screenWidth * WelcomeResponsiveValues.titleFontSizeRatio;
    final double iconSize =
        screenWidth * WelcomeResponsiveValues.iconSizeRatio >
            WelcomeResponsiveValues.maxIconSize
        ? WelcomeResponsiveValues.maxIconSize
        : screenWidth * WelcomeResponsiveValues.iconSizeRatio;
    final double spaceBetween =
        screenHeight * WelcomeResponsiveValues.spaceBetweenRatio;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.getBackground(context),
              AppColors.getSurface(context),
            ],
          ),
        ),
        child: Stack(

          // layout chồng lên nhau
          fit: StackFit.expand,
          children: [

            Positioned.fill(
              child: AnimatedSwitcher(
                duration: Duration(
                  milliseconds: WelcomeAnimationValues.fadeTransitionDuration,
                ),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  _backgroundImages[_currentBgIndex],
                  key: ValueKey<int>(_currentBgIndex),
                  fit: BoxFit.cover, // fit màn
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.1, 0.5, 1.0],
                    colors: [
                      Colors.transparent, // vị trí 0.1
                      AppColors.getBackground(context).withValues(alpha: 0.9),
                      AppColors.getBackground(context).withValues(alpha: 1),
                    ],
                  ),
                ),
              ),
            ),


            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                // scale
                child: Column(
                  children: [

                    SizedBox(height: screenHeight * 0.35),

                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [

                          WelcomeContent(
                            pageController: _pageController,
                            currentPage: _currentPage,
                            welcomeData: _welcomeData,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            horizontalPadding: horizontalPadding,
                            titleFontSize: titleFontSize,
                            spaceBetween: spaceBetween,
                          ),

                          SizedBox(height: spaceBetween * 0.5),

                          PageIndicator(
                            currentPage: _currentPage,
                            totalPages: _welcomeData.length,
                            screenWidth: screenWidth,
                          ),
                        ],
                      ),
                    ),

                    // button
                    Expanded(
                      flex: WelcomeResponsiveValues.actionsAreaFlex,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PrimaryButton(
                            text: WelcomeButtonTexts.getGoogleText(context),
                            onPressed: () {
                              ToastNotification.showInfo(
                                context,
                                message: context.i18n.auth.oauth.featureInDevelopment,
                              );
                              // TODO: Handle Google sign in
                              // context.go(AppRouter.home);
                            },
                            backgroundColor: AppColors.getSurface(context),
                            textColor: AppColors.getText(context),
                            icon: SvgPicture.asset(
                              ImageConstant.imgGoogleIcon,
                              width: iconSize,
                              height: iconSize,
                            ),
                          ),

                          SizedBox(height: spaceBetween),

                          PrimaryButton(
                            text: WelcomeButtonTexts.getSignUpText(context),
                            onPressed: () {
                              context.push(AppRouter.signup);
                            },
                          ),

                          SizedBox(height: spaceBetween),

                          SecondaryButton(
                            text: WelcomeButtonTexts.getLoginText(context),
                            onPressed: () {
                              context.push(AppRouter.signIn);
                            },
                          ),

                          SizedBox(
                            height:
                                screenHeight *
                                WelcomeResponsiveValues.bottomSpacingRatio,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
