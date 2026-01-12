import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_fe/core/enums/status_type.dart';
import 'package:movie_fe/core/theme/app_colors.dart';
import 'package:movie_fe/core/utils/data/image_constant.dart';

class StatusStyle {
  final Color color;
  final SvgPicture img;

  const StatusStyle({required this.color, required this.img});
}

// Map kiểu "enum"
final Map<StatusType, StatusStyle> statusStyles = {
  StatusType.info: StatusStyle(
    color: AppColors.trBlue,
    img: SvgPicture.asset(ImageConstant.notificationInfo),
  ),
  StatusType.feature: StatusStyle(
    color: AppColors.trOrange,
    img: SvgPicture.asset(ImageConstant.notificationFeature),
  ),
  StatusType.update: StatusStyle(
    color: AppColors.trPurple,
    img: SvgPicture.asset(ImageConstant.notificationPurple),
  ),
  StatusType.user: StatusStyle(
    color: AppColors.trGreen,
    img: SvgPicture.asset(ImageConstant.notificationUser),
  ),
  StatusType.storage: StatusStyle(
    color: AppColors.trRed,
    img: SvgPicture.asset(ImageConstant.notificationStorage),
  ),
  StatusType.credit: StatusStyle(
    color: AppColors.trPurple,
    img: SvgPicture.asset(ImageConstant.notificationCredit),
  ),
};

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key, required this.type});

  final StatusType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: statusStyles[type]?.color,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(width: 28, height: 28, child: statusStyles[type]?.img),
      ),
    );
  }
}
