import 'package:flutter/material.dart';
import '../../../../../../core/app_export.dart';

class StepGenre extends StatefulWidget {
  final Function(List<String>) onGenresSelected;
  final List<String>? selectedGenres;

  const StepGenre({
    super.key,
    required this.onGenresSelected,
    this.selectedGenres,
  });

  @override
  State<StepGenre> createState() => _StepGenreState();
}

class _StepGenreState extends State<StepGenre> {
  List<String> selectedGenres = [];



  @override
  void initState() {
    super.initState();
    selectedGenres = widget.selectedGenres ?? [];
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
      }
    });
    widget.onGenresSelected(selectedGenres);
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
            context.i18n.auth.register.steps.genres.title,
            style: AppTypography.h3.copyWith(
              color: AppColors.getText(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            context.i18n.auth.register.steps.genres.description,
            style: AppTypography.bodyLRegular.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),

          const SizedBox(height: 32),

          Builder(
            builder: (context) {
              final genreOptions = Genres.getOptions(context);
              return Wrap(
                spacing: 12,
                runSpacing: 16,
                children: genreOptions.entries.map((entry) => Tag(
                  text: entry.value,
                  isSelected: selectedGenres.contains(entry.key),
                  onTap: () => _toggleGenre(entry.key),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  fontSize: 14,
                )).toList(),
              );
            },
          ),

        ],
      ),
    );
  }
}
