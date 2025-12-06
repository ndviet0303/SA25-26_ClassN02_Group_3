import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/inputs/numeric_keyboard.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/providers/otp_vm.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/widgets/otp_input_controller.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/widgets/otp_input_group.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/widgets/otp_countdown_widget.dart';
import 'package:movie_fe/routes/app_router.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordOtpScreen extends ConsumerStatefulWidget {
  const ForgotPasswordOtpScreen({
    super.key,
    required this.email,
    this.length = 4,
    this.initialSeconds = 10,
  });

  final String email;
  final int length;
  final int initialSeconds;

  @override
  ConsumerState<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState
    extends ConsumerState<ForgotPasswordOtpScreen>
    with OtpInputController {

  @override
  int get length => widget.length;
  
  @override
  OtpVm get otpController => ref.read(_getProvider().notifier);

  AutoDisposeFamilyNotifierProvider<OtpVm, OtpVmState, ({String email, int initialSeconds, int length})> _getProvider() {
    final args = (
      email: widget.email,
      length: widget.length,
      initialSeconds: widget.initialSeconds,
    );
    return otpVmProvider(args);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.i18n;
    final theme = Theme.of(context).textTheme;

    final provider = _getProvider();

    ref.listen<OtpVmState>(provider, (prev, next) {
      updateFromState(next.digits);
    });

    final vm = ref.watch(provider);


    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Ẩn bàn phím khi tap ra ngoài
          FocusScope.of(context).unfocus();
          // Reset currentIndex để tất cả ô đều không focused
          setState(() {
            currentIndex = -1; // Hoặc một giá trị invalid
          });
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24,16,24,28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.auth.forgotPassword.otp.title, style: theme.displaySmall),

                      const SizedBox(height: 12),

                      Text(t.auth.forgotPassword.otp.description, style: theme.titleLarge),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OtpInputGroup(
                        length: widget.length,
                        controllers: controllers,
                        focusNodes: focusNodes,
                        currentIndex: currentIndex,
                        onChanged: (value, index) => commitInput(value, index),
                        onTap: (index) {
                          if (currentIndex != index) {
                            setState(() => currentIndex = index);
                          }
                        },
                        onKeyEvent: handleKeyEvent,
                      ),

                      const SizedBox(height: 40),

                      OtpCountdownWidget(
                        secondsLeft: vm.secondsLeft,
                        onResendCode: () async {
                          // await otpController.resendCode();
                        },
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      PrimaryButton(text: t.common.confirm, onPressed: () async {
                        final token = await otpController.verify();
                        if (token != null && token.isNotEmpty) {
                          if (!mounted) return;
                          context.push(AppRouter.resetPassword, extra: {
                            'email': widget.email,
                            'resetToken': token,
                          });
                        }
                      }),
                    ],
                  ),
                ],
                ),
              ),
            ),

            NumericKeyboard(
              onTextInput: onTextFromKeyboard,
              onBackspace: onBackspaceFromKeyboard,
            ),
            ],
          ),
        ),
      ),
    );
  }
}
