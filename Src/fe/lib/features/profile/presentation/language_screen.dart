import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/features/profile/models/language_settings.dart';
import 'package:movie_fe/features/profile/notifiers/language_notifier.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final textColor = AppColors.getText(context);
    final secondaryColor = AppColors.getTextSecondary(context);
    final languageState = ref.watch(languageNotifierProvider);
    final selected = languageState.value?.selected ?? LanguageSettings.defaults.selected;
    final t = context.i18n;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          t.profile.language.title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: ContentWrappers.page(
        context,
        child: languageState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              t.profile.language.loadError(error: error.toString()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
          data: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LanguageSection(
                title: t.profile.language.sectionSuggested,
                items: Languages.suggested,
                selectedValue: selected,
                onSelected: (value) =>
                    ref.read(languageNotifierProvider.notifier).select(value),
              ),
              const SizedBox(height: 24),
              _LanguageSection(
                title: t.profile.language.sectionOthers,
                items: Languages.others,
                selectedValue: selected,
                onSelected: (value) =>
                    ref.read(languageNotifierProvider.notifier).select(value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  final String title;
  final List<DropdownItem> items;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _LanguageSection({
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textColor = AppColors.getText(context);
    final secondaryColor = AppColors.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = item.value == selectedValue;
          return Column(
            children: [
              InkWell(
                onTap: () => onSelected(item.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: textTheme.bodyLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _SelectionIndicator(isSelected: isSelected),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1)
                Divider(height: 1, color: secondaryColor.withOpacity(0.1)),
            ],
          );
        }),
      ],
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final secondaryColor = AppColors.getTextSecondary(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColors.primary500
              : secondaryColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isSelected ? 1 : 0,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.primary500,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
