import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../extension/context_extensions.dart';

class ImagePickerCustom extends StatelessWidget {
  final File? imageFile;
  final ValueChanged<File?> onPicked;
  final ImageSource source;
  final double? maxWidth;
  final double? maxHeight;
  final int? imageQuality;

  final double size;
  final double borderWidth;

  const ImagePickerCustom({
    super.key,
    required this.imageFile,
    required this.onPicked,
    this.source = ImageSource.gallery,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality,
    this.size = 90,
    this.borderWidth = 2,
  });

  Future<void> _handlePick(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? xfile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      if (xfile != null) {
        onPicked(File(xfile.path));
      }
    } catch (_) {
      onPicked(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handlePick(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.greyscale100,
          border: Border.all(color: AppColors.primary500, width: borderWidth),
        ),
        child: imageFile != null
            ? ClipOval(
                child: Image.file(
                  imageFile!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: size * 0.36,
                    color: AppColors.greyscale500,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.i18n.auth.register.steps.profile.photo.add,
                    style: AppTypography.bodySBRegular.copyWith(
                      color: AppColors.greyscale500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
