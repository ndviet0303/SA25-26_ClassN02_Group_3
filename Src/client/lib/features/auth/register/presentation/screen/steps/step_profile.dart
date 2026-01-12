import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/app_export.dart';

class StepProfile extends ConsumerStatefulWidget {
  final Function(Map<String, String>) onProfileCompleted;
  final Map<String, String>? initialData;

  const StepProfile({
    super.key,
    required this.onProfileCompleted,
    this.initialData,
  });

  @override
  ConsumerState<StepProfile> createState() => _StepProfileState();
}

class _StepProfileState extends ConsumerState<StepProfile> {
  // gán value
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _dob = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();

  String? _country;
  File? _selectedImage;

  static const List<DropdownItem> _countries = Countries.list;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _setupFocusListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onInputChange();
    });
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _fullName.text = data['fullName'] ?? '';
      _phone.text = data['phone'] ?? '';
      _dob.text = data['dob'] ?? '';
      _country = data['country'];
    }
  }

  void _setupFocusListeners() {
    // tránh validate form khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fullName.addListener(_onInputChange);
      _phone.addListener(_onInputChange);
      _dob.addListener(_onInputChange);
    });
  }

  void _onInputChange() {
    final fullName = _fullName.text.trim();
    final phone = _phone.text.trim();
    final dob = _dob.text.trim();
    final country = (_country ?? '').trim();

    final profile = <String, String>{
      'fullName': fullName,
      'phone': phone,
      'dob': dob,
      'country': country,
      if (_selectedImage != null) 'avatarPath': _selectedImage!.path,
    };

    print('StepProfile input: $profile');

    widget.onProfileCompleted(profile);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await pickDate(context);
    if (picked != null) {
      _dob.text = formatDateDDMMYYYY(picked);
      _onInputChange();
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _dob.dispose();
    _fullNameFocus.dispose();
    _phoneFocus.dispose();
    _dobFocus.dispose();
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
            context.i18n.auth.register.steps.profile.title,
            style: AppTypography.h3.copyWith(
              color: AppColors.getText(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            context.i18n.auth.register.steps.profile.privacyNote,
            style: AppTypography.bodyLRegular.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),

          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                ImagePickerCustom(
                  imageFile: _selectedImage,
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 80,
                  onPicked: (file) {
                    if (!mounted) return;
                    setState(() {
                      _selectedImage = file;
                    });
                  },
                ),

                const SizedBox(height: 16),

                Text(
                  context.i18n.auth.register.steps.profile.photo.tapToAdd,
                  style: AppTypography.bodySBRegular.copyWith(
                    color: AppColors.greyscale600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Column(
            children: [
              InfoField(
                label: context.i18n.auth.register.steps.profile.fields.fullName.label,
                hintText: context.i18n.auth.register.steps.profile.fields.fullName.placeholder,
                controller: _fullName,
                focusNode: _fullNameFocus,
                isRequired: true,
                validator: (value) =>
                    ValidationUtils.validateFullName(value, context),
                keyboardType: TextInputType.name,
                onSubmitted: (_) => _phoneFocus.requestFocus(),
              ),

              const SizedBox(height: 16),

              InfoField(
                label: context.i18n.auth.register.steps.profile.fields.phoneNumber.label,
                hintText: context.i18n.auth.register.steps.profile.fields.phoneNumber.placeholder,
                controller: _phone,
                focusNode: _phoneFocus,
                isRequired: true,
                validator: (value) =>
                    ValidationUtils.validatePhone(value, context),
                keyboardType: TextInputType.phone,
                onSubmitted: (_) => _dobFocus.requestFocus(),
              ),

              const SizedBox(height: 16),

              InfoField(
                label: context.i18n.auth.register.steps.profile.fields.dateOfBirth.label,
                hintText: context.i18n.auth.register.steps.profile.fields.dateOfBirth.format,
                controller: _dob,
                focusNode: _dobFocus,
                isRequired: true,
                validator: (value) =>
                    ValidationUtils.validateDOB(value, context),
                isReadOnly: true,
                onTap: _selectDate,
                onSubmitted: (_) {},
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
              ),

              const SizedBox(height: 16),

              CustomDropdown(
                label: context.i18n.auth.register.steps.profile.fields.country.label,
                value: _country,
                hint: context.i18n.auth.register.steps.profile.fields.country.placeholder,
                items: _countries,
                isRequired: true,
                onChanged: (value) {
                  setState(() {
                    _country = value ?? '';
                  });
                  _onInputChange();
                },
                suffixIcon: Transform.scale(
                  scale: 0.5,
                  child: SvgPicture.asset(
                    ImageConstant.dropdownIcon,
                    colorFilter: ColorFilter.mode(
                      AppColors.getTextSecondary(context),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }
}
