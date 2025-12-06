import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie.dart';
import 'package:gap/gap.dart';

class MovieInfoPanel extends StatelessWidget {
  const MovieInfoPanel({
    super.key,
    required this.movie,
    this.onEpisodeSelected,
    this.onTrailerSelected,
  });

  final Movie movie;
  final void Function(String url)? onEpisodeSelected;
  final void Function(String url)? onTrailerSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (movie.originName.isNotEmpty && movie.originName != movie.title) ...[
          const Gap(6),
          Text(
            movie.originName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const Gap(8),
        if (movie.directorString.isNotEmpty)
          Text(
            movie.directorString,
            style: theme.textTheme.bodyLarge?.copyWith(color: secondaryText),
          ),
        const Gap(12),
        Row(
          children: [
            Icon(Icons.star, color: AppColors.primary500, size: 18),
            const Gap(6),
            Text(
              (movie.rating ?? 0.0).toStringAsFixed(1),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            Text('(${movie.ratingCount ?? 0})', style: theme.textTheme.bodySmall?.copyWith(color: secondaryText)),
            const Spacer(),
            if (movie.view != null)
              Row(
                children: [
                  const Icon(Icons.visibility, size: 16, color: Colors.grey),
                  const Gap(4),
                  Text(movie.viewsString, style: theme.textTheme.bodySmall?.copyWith(color: secondaryText)),
                ],
              ),
          ],
        ),
        const Gap(16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (movie.year != null) _badge(context, '${movie.year}'),
            if (movie.time != null && movie.time!.isNotEmpty) _badge(context, movie.time!),
            if (movie.lang != null && movie.lang!.isNotEmpty) _badge(context, movie.lang!),
            if (movie.status.isNotEmpty) _badge(context, movie.status),
            if ((movie.episodeTotal ?? '').isNotEmpty)
              _badge(context, '${context.i18n.movie.info.episodesPrefix}: ${movie.episodeTotal}')
            else if ((movie.episodeCurrent ?? '').isNotEmpty)
              _badge(context, '${context.i18n.movie.info.episodePrefix}: ${movie.episodeCurrent}'),
          ],
        ),
        const Gap(16),
        // Episodes list (show above genres)
        if ((movie.episodes ?? []).isNotEmpty) ...[
          Text(
            context.i18n.movie.info.episodesList,
            style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          _buildEpisodes(context, theme),
          const Gap(16),
        ],

        // Language explicit label
        if ((movie.lang ?? '').isNotEmpty) ...[
          Text(
            context.i18n.movie.info.language,
            style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          _badge(context, movie.lang!),
          const Gap(16),
        ],

        if (movie.genres.isNotEmpty) ...[
          Text(
            context.i18n.movie.info.genres,
            style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.genres
                .map((genre) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.getSurface(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(genre, style: theme.textTheme.bodySmall?.copyWith(color: textColor)),
                    ))
                .toList(),
          ),
        ],
        const Gap(16),
        if ((movie.country ?? []).isNotEmpty) ...[
          Text(
            context.i18n.movie.info.countries,
            style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.country!
                .map((e) => e['name']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .map((name) => _badge(context, name))
                .toList(),
          ),
          const Gap(16),
        ],

        // Directors
        if ((movie.director ?? []).where((e) => (e ?? '').toString().isNotEmpty).isNotEmpty) ...[
          Text(
            context.i18n.movie.info.directors,
            style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (movie.director ?? [])
                .where((e) => (e ?? '').toString().isNotEmpty)
                .map((name) => _badge(context, (name ?? '').toString()))
                .toList(),
          ),
          const Gap(16),
        ],

        // Actors
        if ((movie.actor ?? []).where((e) => (e ?? '').toString().isNotEmpty).isNotEmpty) ...[
          Text(
            context.i18n.movie.info.actors,
            style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (movie.actor ?? [])
                .where((e) => (e ?? '').toString().isNotEmpty)
                .map((name) => _badge(context, (name ?? '').toString()))
                .toList(),
          ),
          const Gap(16),
        ],


        Text(
          context.i18n.movie.info.aboutThisFilm,
          style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
        ),
        const Gap(12),
        Builder(
          builder: (_) {
            final raw = movie.content ?? movie.description;
            final spans = _buildDescriptionSpans(raw, theme, secondaryText);
            return RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryText, height: 1.5),
                children: spans,
              ),
            );
          },
        ),

        if ((movie.trailerUrl ?? '').isNotEmpty) ...[
          const Gap(16),
          Text(
            context.i18n.movie.info.trailer,
            style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: onTrailerSelected == null ? null : () => onTrailerSelected!(movie.trailerUrl!),
              icon: const Icon(Icons.play_arrow, size: 20),
              label: Text(context.i18n.movie.info.watchTrailer),
            ),
          ),
        ],
      ],
    );
  }

  Widget _badge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getLine(context)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.getText(context),
        ),
      ),
    );
  }

  Widget _buildEpisodes(BuildContext context, ThemeData theme) {
    final episodes = _extractEpisodeList();
    if (episodes.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: episodes.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (context, index) {
          final ep = episodes[index];
          return InkWell(
            onTap: ep.url != null && onEpisodeSelected != null ? () => onEpisodeSelected!(ep.url!) : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.getLine(context)),
              ),
              child: Text(
                'Tập ${_displayEpisodeNumber(ep.name, index)}',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.getText(context), fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  List<_EpisodeEntry> _extractEpisodeList() {
    final result = <_EpisodeEntry>[];
    final eps = movie.episodes ?? [];
    if (eps.isEmpty) return result;
    final first = eps.first;
    if (first['server_data'] is List) {
      final serverData = first['server_data'] as List;
      for (final item in serverData) {
        final map = (item as Map).map((k, v) => MapEntry(k.toString(), v));
        final m3u8 = map['link_m3u8']?.toString();
        final embed = map['link_embed']?.toString();
        final url = (m3u8 != null && m3u8.isNotEmpty) ? m3u8 : (embed ?? '');
        result.add(_EpisodeEntry(name: map['name']?.toString(), url: url.isNotEmpty ? url : null));
      }
    }
    return result;
  }

  String _displayEpisodeNumber(String? rawName, int index) {
    if (rawName == null || rawName.trim().isEmpty) {
      return (index + 1).toString();
    }
    final n = int.tryParse(rawName.trim());
    if (n == null) return rawName;
    return (n <= 0 ? 1 : n).toString();
  }
}

class _EpisodeEntry {
  _EpisodeEntry({this.name, this.url});
  final String? name;
  final String? url;
}

List<TextSpan> _buildDescriptionSpans(String raw, ThemeData theme, Color textColor) {
  var text = raw
      .replaceAll(RegExp(r'</?p[^>]*>', caseSensitive: false), '')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .trim();

  final spans = <TextSpan>[];
  final regex = RegExp(r'(<strong[^>]*>)(.*?)(</strong>)', caseSensitive: false, dotAll: true);
  int lastIndex = 0;
  for (final match in regex.allMatches(text)) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
    }
    final boldText = match.group(2) ?? '';
    spans.add(TextSpan(
      text: boldText,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
    ));
    lastIndex = match.end;
  }
  if (lastIndex < text.length) {
    spans.add(TextSpan(text: text.substring(lastIndex)));
  }
  return spans;
}



