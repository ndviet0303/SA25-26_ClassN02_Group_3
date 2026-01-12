import 'package:flutter/material.dart';
import 'package:movie_fe/core/app_export.dart';

class HelpCenterTabs extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const HelpCenterTabs({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textColor = AppColors.getText(context);

    return Row(
      children: List.generate(tabs.length, (index) {
        final isActive = index == activeIndex;
        return Expanded(
          child: InkWell(
            onTap: () => onTabSelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabs[index],
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.primary500
                        : textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary500 : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
