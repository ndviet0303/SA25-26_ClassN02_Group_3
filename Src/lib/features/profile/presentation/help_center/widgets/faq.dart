import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/utils/data/data.dart';

class HelpCenterCategoryTags extends StatelessWidget {
  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  const HelpCenterCategoryTags({
    super.key,
    required this.categories,
    required this.activeIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final isActive = index == activeIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index == categories.length - 1 ? 0 : 12,
            ),
            child: Tag(
              text: categories[index],
              isSelected: isActive,
              onTap: () => onSelected(index),
              backgroundColor: Colors.transparent,
              textColor: AppColors.getText(context).withOpacity(0.7),
              selectedTextColor: Colors.white,
              borderColor: AppColors.primary500,
              selectedBorderColor: AppColors.primary500,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          );
        }),
      ),
    );
  }
}

class HelpCenterSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onQueryChanged;
  final VoidCallback? onFilter;
  final String? hintText;

  const HelpCenterSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onQueryChanged,
    this.onFilter,
    this.hintText,
  });

  @override
  State<HelpCenterSearchBar> createState() => _HelpCenterSearchBarState();
}

class _HelpCenterSearchBarState extends State<HelpCenterSearchBar> {
  bool _hasQuery = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _hasQuery = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_handleChange);
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _handleChange() {
    final next = widget.controller.text.isNotEmpty;
    if (next != _hasQuery) {
      setState(() => _hasQuery = next);
    }
    widget.onQueryChanged?.call(widget.controller.text);
  }

  void _clear() {
    widget.controller.clear();
    widget.focusNode.unfocus();
    setState(() => _hasQuery = false);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final surface = AppColors.getSurface(context);

    return Container(
      decoration: BoxDecoration(
        color: _isFocused ? AppColors.trOrange : surface,
        borderRadius: BorderRadius.circular(16),
        border: _isFocused
            ? Border.all(color: AppColors.primary500, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          SvgPicture.asset(
            ImageConstant.searchIcon,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              textColor.withOpacity(0.4),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText ?? context.i18n.common.search,
                border: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacity(0.4),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _hasQuery ? _clear : widget.onFilter,
            icon: SvgPicture.asset(
              _hasQuery ? ImageConstant.closeIcon : ImageConstant.filterIcon,
              width: _hasQuery ? 16 : 20,
              height: _hasQuery ? 16 : 20,
              colorFilter: ColorFilter.mode(
                _hasQuery
                    ? AppColors.getText(context)
                    : textColor.withOpacity(0.6),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpCenterSuggestionList extends StatelessWidget {
  final String query;
  final List<FaqItem> faqs;
  final ValueChanged<FaqItem> onSelected;

  const HelpCenterSuggestionList({
    super.key,
    required this.query,
    required this.faqs,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final secondary = AppColors.getTextSecondary(context);
    final surface = AppColors.getSurface(context);

    final lowerQuery = query.toLowerCase();
    final filteredFaqs = faqs
        .where((item) => item.question.toLowerCase().contains(lowerQuery))
        .toList();

    if (filteredFaqs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ListView.separated(
            itemCount: filteredFaqs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: secondary.withOpacity(0.1)),
            itemBuilder: (context, index) {
              final faq = filteredFaqs[index];
              return InkWell(
                onTap: () => onSelected(faq),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Icon(
                        Icons.north_east,
                        size: 16,
                        color: AppColors.primary500,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HelpCenterFilterBanner extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  final String? clearLabel;

  const HelpCenterFilterBanner({
    super.key,
    required this.label,
    required this.onClear,
    this.clearLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.trOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary500.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: Text(clearLabel ?? context.i18n.common.clear),
          ),
        ],
      ),
    );
  }
}

class HelpCenterFaqTile extends StatelessWidget {
  final FaqItem faq;
  final bool isExpanded;
  final VoidCallback onPressed;

  const HelpCenterFaqTile({
    super.key,
    required this.faq,
    required this.isExpanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final secondaryColor = AppColors.getTextSecondary(context);
    final surface = AppColors.getSurface(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    faq.question,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primary500,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  faq.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryColor,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
