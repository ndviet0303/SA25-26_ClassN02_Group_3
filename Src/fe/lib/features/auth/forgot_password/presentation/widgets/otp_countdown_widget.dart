import 'package:flutter/material.dart';
import 'package:movie_fe/core/app_export.dart';

class OtpCountdownWidget extends StatelessWidget {
  const OtpCountdownWidget({
    super.key,
    required this.secondsLeft,
    required this.onResendCode,
  });

  final int secondsLeft;
  final VoidCallback onResendCode;

  @override
  Widget build(BuildContext context) {
    final t = context.i18n;
    final theme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            t.auth.forgotPassword.otp.didntReceiveCode,
            style: theme.titleSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: secondsLeft > 0
              ? _buildCountdownText(context, theme, isDark, t)
              : _buildResendButton(context, theme, t),
        ),
      ],
    );
  }

  Widget _buildCountdownText(
    BuildContext context,
    TextTheme theme,
    bool isDark,
    dynamic t,
  ) {
    final template = t.auth.forgotPassword.otp.resendAfter(seconds: secondsLeft);
    final parts = template.split('$secondsLeft');

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: theme.titleSmall,
        children: [
          if (parts[0].isNotEmpty) TextSpan(text: parts[0]),
          TextSpan(
            text: '$secondsLeft',
            style: theme.titleMedium!.copyWith(
              color: AppColors.primary500,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (parts.length > 1 && parts[1].isNotEmpty) 
            TextSpan(text: parts[1]),
        ],
      ),
    );
  }

  Widget _buildResendButton(
    BuildContext context,
    TextTheme theme,
    dynamic t,
  ) {
    return TextButton(
      onPressed: onResendCode,
      child: Text(
        t.auth.forgotPassword.otp.resendCode,
        textAlign: TextAlign.center,
        style: theme.titleMedium,
      ),
    );
  }
}
