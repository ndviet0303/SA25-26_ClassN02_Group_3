import 'package:flutter/material.dart';
import '../utils/data/image_constant.dart';

class NetworkOrAssetImage extends StatelessWidget {
  const NetworkOrAssetImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  bool get _isNetworkUrl {
    return imageUrl.startsWith('http://') || 
           imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetworkUrl) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (errorWidget != null) return errorWidget!;
          return Image.asset(
            ImageConstant.imgImageNotFound,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (errorWidget != null) return errorWidget!;
          return Image.asset(
            ImageConstant.imgImageNotFound,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      );
    }
  }
}

