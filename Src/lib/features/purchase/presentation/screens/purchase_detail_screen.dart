import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/image_utils.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../models/transaction_item.dart';
import '../../../../routes/app_router.dart';

class PurchaseDetailScreen extends ConsumerWidget {
  final String movieId;

  const PurchaseDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);
    final surfaceColor = AppColors.getSurface(context);

    final purchaseInfoAsync = ref.watch(purchaseInfoProvider(movieId));
    final transactionsAsync = ref.watch(movieTransactionsProvider(movieId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.i18n.purchaseDetail.title),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purchase Info Section
            purchaseInfoAsync.when(
              data: (purchaseInfo) {
                if (purchaseInfo == null) {
                  return _buildNotFound(context, theme, textColor);
                }
                return _buildPurchaseInfo(
                  context,
                  theme,
                  textColor,
                  secondaryText,
                  surfaceColor,
                  purchaseInfo,
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _buildError(context, theme, error),
            ),

            const Gap(24),

            // Transactions Section
            Text(
              context.i18n.purchaseDetail.labels.transactions,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const Gap(16),

            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return _buildEmptyTransactions(context, theme, secondaryText);
                }
                return _buildTransactionsList(context, theme, textColor, secondaryText, surfaceColor, transactions);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _buildError(context, theme, error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseInfo(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
    Color surfaceColor,
    Map<String, dynamic> purchaseInfo,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.i18n.purchaseDetail.infoTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const Gap(16),
          _buildInfoRow(theme, textColor, secondaryText, context.i18n.purchaseDetail.labels.movieId, purchaseInfo['movieId']?.toString() ?? 'N/A'),
          if (purchaseInfo['isDownloaded'] != null) ...[
            const Gap(12),
            _buildInfoRow(
              theme,
              textColor,
              secondaryText,
              context.i18n.purchaseDetail.labels.downloaded,
              purchaseInfo['isDownloaded'] == true ? context.i18n.common.yes : context.i18n.common.no,
            ),
          ],
          if (purchaseInfo['isFinished'] != null) ...[
            const Gap(12),
            _buildInfoRow(
              theme,
              textColor,
              secondaryText,
              context.i18n.purchaseDetail.labels.finished,
              purchaseInfo['isFinished'] == true ? context.i18n.common.yes : context.i18n.common.no,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
    Color surfaceColor,
    List<TransactionItem> transactions,
  ) {
    return Column(
      children: transactions.asMap().entries.map((entry) {
        final index = entry.key;
        final transaction = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index < transactions.length - 1 ? 12 : 0),
          child: _buildTransactionCard(context, theme, textColor, secondaryText, surfaceColor, transaction),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
    Color surfaceColor,
    TransactionItem transaction,
  ) {
    final statusColor = _getStatusColor(transaction.status, secondaryText);
    final statusIcon = _getStatusIcon(transaction.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Transaction #${transaction.id.substring(0, 8)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (statusIcon != null) ...[
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      _localizedStatus(context, transaction.status).toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          _buildInfoRow(theme, textColor, secondaryText, context.i18n.purchaseDetail.labels.amount, '\$${transaction.amount.toStringAsFixed(2)} ${transaction.currency.toUpperCase()}'),
          if (transaction.createdAt != null) ...[
            const Gap(8),
            _buildInfoRow(theme, textColor, secondaryText, context.i18n.purchaseDetail.labels.created, transaction.createdAt!.toString()),
          ],
          if (transaction.paidAt != null) ...[
            const Gap(8),
            _buildInfoRow(theme, textColor, secondaryText, context.i18n.purchaseDetail.labels.paidAt, transaction.paidAt!.toString()),
          ],
          if (transaction.failedAt != null) ...[
            const Gap(8),
            _buildInfoRow(theme, textColor, secondaryText, context.i18n.purchaseDetail.labels.failedAt, transaction.failedAt!.toString()),
          ],
          if (transaction.canceledAt != null) ...[
            const Gap(8),
            _buildInfoRow(theme, textColor, secondaryText, context.i18n.purchaseDetail.labels.canceledAt, transaction.canceledAt!.toString()),
          ],
          if (transaction.stripePaymentIntentId != null) ...[
            const Gap(8),
            _buildInfoRow(theme, textColor, secondaryText, context.i18n.purchaseDetail.labels.paymentIntent, transaction.stripePaymentIntentId ?? 'N/A'),
          ],
          if (transaction.chargeId != null) ...[
            const Gap(8),
            _buildInfoRow(theme, textColor, secondaryText, context.i18n.purchaseDetail.labels.chargeId, transaction.chargeId ?? 'N/A'),
          ],
          if (transaction.errorMessage != null) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 20, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaction.errorMessage ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, Color textColor, Color secondaryText, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFound(BuildContext context, ThemeData theme, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 64, color: textColor.withOpacity(0.5)),
            const Gap(16),
            Text(
              context.i18n.purchaseDetail.empty.purchaseNotFound,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context, ThemeData theme, Color secondaryText) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: secondaryText.withOpacity(0.5)),
            const Gap(16),
            Text(
              context.i18n.purchaseDetail.empty.transactions,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ThemeData theme, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.warning),
            const Gap(8),
            Text(
              '${context.i18n.purchaseDetail.error.generic} ${error.toString()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.warning,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, Color defaultColor) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return AppColors.success;
      case 'failed':
        return AppColors.warning;
      case 'canceled':
        return defaultColor;
      case 'pending':
        return AppColors.primary500;
      default:
        return defaultColor;
    }
  }

  IconData? _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'canceled':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return null;
    }
  }

  String _localizedStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return context.i18n.purchaseDetail.states.succeeded;
      case 'failed':
        return context.i18n.purchaseDetail.states.failed;
      case 'canceled':
        return context.i18n.purchaseDetail.states.canceled;
      case 'pending':
        return context.i18n.purchaseDetail.states.pending;
      default:
        return status;
    }
  }

  String _formatDateTimeFromMap(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime? date;
    if (timestamp is DateTime) {
      date = timestamp;
    } else if (timestamp is Map) {
      final seconds = timestamp['_seconds'] ?? timestamp['seconds'];
      if (seconds != null) {
        date = DateTime.fromMillisecondsSinceEpoch((seconds as int) * 1000);
      }
    }
    if (date == null) return 'N/A';
    return _formatDateTime(date);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
