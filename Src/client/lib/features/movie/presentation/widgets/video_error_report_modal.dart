import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/feedback/toast_notification.dart';
import '../../../../core/models/movie.dart';

class VideoErrorReportModal extends ConsumerStatefulWidget {
  const VideoErrorReportModal({
    super.key,
    required this.movie,
    required this.videoUrl,
    required this.errorMessage,
  });

  final Movie movie;
  final String? videoUrl;
  final String errorMessage;

  @override
  ConsumerState<VideoErrorReportModal> createState() => _VideoErrorReportModalState();
}

class _VideoErrorReportModalState extends ConsumerState<VideoErrorReportModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedIssueType;
  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'Video not loading',
    'Stutter/lag',
    'Poor video quality',
    'Audio issue',
    'Cannot play',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || _selectedIssueType == null) {
      if (_selectedIssueType == null && mounted) {
        ToastNotification.showError(
          context,
          message: context.i18n.movie.report.validations.selectIssue,
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('reports').add({
        'movieId': widget.movie.id,
        'movieTitle': widget.movie.title,
        'movieSlug': widget.movie.slug,
        'videoUrl': widget.videoUrl ?? '',
        'videoUrlType': widget.videoUrl?.contains('.m3u8') == true ? 'm3u8' : 'embed',
        'issueType': _selectedIssueType,
        'description': _descriptionController.text.trim(),
        'errorMessage': widget.errorMessage,
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? '',
        'userDisplayName': user?.displayName ?? '',
        'deviceInfo': {'platform': Theme.of(context).platform.toString()},
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ToastNotification.showSuccess(
          context,
          message: context.i18n.movie.report.success,
          duration: const Duration(seconds: 3),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ToastNotification.showError(
          context,
          message: '${context.i18n.movie.report.failurePrefix} $e',
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.getModalBackground(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, theme, textColor, secondaryText),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieInfo(context, theme, textColor, secondaryText),
                      const Gap(24),
                      _buildIssueTypeSection(context, theme, textColor),
                      const Gap(24),
                      _buildDescriptionField(context, theme, textColor, secondaryText),
                    ],
                  ),
                ),
              ),
              _buildFooter(context, theme, textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, Color textColor, Color secondaryText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.getLine(context)))),
      child: Row(
        children: [
          Icon(Icons.report_problem, color: AppColors.warning, size: 28),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.i18n.movie.report.headerTitle, style: theme.textTheme.titleLarge?.copyWith(color: textColor, fontWeight: FontWeight.w700)),
                Text(context.i18n.movie.report.headerSubtitle, style: theme.textTheme.bodySmall?.copyWith(color: secondaryText)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(true), color: secondaryText),
        ],
      ),
    );
  }

  Widget _buildMovieInfo(BuildContext context, ThemeData theme, Color textColor, Color secondaryText) {
    final border = Border.all(color: AppColors.getLine(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.i18n.movie.report.movieInfo, style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.getSurface(context), borderRadius: BorderRadius.circular(12), border: border),
          child: Column(
            children: [
              _buildInfoRow(context.i18n.movie.report.labels.movieName, widget.movie.title, theme, secondaryText),
              if (widget.movie.directorString.isNotEmpty) _buildInfoRow(context.i18n.movie.report.labels.director, widget.movie.directorString, theme, secondaryText),
              _buildInfoRow(context.i18n.movie.report.labels.videoUrl, widget.videoUrl ?? 'N/A', theme, secondaryText),
              _buildInfoRow(context.i18n.movie.report.labels.error, widget.errorMessage, theme, AppColors.warning),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.getTextSecondary(context)))),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall?.copyWith(color: valueColor, fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTypeSection(BuildContext context, ThemeData theme, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.i18n.movie.report.issueTypeLabel, style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _issueTypes.map((issueType) {
            final isSelected = _selectedIssueType == issueType;
            return GestureDetector(
              onTap: () => setState(() => _selectedIssueType = issueType),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary500 : AppColors.getSurface(context),
                  border: Border.all(color: isSelected ? AppColors.primary500 : AppColors.getLine(context), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  issueType,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context, ThemeData theme, Color textColor, Color secondaryText) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.getLine(context)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.i18n.movie.report.descriptionLabel, style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
        const Gap(12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: context.i18n.movie.report.descriptionHint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: secondaryText),
            filled: true,
            fillColor: AppColors.getSurface(context),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary500, width: 2)),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return context.i18n.movie.report.validations.descRequired;
            if (value.trim().length < 10) return context.i18n.movie.report.validations.descMin;
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.getLine(context)))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(context.i18n.movie.report.actions.cancel, style: theme.textTheme.bodyLarge?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
            ),
          ),
          const Gap(12),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: _isSubmitting ? context.i18n.movie.report.actions.sending : context.i18n.movie.report.actions.submit,
              onPressed: _isSubmitting ? null : _submitReport,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}

