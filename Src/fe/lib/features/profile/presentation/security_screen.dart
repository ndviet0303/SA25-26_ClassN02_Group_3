import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/feedback/toast_notification.dart';
import 'package:movie_fe/features/profile/models/security_settings.dart';
import 'package:movie_fe/features/profile/notifiers/security_notifier.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityNotifierProvider);
    final settings = securityState.value ?? SecuritySettings.defaults;
    final notifier = ref.read(securityNotifierProvider.notifier);

    final isProcessing = securityState.isLoading;
    final t = context.i18n;

    void openDeviceManagement() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.getModalBackground(context),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return _DeviceManagementSheet(
                sessions: settings.sessions,
                scrollController: scrollController,
                onSignOut: (session) async {
                  await notifier.signOutDevice(session.id);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).maybePop();
                  }
                  if (context.mounted) {
                    ToastNotification.showSuccess(
                      context,
                      message: t.profile.security.actions
                          .signOutDevice(name: session.name),
                    );
                  }
                },
                onSignOutAll: () async {
                  await notifier.signOutAllDevices();
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).maybePop();
                  }
                  if (context.mounted) {
                    ToastNotification.showSuccess(
                      context,
                      message: t.profile.security.actions.signOutAll,
                    );
                  }
                },
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          t.profile.security.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: ContentWrappers.page(
        context,
        child: securityState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              t.profile.security.loadError(error: error.toString()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
          data: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SecurityToggle(
                title: t.profile.security.toggles.rememberMe,
                value: settings.rememberMe,
                onChanged: isProcessing
                    ? null
                    : (val) => notifier.toggle(rememberMe: val),
              ),
              const SizedBox(height: 20),
              _SecurityToggle(
                title: t.profile.security.toggles.biometricId,
                value: false, // Luôn tắt
                onChanged: isProcessing
                    ? null
                    : (val) {
                        if (val) {
                          // Khi user cố bật, hiển thị toast
                          ToastNotification.showInfo(
                            context,
                            message: t.auth.oauth.featureInDevelopment,
                          );
                        }
                        // Không thay đổi giá trị, luôn giữ false
                      },
              ),
              const SizedBox(height: 20),
              _SecurityToggle(
                title: t.profile.security.toggles.faceId,
                value: false, // Luôn tắt
                onChanged: isProcessing
                    ? null
                    : (val) {
                        if (val) {
                          // Khi user cố bật, hiển thị toast
                          ToastNotification.showInfo(
                            context,
                            message: t.auth.oauth.featureInDevelopment,
                          );
                        }
                        // Không thay đổi giá trị, luôn giữ false
                      },
              ),
              const SizedBox(height: 20),
              _SecurityToggle(
                title: t.profile.security.toggles.smsAuthenticator,
                value: false, // Luôn tắt
                onChanged: isProcessing
                    ? null
                    : (val) {
                        if (val) {
                          // Khi user cố bật, hiển thị toast
                          ToastNotification.showInfo(
                            context,
                            message: t.auth.oauth.featureInDevelopment,
                          );
                        }
                        // Không thay đổi giá trị, luôn giữ false
                      },
              ),
              const SizedBox(height: 20),
              _SecurityToggle(
                title: t.profile.security.toggles.googleAuthenticator,
                value: false, // Luôn tắt
                onChanged: isProcessing
                    ? null
                    : (val) {
                        if (val) {
                          // Khi user cố bật, hiển thị toast
                          ToastNotification.showInfo(
                            context,
                            message: t.auth.oauth.featureInDevelopment,
                          );
                        }
                        // Không thay đổi giá trị, luôn giữ false
                      },
              ),
              const SizedBox(height: 20),
              _SecurityNavigationTile(
                title: t.profile.security.actions.deviceManagement,
                onTap: openDeviceManagement,
              ),
              const SizedBox(height: 32),
              // SecondaryButton(
              //   text: t.profile.security.actions.changePassword,
              //   onPressed: () {
              //     ToastNotification.showInfo(
              //       context,
              //       message: t.profile.security.actions.changePasswordMessage,
              //     );
              //   },
              //   hasShadow: false,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityToggle extends StatelessWidget {
  const _SecurityToggle({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary500,
          activeTrackColor: AppColors.primary500,
        ),
      ],
    );
  }
}

class _SecurityNavigationTile extends StatelessWidget {
  const _SecurityNavigationTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppColors.getText(context).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceManagementSheet extends StatelessWidget {
  const _DeviceManagementSheet({
    required this.sessions,
    required this.scrollController,
    required this.onSignOut,
    required this.onSignOutAll,
  });

  final List<DeviceSession> sessions;
  final ScrollController scrollController;
  final void Function(DeviceSession session) onSignOut;
  final VoidCallback onSignOutAll;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final secondary = AppColors.getTextSecondary(context);
    final t = context.i18n;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: ListView(
        controller: scrollController,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.getText(context).withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.profile.security.deviceManagement.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t.profile.security.deviceManagement.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: secondary,
                ),
          ),
          const SizedBox(height: 24),
          ...sessions.map(
            (session) => Padding(
              padding: EdgeInsets.only(
                bottom: session == sessions.last ? 0 : 20,
              ),
              child: _DeviceSessionRow(
                session: session,
                onSignOut: () => onSignOut(session),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SecondaryButton(
            text: t.profile.security.deviceManagement.signOutAll,
            onPressed: onSignOutAll,
            hasShadow: false,
          ),
        ],
      ),
    );
  }
}

class _DeviceSessionRow extends StatelessWidget {
  const _DeviceSessionRow({
    required this.session,
    required this.onSignOut,
  });

  final DeviceSession session;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final secondary = AppColors.getTextSecondary(context);
    final t = context.i18n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.getSurface(context),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(
            _iconForPlatform(session.platform),
            size: 22,
            color: textColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (session.isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        t.profile.security.deviceManagement.current,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary500,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                session.location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                session.status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                t.profile.security.deviceManagement
                    .lastActive(time: session.lastActive),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondary.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSignOut,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary500,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(t.common.signOut),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForPlatform(DevicePlatform platform) {
    switch (platform) {
      case DevicePlatform.ios:
        return Icons.phone_iphone;
      case DevicePlatform.android:
        return Icons.smartphone;
      case DevicePlatform.macos:
        return Icons.laptop_mac;
      case DevicePlatform.web:
        return Icons.desktop_windows;
    }
  }
}


