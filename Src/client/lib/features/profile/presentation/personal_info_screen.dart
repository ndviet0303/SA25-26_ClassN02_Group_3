import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_fe/core/app_export.dart';
import '../../../core/auth/auth_providers.dart';

import '../models/user_profile.dart';
import '../notifiers/profile_notifier.dart';
import '../../auth/shared/services/storage_service.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  final TextEditingController _bio = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();

  String? _username;
  String? _gender;
  String? _country;
  File? _avatarFile;
  String _userId = '';
  bool _initialized = false;
  ProviderSubscription<AsyncValue<UserProfile>>? _profileSubscription;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    _bio.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _dobFocus.dispose();
    _bioFocus.dispose();
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
      _username = profile.username;
      _fullName.text = profile.fullName;
      _email.text = profile.email;
      _phone.text = profile.phoneNumber;
      _dob.text = profile.dateOfBirth;
      _gender = profile.gender.isNotEmpty ? profile.gender.toLowerCase() : null;
      _bio.text = profile.bio;
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
        _dob.text = picked.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD for API
      });
    }
  }

  Future<void> _updateEmail() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    
    // Simple verification
    if (!ValidationUtils.isValidEmail(email)) {
      ToastNotification.showError(context, message: "Invalid email format");
      return;
    }

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final accessToken = ref.read(accessTokenProvider);
      if (accessToken == null) return;

      ToastNotification.showInfo(context, message: "Updating email...");
      await authRepo.updateEmail(email, accessToken);
      
      if (!mounted) return;
      ToastNotification.showSuccess(context, message: "Email updated successfully");
      
      // Refresh profile to sync
      ref.invalidate(profileNotifierProvider);
    } catch (e) {
      if (!mounted) return;
      ToastNotification.showError(context, message: "Failed to update email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profileState = ref.watch(profileNotifierProvider);
    final isSaving = profileState.isLoading;
    final currentProfile = profileState.asData?.value;
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
                    imageUrl: currentProfile?.avatarUrl,
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
              color: AppColors.getSurface(context),
              height: 1,
              thickness: 1,
            ),

            const SizedBox(height: 32),
            
            // Username Display (Non-editable, No TextField)
            _buildReadOnlyInfo("Username", _username ?? "...", context),
            
            const SizedBox(height: 24),

            InfoField(
              label: t.profile.personalInfo.fields.fullName.label,
              hintText: t.profile.personalInfo.fields.fullName.hint,
              controller: _fullName,
              focusNode: _fullNameFocus,
              onSubmitted: (_) => _emailFocus.requestFocus(),
              validator: (value) =>
                  ValidationUtils.validateFullName(value, context),
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
              suffixIcon: IconButton(
                onPressed: _updateEmail,
                icon: const Icon(Icons.update, color: AppColors.primary500, size: 28),
                tooltip: "Update Email",
              ),
            ),
            const SizedBox(height: 16),
            InfoField(
              label: "Phone Number",
              hintText: "Enter your phone number",
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
              label: "Gender",
              value: _gender,
              items: Genders.getOptions(context).entries.map((e) => DropdownItem(value: e.key, label: e.value)).toList(),
              onChanged: (value) => setState(() => _gender = value),
              hint: "Select Gender",
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
            const SizedBox(height: 16),
            InfoField(
              label: "Bio",
              hintText: "Tell us something about yourself",
              controller: _bio,
              focusNode: _bioFocus,
              maxLines: 3,
              backgroundColor: Colors.transparent,
              focusedBackgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: t.profile.personalInfo.saveChanges,
              isLoading: isSaving,
              onPressed: () async {
                if (isSaving) return;
                if (!(_formKey.currentState?.validate() ?? false)) {
                  return;
                }

                String? finalAvatarUrl = currentProfile?.avatarUrl;
                
                // Upload new avatar if picked
                if (_avatarFile != null) {
                  try {
                    final storageService = ref.read(storageServiceProvider);
                    finalAvatarUrl = await storageService.uploadToImgBB(_avatarFile!);
                  } catch (e) {
                    if (!mounted) return;
                    ToastNotification.showError(
                      context,
                      message: "Failed to upload avatar: $e",
                    );
                    return;
                  }
                }

                final baseProfile = currentProfile ?? UserProfile.empty;
                final userId = _userId.isNotEmpty ? _userId : baseProfile.id;
                final updated = UserProfile(
                  id: userId,
                  fullName: _fullName.text.trim(),
                  username: _username ?? baseProfile.username,
                  email: _email.text.trim(),
                  phoneNumber: _phone.text.trim(),
                  dateOfBirth: _dob.text.trim(),
                  country: _country ?? '',
                  avatarUrl: finalAvatarUrl ?? '',
                  gender: _gender ?? '',
                  bio: _bio.text.trim(),
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
            const SizedBox(height: 32),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyInfo(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMSemibold.copyWith(
            color: AppColors.getText(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.primary500, width: 1)),
          ),
          child: Text(
            value,
            style: AppTypography.bodyMRegular.copyWith(
              color: AppColors.getTextSecondary(context),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

