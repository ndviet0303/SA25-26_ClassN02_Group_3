import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_fe/core/app_export.dart';

import '../models/user_profile.dart';
import '../notifiers/profile_notifier.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _dob = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();

  String? _country;
  File? _avatarFile;
  String _userId = '';
  bool _initialized = false;
  ProviderSubscription<AsyncValue<UserProfile>>? _profileSubscription;

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    _fullNameFocus.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _dobFocus.dispose();
    _profileSubscription?.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Populate once when data becomes available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromProfile(ref.read(profileNotifierProvider));
    });
    _profileSubscription = ref.listenManual<AsyncValue<UserProfile>>(
      profileNotifierProvider,
      (previous, next) => _syncFromProfile(next),
    );
  }

  void _syncFromProfile(AsyncValue<UserProfile> state) {
    if (_initialized) return;
    final profile = state.value;
    if (profile == null) return;
    setState(() {
      _initialized = true;
      _userId = profile.id;
      _fullName.text = profile.fullName;
      _username.text = profile.username;
      _email.text = profile.email;
      _phone.text = profile.phone;
      _dob.text = profile.dateOfBirth;
      _country = profile.country.isNotEmpty ? profile.country : null;
      if (profile.avatarUrl.isNotEmpty) {
        _avatarFile = null; // network avatar, keep null
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await pickDate(context);
    if (picked != null) {
      setState(() {
        _dob.text = formatDateDDMMYYYY(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profileState = ref.watch(profileNotifierProvider);
    final isSaving = profileState.isLoading;
    final currentProfile = profileState.value;
    final t = context.i18n;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          t.profile.personalInfo.title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  ImagePickerCustom(
                    imageFile: _avatarFile,
                    onPicked: (file) => setState(() => _avatarFile = file),
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 80,
                    size: 96,
                    borderWidth: 2,
                  ),
                  const SizedBox(height: 12),
                 
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            Divider(
              color: AppColors.getTextSecondary(context).withOpacity(0.15),
              height: 1,
              thickness: 1,
            ),

            const SizedBox(height: 24),
            InfoField(
              label: t.profile.personalInfo.fields.fullName.label,
              hintText: t.profile.personalInfo.fields.fullName.hint,
              controller: _fullName,
              focusNode: _fullNameFocus,
              onSubmitted: (_) => _usernameFocus.requestFocus(),
              validator: (value) =>
                  ValidationUtils.validateFullName(value, context),
              backgroundColor: Colors.transparent,
              focusedBackgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            InfoField(
              label: t.profile.personalInfo.fields.username.label,
              hintText: t.profile.personalInfo.fields.username.hint,
              controller: _username,
              focusNode: _usernameFocus,
              onSubmitted: (_) => _emailFocus.requestFocus(),
              validator: (value) =>
                  ValidationUtils.validateUsername(value, context),
              backgroundColor: Colors.transparent,
              focusedBackgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            InfoField(
              label: t.profile.personalInfo.fields.email.label,
              hintText: t.profile.personalInfo.fields.email.hint,
              controller: _email,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => _phoneFocus.requestFocus(),
              validator: (value) =>
                  ValidationUtils.validateEmail(value, context),
              backgroundColor: Colors.transparent,
              focusedBackgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            InfoField(
              label: t.profile.personalInfo.fields.phone.label,
              hintText: t.profile.personalInfo.fields.phone.hint,
              controller: _phone,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => _dobFocus.requestFocus(),
              validator: (value) =>
                  ValidationUtils.validatePhone(value, context),
              backgroundColor: Colors.transparent,
              focusedBackgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            InfoField(
              label: t.profile.personalInfo.fields.dob.label,
              hintText: t.profile.personalInfo.fields.dob.hint,
              controller: _dob,
              focusNode: _dobFocus,
              isReadOnly: true,
              onTap: _selectDate,
              suffixIcon: Transform.scale(
                scale: 0.5,
                child: SvgPicture.asset(
                  ImageConstant.scheduleIcon,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              focusedBackgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: t.profile.personalInfo.fields.country.label,
              value: _country,
              items: Countries.list,
              onChanged: (value) => setState(() => _country = value),
              validator: (value) =>
                  ValidationUtils.validateCountry(value, context),

              hint: t.profile.personalInfo.fields.country.hint,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: t.profile.personalInfo.saveChanges,
              isLoading: isSaving,
              onPressed: () {
                if (isSaving) return;
                if (!(_formKey.currentState?.validate() ?? false)) {
                  return;
                }
                final baseProfile = currentProfile ?? UserProfile.empty;
                final userId = _userId.isNotEmpty ? _userId : baseProfile.id;
                final updated = UserProfile(
                  id: userId,
                  fullName: _fullName.text.trim(),
                  username: _username.text.trim(),
                  email: _email.text.trim(),
                  phone: _phone.text.trim(),
                  dateOfBirth: _dob.text.trim(),
                  country: _country ?? '',
                  avatarUrl: baseProfile.avatarUrl,
                );
                ref.read(profileNotifierProvider.notifier).update(updated).then((_) {
                  if (!mounted) return;
                  ToastNotification.showSuccess(
                    context,
                    message: t.profile.personalInfo.success,
                    duration: const Duration(seconds: 2),
                  );
                });
              },
              hasShadow: true,
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              text: t.common.cancel,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 24),
            if (profileState.hasError && !_initialized)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  t.profile.personalInfo.loadError,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                      ),
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }
}

