import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/layout/lined_text_divider.dart';
import 'package:movie_fe/features/auth/shared/providers/firebase_auth_provider.dart';
import 'package:movie_fe/features/profile/models/language_settings.dart';
import 'package:movie_fe/features/profile/models/user_profile.dart';
import 'package:movie_fe/features/profile/notifiers/auth_user_provider.dart';
import 'package:movie_fe/features/profile/notifiers/language_notifier.dart';
import 'package:movie_fe/features/profile/services/logout_service.dart';
import 'package:movie_fe/routes/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authUserProvider);
    final languageState = ref.watch(languageNotifierProvider);
    final t = context.i18n;
    final languageLabel = _languageLabel(context, languageState);

    void _showLogoutConfirmation() {
      final router = GoRouter.of(context);
      final auth = ref.read(firebaseAuthProvider);

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: AppColors.getModalBackground(context),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        builder: (sheetContext) => _LogoutBottomSheet(
          onCancel: () => Navigator.of(sheetContext).maybePop(),
          onConfirm: () async {
            Navigator.of(sheetContext).maybePop();
            await auth.signOut();
            await LogoutService.logout(ref);
            if (context.mounted) {
              router.go(AppRouter.welcome);
            }
          },
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(userState: userState),
            const LinedTextDivider(),
            _SettingItem(
              lightBackgroundColor: const Color(0xFFE7F8EF),
              iconAsset: ImageConstant.walletColorIcon,
              title: t.profile.menu.paymentMethods,
              onTap: () => context.push(AppRouter.paymentMethods),
            ),
            const LinedTextDivider(),
            _SettingItem(
              lightBackgroundColor: const Color(0xFFE9F0FF),
              iconAsset: ImageConstant.profileColorIcon,
              title: t.profile.menu.personalInfo,
              onTap: () => context.push(AppRouter.personalInfo),
            ),
            _SettingItem(
              lightBackgroundColor: const Color(0xFFFFEFEF),
              iconAsset: ImageConstant.ringColorIcon,
              title: t.profile.menu.notification,
              onTap: () => context.push(AppRouter.notificationSettings),
            ),
            _SettingItem(
              lightBackgroundColor: const Color(0xFFF3EEFF),
              iconAsset: ImageConstant.settingColorIcon,
              title: t.profile.menu.preferences,
              onTap: () => context.push(AppRouter.preferences),
            ),
            _SettingItem(
              lightBackgroundColor: const Color(0xFFEAF7F1),
              iconAsset: ImageConstant.guardIcon,
              title: t.profile.menu.security,
              onTap: () => context.push(AppRouter.security),
            ),
            _SettingItem(
              lightBackgroundColor: const Color(0xFFFFF4E6),
              iconAsset: ImageConstant.categoryColorIcon,
              title: t.profile.menu.language,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languageLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.getText(context).withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    ImageConstant.arrowRightIcon,
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      AppColors.getText(context).withOpacity(0.5),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              onTap: () => context.push(AppRouter.language),
            ),
            const _DarkModeSetting(),
            const SizedBox(height: 16),
            _SettingItem(
              lightBackgroundColor: const Color(0xFFE7F8EF),
              iconAsset: ImageConstant.documentColorIcon,
              title: t.profile.menu.helpCenter,
              onTap: () => context.push(AppRouter.helpCenter),
            ),
            // _SettingItem(
            //   lightBackgroundColor: const Color(0xFFFFF4E6),
            //   iconAsset: ImageConstant.infoIcon,
            //   title: t.profile.menu.about,
            //   onTap: () {},
            // ),
            const SizedBox(height: 8),
            _LogoutItem(onTap: _showLogoutConfirmation),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.userState,
  });

  final AsyncValue<UserProfile> userState;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);
    final t = context.i18n;

    return userState.when(
      data: (profile) => Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: profile.avatarUrl.isNotEmpty
                ? NetworkImage(profile.avatarUrl) as ImageProvider
                : const AssetImage(ImageConstant.imgAvatar),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                profile.fullName.isNotEmpty
                    ? profile.fullName
                    : t.profile.header.defaultName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                profile.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryText,
                    ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRouter.personalInfo),
            icon: SvgPicture.asset(
              ImageConstant.editIcon,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(
                textColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(ImageConstant.imgAvatar),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              t.profile.header.loadError,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String iconAsset;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color lightBackgroundColor;

  const _SettingItem({
    required this.iconAsset,
    required this.title,
    required this.lightBackgroundColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final bg = _bgForTheme(context, lightBackgroundColor);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: SvgPicture.asset(iconAsset, width: 18, height: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                SvgPicture.asset(
                  ImageConstant.arrowRightIcon,
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    textColor.withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  final VoidCallback? onTap;
  const _LogoutItem({this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.i18n;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _bgForTheme(context, const Color(0xFFFFE9EB)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              ImageConstant.logoutIcon,
              width: 18,
              height: 18,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            t.profile.menu.logout,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFFF4D4D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkModeSetting extends ConsumerWidget {
  const _DarkModeSetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final isDark = mode == ThemeMode.dark;
    final t = context.i18n;

    return _SettingItem(
      lightBackgroundColor: const Color(0xFFE9F0FF),
      iconAsset: ImageConstant.eyeColorIcon,
      title: t.profile.menu.darkMode,
      trailing: Switch.adaptive(
        value: isDark,
        onChanged: (val) => notifier.set(val ? ThemeMode.dark : ThemeMode.light),
      ),
    );
  }
}

class _LogoutBottomSheet extends StatelessWidget {
  const _LogoutBottomSheet({
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final t = context.i18n;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.getText(context).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.trRed.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                ImageConstant.logoutIcon,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.warning,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.profile.logoutSheet.title,
              style: AppTypography.h6.copyWith(color: textColor),
            ),
            const SizedBox(height: 6),
            Text(
              t.profile.logoutSheet.description,
              style: AppTypography.bodyMMedium.copyWith(color: secondaryText),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: t.common.cancel,
                    onPressed: onCancel,
                    backgroundColor: AppColors.getSurface(context),
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: t.common.yes,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _languageLabel(BuildContext context, AsyncValue<LanguageSettings> state) {
  return state.when(
    data: (value) {
      final label = value.selected;
      return Languages.suggested
          .followedBy(Languages.others)
          .firstWhere(
            (item) => item.value == label,
            orElse: () => DropdownItem(
              value: 'en_us',
              label: context.i18n.profile.language.fallback,
            ),
          )
          .label;
    },
    loading: () => context.i18n.common.loading,
    error: (_, __) => context.i18n.profile.language.fallback,
  );
}

// Util: generate dark-mode friendly background from a light pastel
Color _bgForTheme(BuildContext context, Color lightColor) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (!isDark) return lightColor;
  final hsl = HSLColor.fromColor(lightColor);
  // Reduce lightness and saturation for better dark backgrounds
  final darkHsl = hsl
      .withSaturation((hsl.saturation * 0.6).clamp(0.0, 1.0))
      .withLightness((hsl.lightness * 0.25).clamp(0.0, 1.0));
  return darkHsl.toColor().withOpacity(0.6);
}
