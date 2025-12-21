import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/common/ui_state.dart';
import 'package:movie_fe/core/widgets/feedback/toast_notification.dart';
import 'package:movie_fe/core/widgets/buttons/social_button.dart';
import 'package:movie_fe/core/widgets/layout/lined_text_divider.dart';
import 'package:movie_fe/features/auth/login/presentation/providers/login_provider.dart';
import 'package:movie_fe/core/widgets/selection/app_checkbox.dart';
import 'package:movie_fe/features/auth/login/presentation/notifier/login_notifier.dart';

import '../../../../routes/app_router.dart';
import 'package:go_router/go_router.dart';

final rememberMeProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var rememberMe = ref.watch(rememberMeProvider);
    final t = context.i18n;
    final type = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userCtl = ref.watch(usernameControllerProvider);
    final passCtl = ref.watch(passwordControllerProvider);
    final userNode = ref.watch(userFocusProvider);
    final passNode = ref.watch(passFocusProvider);

    final loginState = ref.watch(loginNotifierProvider);
    final loginNotifier = ref.read(loginNotifierProvider.notifier);

    Future<void> _handleEmailSignIn() async {
      final email = userCtl.text.trim();
      final password = passCtl.text.trim();

      final emailError = ValidationUtils.validateEmail(email, context);
      if (emailError != null) {
        ToastNotification.showError(
          context,
          message: emailError,
        );
        return;
      }

      if (password.isEmpty) {
        ToastNotification.showError(
          context,
          message: t.validation.password.required,
        );
        return;
      }

      await loginNotifier.signIn(email: email, password: password);
    }

    Future<void> _handleGoogleSignIn() async {
      ToastNotification.showInfo(
        context,
        message: t.auth.oauth.featureInDevelopment,
      );
      // TODO: Implement Google sign in
      // await loginNotifier.signInWithGoogle();
    }

    ref.listen<UIState<bool>>(loginNotifierProvider, (previous, next) {
      if (next is Success<bool>) {
        if (context.mounted) {
          context.go(AppRouter.home);
        }
        loginNotifier.reset();
      } else if (next is Error<bool>) {
        if (context.mounted) {
          final raw = next.message ?? '';
          final friendly = raw.contains('The supplied auth credential is malformed or has expired')
              ? t.auth.errors.invalidCredentials
              : raw;
          ToastNotification.showError(
            context,
            message: friendly,
          );
        }
        loginNotifier.reset();
      }
    });


    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.auth.loginScreen.title, style: type.displaySmall),

                const SizedBox(height: 12),

                Text(t.auth.loginScreen.description, style: type.titleLarge),

                const SizedBox(height: 32),

                Text(
                  t.auth.email,
                  style: type.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),

                InfoField(
                  hintText: t.auth.loginScreen.placeholder.email,
                  controller: userCtl,
                  focusNode: userNode,
                  validator: (value) => ValidationUtils.validateEmail(value, context),
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(passNode),
                ),

                const SizedBox(height: 24),

                Text(
                  t.auth.password,
                  style: type.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),

                InfoField(
                    hintText: t.auth.loginScreen.placeholder.password, isPassword: true,
                controller: passCtl,
                focusNode: passNode,
                // validator: (value) => ValidationUtils.validatePassword(value, context),
                onSubmitted: (_) => FocusScope.of(context).unfocus()),

                const SizedBox(height: 24),

                AppCheckbox(
                  value: rememberMe,
                  label: t.auth.rememberMe,
                  textStyle: type.titleMedium,
                  spacing: 16,
                  onChanged: (bool value) {
                    ref.read(rememberMeProvider.notifier).state = value;
                  },
                ),

                const SizedBox(height: 24),

                LinedTextDivider(),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity, // full width
                  alignment: Alignment.center, // căn giữa text
                  child: GestureDetector(
                    onTap: () {
                      context.push(AppRouter.forgotPassword);
                    },
                    child: Text(
                      t.auth.forgotPassword.title,
                      style: type.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                LinedTextDivider(text: t.auth.forgotPassword.orContinueWith),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: SocialButton(
                        icon: SvgPicture.asset(
                          ImageConstant.imgGoogleIcon,
                          height: 24,
                        ),
                        onPressed: () {
                          if (loginState is Loading<bool>) return;
                          _handleGoogleSignIn();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialButton(
                        icon: Icon(
                          Icons.apple,
                          size: 28,
                          color: isDark ? AppColors.white : AppColors.black,
                        ),
                        onPressed: () {
                          ToastNotification.showInfo(
                            context,
                            message: t.auth.oauth.featureInDevelopment,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialButton(
                        icon: SvgPicture.asset(
                          ImageConstant.imgFBIcon,
                          height: 24,
                        ),
                        onPressed: () {
                          ToastNotification.showInfo(
                            context,
                            message: t.auth.oauth.featureInDevelopment,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                Gap(24),
                Spacer(),

                PrimaryButton(
                  text: t.auth.signIn,
                  isLoading: loginState is Loading<bool>,
                  onPressed: loginState is Loading<bool>
                      ? null
                      : () {
                          _handleEmailSignIn();
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
