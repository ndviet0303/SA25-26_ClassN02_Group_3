import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_fe/core/widgets/selection/app_checkbox.dart';
import '../../../../../../core/app_export.dart';

class StepSignup extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSignupCompleted;
  final Map<String, dynamic>? initialData;

  const StepSignup({
    super.key,
    required this.onSignupCompleted,
    this.initialData,
  });

  @override
  ConsumerState<StepSignup> createState() => _StepSignupState();
}

class _StepSignupState extends ConsumerState<StepSignup> {

  // gán value
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;

  // next field sau
  late final FocusNode _usernameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;

  bool _rememberMe = false;


  @override
  void initState() {
    super.initState();

    _username = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();

    _usernameFocus = FocusNode();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();

    // nghe thay đổi
    _username.addListener(_onInputChanged);
    _email.addListener(_onInputChanged);
    _password.addListener(_onInputChanged);
    _confirmPassword.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    final account = {
      'username' : _username.text,
      'email' : _email.text,
      'password' : _password.text,
      'confirmPassword' : _confirmPassword.text,
      'rememberMe': _rememberMe,
    };

    print("onSignupCompleted nhận dữ liệu: $account");

    widget.onSignupCompleted(account); // gán vào sign up
  }

  @override // giải phóng data widget
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();

    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            context.i18n.auth.register.createAccount,
            style: AppTypography.h3.copyWith(
              color: AppColors.getText(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            context.i18n.auth.register.description,
            style: AppTypography.bodyLRegular.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),

          const SizedBox(height: 32),

          Column(
            children: [

              InfoField(
                label: context.i18n.auth.username,
                hintText: context.i18n.auth.register.placeholder.username,
                isRequired: true,
                keyboardType: TextInputType.text,
                controller: _username, // nghe input
                focusNode: _usernameFocus,
                validator: (value) => ValidationUtils.validateUsername(value, context),
                onSubmitted: (_) => _emailFocus.requestFocus(), // next focus
              ),

              const SizedBox(height: 24),

              InfoField(
                label: context.i18n.auth.email,
                hintText: context.i18n.auth.register.placeholder.email,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                controller: _email,
                focusNode: _emailFocus,
                validator: (value) => ValidationUtils.validateEmail(value, context),
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),

              const SizedBox(height: 24),

              InfoField(
                label: context.i18n.auth.password,
                hintText: context.i18n.auth.register.placeholder.password,
                isRequired: true,
                isPassword: true,
                controller: _password,
                focusNode: _passwordFocus,
                validator: (value) => ValidationUtils.validatePassword(value, context),
                onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
              ),

              const SizedBox(height: 24),

              InfoField(
                label: context.i18n.auth.confirmPassword,
                hintText: context.i18n.auth.register.placeholder.confirmPassword,
                isRequired: true,
                isPassword: true,
                controller: _confirmPassword,
                focusNode: _confirmPasswordFocus,
                validator: (value) => ValidationUtils.validateConfirmPassword(value, _password.text, context),
                onSubmitted: (_) {
                  if (_confirmPassword.text.trim() != _password.text.trim()) {
                    _confirmPasswordFocus.requestFocus();
                    return;
                  }
                  _confirmPasswordFocus.unfocus();
                },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  //
                  AppCheckbox(
                    value: _rememberMe,
                    label: context.i18n.auth.rememberMe,
                    spacing: 16,
                    onChanged: (bool value) {
                      setState(() {
                        _rememberMe = value;
                      });
                      _onInputChanged();
                    },
                  ),

                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }
}
