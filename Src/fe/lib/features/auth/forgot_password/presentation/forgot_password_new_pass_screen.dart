import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/selection/app_checkbox.dart';
import '../../../../routes/app_router.dart';

import '../../../../core/widgets/feedback/modal.dart';
import 'package:movie_fe/features/auth/forgot_password/providers/forgot_password_repository_provider.dart';

final rememberMeProvider = StateProvider<bool>((ref) => false);

class ForgotPasswordNewPassScreen extends ConsumerWidget {
  const ForgotPasswordNewPassScreen({super.key, this.email, this.resetToken});

  final String? email;
  final String? resetToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var rememberMe = ref.watch(rememberMeProvider);
    final t = context.i18n;
    final ctxTheme = Theme.of(context).textTheme;

    final passCtl = TextEditingController();
    final confirmCtl = TextEditingController();
    final passNode = FocusNode();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.auth.forgotPassword.newPassword.title, style: ctxTheme.displaySmall),

              const SizedBox(height: 12),

              Text(t.auth.forgotPassword.newPassword.description, style: ctxTheme.titleLarge),

              const SizedBox(height: 32),

              Text(
                t.auth.password,
                style: ctxTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              InfoField(controller: passCtl,
                  focusNode: passNode,
                  hintText: '●●●●●●●●●●●●',
                  validator: (value) => ValidationUtils.validatePassword(value, context),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  isPassword: true),

              const SizedBox(height: 24),

              Text(
                t.auth.confirmPassword,
                style: ctxTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              InfoField(controller: confirmCtl, hintText: '●●●●●●●●●●●●', isPassword: true),

              const SizedBox(height: 24),

              AppCheckbox(
                value: rememberMe,
                label: t.auth.rememberMe,
                textStyle: ctxTheme.titleMedium,
                spacing: 16,
                onChanged: (bool value) {
                  ref.read(rememberMeProvider.notifier).state = value;
                },
              ),

              const Spacer(),

              PrimaryButton(
                text: t.common.continueText,
                onPressed: () async {
                  final newPass = passCtl.text.trim();
                  final confirmPass = confirmCtl.text.trim();
                  if (newPass.isEmpty || newPass != confirmPass) {
                    await showAppModal(
                      context: context,
                      title: 'Error',
                      description: 'Password not match',
                      iconPath: ImageConstant.successIcon,
                      primaryButton: PrimaryButton(
                        text: 'Close',
                        onPressed: () => context.pop(),
                      ),
                    );
                    return;
                  }
                  if (email == null || resetToken == null) {
                    await showAppModal(
                      context: context,
                      title: 'Error',
                      description: 'Missing token',
                      iconPath: ImageConstant.successIcon,
                      primaryButton: PrimaryButton(
                        text: 'Close',
                        onPressed: () => context.pop(),
                      ),
                    );
                    return;
                  }

                  try {
                    final repo = ref.read(forgotPasswordRepositoryProvider);
                    await repo.resetPassword(email: email!, resetToken: resetToken!, newPassword: newPass);
                    await showAppModal(
                      context: context,
                      title: 'Success',
                      description: 'Password updated',
                      iconPath: ImageConstant.successIcon,
                      primaryButton: PrimaryButton(
                        text: 'Go to Sign in',
                        onPressed: () => context.go(AppRouter.signIn),
                      ),
                    );
                  } catch (e) {
                    await showAppModal(
                      context: context,
                      title: 'Error',
                      description: e.toString(),
                      iconPath: ImageConstant.successIcon,
                      primaryButton: PrimaryButton(
                        text: 'Close',
                        onPressed: () => context.pop(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
