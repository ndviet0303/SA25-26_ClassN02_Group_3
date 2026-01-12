import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/data/image_constant.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/* doc:
await showAppModal(
  context: context,
  title: 'Error',
  description: 'Error',
  iconPath: ImageConstant.successIcon,
  primaryButton: PrimaryButton(
      text: 'Close',
      onPressed: () => Navigator.pop(context),
   ),
   secondaryButton: SecondaryButton(
      text: 'ok',
      onPressed: () => Navigator.pop(context),
    ),
);
*/


class Modal extends StatelessWidget {

  final String title;
  final String description;
  final String iconPath;
  final PrimaryButton? primaryButton;
  final SecondaryButton? secondaryButton;
  final EdgeInsetsGeometry contentPadding;
  final double iconSize;

  const Modal({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    this.primaryButton,
    this.secondaryButton,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0),
    this.iconSize = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.primary500; // mặc định
    final Color textSecondary = AppColors.getText(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: AppColors.getModalBackground(context),
      child: Padding(
        padding: contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            SvgPicture.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
            ),

            const SizedBox(height: 24.0),

            Text(
              title,
              style: AppTypography.h3.copyWith(
                color: textColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16.0),

            Text(
              description,
              style: AppTypography.bodyLRegular.copyWith(
                color: textSecondary,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),

            if (primaryButton != null || secondaryButton != null) ...[
              const SizedBox(height: 32),
              if (primaryButton != null) SizedBox(width: double.infinity, child: primaryButton!),
              if (secondaryButton != null) ...[
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: secondaryButton!),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

Future<T?> showAppModal<T>({
  required BuildContext context,
  required String title,
  required String description,
  String iconPath = ImageConstant.loadingIcon,
  PrimaryButton? primaryButton,
  SecondaryButton? secondaryButton,
}) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => BlurModalScreen(
        child: Modal(
          title: title,
          description: description,
          iconPath: iconPath,
          primaryButton: primaryButton,
          secondaryButton: secondaryButton,
        ),
      ),
    ),
  );
}


// bọc cho fading in
class ModalWrapper extends StatefulWidget {
  final Widget child;

  const ModalWrapper({super.key, required this.child});

  @override
  State<ModalWrapper> createState() => _ModalWrapperState();
}

class _ModalWrapperState extends State<ModalWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}


// bọc blur màn
class BlurModalScreen extends StatelessWidget {
  final Widget child;

  const BlurModalScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // để lộ nền
      body: Stack(
        children: [
          // Nền blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // Modal chính
          Center(
            child: ModalWrapper(child: child),
          ),
        ],
      ),
    );
  }
}
