import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/core/widgets/feedback/modal.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../core/app_export.dart';
import '../../../../../core/common/ui_state.dart';
import '../notifier/signup_notifier.dart';
import '../models/signup_step.dart';
import '../../domain/models/user_registration.dart';
import 'steps/step_gender.dart';
import 'steps/step_age.dart';
import 'steps/step_genre.dart';
import 'steps/step_profile.dart';
import 'steps/step_signup.dart';

class SignupFlowScreen extends ConsumerStatefulWidget {
  const SignupFlowScreen({super.key});

  @override
  ConsumerState<SignupFlowScreen> createState() => _SignupFlowScreenState();
}

class _SignupFlowScreenState extends ConsumerState<SignupFlowScreen> {
  SignupStep currentStep = SignupStep.gender;
  String? selectedGender;
  String? selectedAge;
  List<String> selectedGenres = [];
  Map<String, String> profileData = {};
  Map<String, dynamic> signupData = {};

  void _nextStep() {
    final nextStep = currentStep.next;
    if (nextStep != null) {
      setState(() {
        currentStep = nextStep;
      });
    }
  }

  void _previousStep() {
    final previousStep = currentStep.previous;
    if (previousStep != null) {
      setState(() {
        currentStep = previousStep;
      });
    }
  }

  bool _canNextStep() {
    switch (currentStep) {
      case SignupStep.gender:
        return selectedGender != null;
      case SignupStep.age:
        return selectedAge != null;
      case SignupStep.genre:
        return true; // có thể skip
      case SignupStep.profile:
        final fullName = (profileData['fullName'] ?? '').trim();
        final phone = (profileData['phone'] ?? '').trim();
        final dob = (profileData['dob'] ?? '').trim();
        final country = (profileData['country'] ?? '').trim();

        final hasAllFields =
            fullName.isNotEmpty && phone.isNotEmpty && dob.isNotEmpty && country.isNotEmpty;
        if (!hasAllFields) return false;

        // check tiếp tục
        final isValid =
            ValidationUtils.validateFullName(fullName, context) == null &&
            ValidationUtils.validatePhone(phone, context) == null &&
            ValidationUtils.validateDOB(dob, context) == null &&
            ValidationUtils.validateCountry(country, context) == null;

        return isValid;
      case SignupStep.signup:
        final username = (signupData['username'] as String?)?.trim() ?? '';
        final email = (signupData['email'] as String?)?.trim() ?? '';
        final password = (signupData['password'] as String?)?.trim() ?? '';
        final confirmPassword = (signupData['confirmPassword'] as String?)?.trim() ?? '';

        final hasAllFields =
            username.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty;

        if (!hasAllFields) return false;

        final isValid =
            ValidationUtils.validateUsername(username, context) == null &&
            ValidationUtils.validateEmail(email, context) == null &&
            ValidationUtils.validatePassword(password, context) == null &&
            ValidationUtils.validateConfirmPassword(confirmPassword, password, context) == null;

        return isValid;
    }
  }

  Future<void> _handleSignUp() async {
    final signupNotifier = ref.read(signupNotifierProvider.notifier);

    final result = await signupNotifier.registerUser(
      gender: selectedGender,
      age: selectedAge,
      genres: selectedGenres,
      profileData: profileData,
      accountData: signupData,
    );

    // if (mounted) Navigator.of(context).pop(); // đóng loading

    switch (result) {
      case Success<UserReg>(data: final _):
        if (!mounted) return;
        await showAppModal(
          context: context,
          title: 'Success',
          description: context.i18n.auth.register.registrationSuccessful,
          iconPath: ImageConstant.successIcon,
          primaryButton: PrimaryButton(
            text: 'OK',
            onPressed: () => context.go(AppRouter.home),
          ),
        );
        break;
      case Error<UserReg>(message: final msg):
        if (!mounted) return;
        await showAppModal(
          context: context,
          title: 'Error',
          description: 'Error',
          iconPath: ImageConstant.successIcon,
          primaryButton: PrimaryButton(
            text: 'Close',
            onPressed: () => context.go(AppRouter.welcome),
          ),
          secondaryButton: SecondaryButton(
            text: 'ok',
            onPressed: () => context.go(AppRouter.welcome),
          ),
        );
        break;
      case Loading<UserReg>():
      case Idle<UserReg>():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildProcessBar(),

            Expanded(child: _buildStepContent()),

            _buildButtonBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessBar() {
    final progress = currentStep.stepNumber / SignupStepExtension.totalSteps;

    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [

          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = (constraints.maxWidth * 0.5).clamp(160.0, 320.0,); // %50
                return SizedBox(
                  width: barWidth,
                  height: 12,
                  child: Stack(
                    children: [
                      Container(
                        decoration: ShapeDecoration(
                          color: AppColors.getSurface(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: barWidth * progress,
                        decoration: ShapeDecoration(
                          color: AppColors.primary500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // <-
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                if (currentStep.isFirst) {
                  context.pop();
                } else {
                  _previousStep();
                }
              },
              child: SizedBox(
                width: 16,
                height: 16,
                child: SvgPicture.asset(
                  ImageConstant.arrowIcon,
                  colorFilter: ColorFilter.mode(
                    AppColors.getText(context),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case SignupStep.gender:
        return StepGender(
          onGenderSelected: (gender) {
            setState(() {
              selectedGender = gender;
            });
          },
          selectedGender: selectedGender,
        );
      case SignupStep.age:
        return StepAge(
          onAgeSelected: (age) {
            setState(() {
              selectedAge = age;
            });
          },
          selectedAge: selectedAge,
        );
      case SignupStep.genre:
        return StepGenre(
          onGenresSelected: (genres) {
            setState(() {
              selectedGenres = genres;
            });
          },
          selectedGenres: selectedGenres,
        );
      case SignupStep.profile:
        return StepProfile(
          onProfileCompleted: (data) {
            setState(() {
              profileData = data;
            });
          },
          initialData: profileData.isNotEmpty ? profileData : null,
        );
      case SignupStep.signup:
        return StepSignup(
          onSignupCompleted: (data) {
            setState(() {
              signupData = data;
            });
          },
          initialData: signupData.isNotEmpty ? signupData : null,
        );
    }
  }

  Widget _buildButtonBar() {
    final isLastStep = currentStep.isLast;
    final isGenreStep = currentStep.canSkip;
    final signupState = ref.watch(signupNotifierProvider);
    final isLoading = signupState is Loading<UserReg>;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        border: Border(
          top: BorderSide(color: AppColors.getSurface(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (isGenreStep)
            Expanded(
              child: SecondaryButton(
                text: context.i18n.common.skip,
                onPressed: () {
                  setState(() {
                    if (currentStep == SignupStep.genre) {
                      selectedGenres = [];
                    }
                    currentStep = currentStep.next ?? SignupStep.signup;
                  });
                },
              ),
            ),

          if (isGenreStep) const SizedBox(width: 16),

          Expanded(
            child: PrimaryButton(
              text: isLastStep
                  ? context.i18n.auth.signUp
                  : context.i18n.common.continueText,
              onPressed: isLastStep
                  ? (_canNextStep() && !isLoading ? _handleSignUp : null)
                  : (_canNextStep() ? _nextStep : null),
              backgroundColor: (_canNextStep()
                  ? AppColors.primary500
                  : AppColors.getSurface(context)),
              isLoading: isLastStep && isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
