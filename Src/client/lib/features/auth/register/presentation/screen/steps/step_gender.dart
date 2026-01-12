import 'package:flutter/material.dart';
import '../../../../../../core/app_export.dart';

class StepGender extends StatefulWidget {
  final Function(String) onGenderSelected;
  final String? selectedGender;

  const StepGender({
    super.key,
    required this.onGenderSelected,
    this.selectedGender,
  });

  @override
  State<StepGender> createState() => _StepGenderState();
}

class _StepGenderState extends State<StepGender> {
  String? selectedGender;



  @override
  void initState() {
    super.initState();
    selectedGender = widget.selectedGender;
  }

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
    widget.onGenderSelected(gender);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            context.i18n.auth.register.steps.gender.question,
            style: AppTypography.h3.copyWith(
              color: AppColors.getText(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          

          Text(
            context.i18n.auth.register.steps.gender.description,
            style: AppTypography.bodyLRegular.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 24),

          // Gender
          Builder(
            builder: (context) {
              final genderOptions = Genders.getOptions(context);
              return Column(
                children: genderOptions.entries.map((entry) => Column(
                  children: [
                    RadioBox(
                      title: entry.value,
                      value: entry.key,
                      isSelected: selectedGender == entry.key,
                      onTap: () => _selectGender(entry.key),
                    ),
                    if (entry.key != genderOptions.keys.last) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: AppColors.getSurface(context),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                )).toList(),
              );
            },
          ),

          const SizedBox(height: 16),

        ],
      ),
    );
  }


}
