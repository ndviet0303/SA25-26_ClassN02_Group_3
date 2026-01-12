import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/widgets/feedback/toast_notification.dart';
import '../../../../core/services/stripe_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.movie,
  });

  final Movie movie;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    final price = widget.movie.priceValue ?? 0.0;
    final isFree = price == 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.i18n.purchase.checkout.title),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  // Movie Summary
                  _buildMovieSummary(context, theme, textColor),
                  const Gap(24),
                  // Price Details
                  _buildPriceDetails(context, theme, textColor, secondaryText, price),
                  const Gap(24),
                  // Payment Method Selection
                  if (!isFree) ...[
                    _buildSectionTitle(context.i18n.purchase.checkout.section.paymentMethod, theme, textColor),
                    const Gap(12),
                    _buildVisaOption(context, theme, textColor),
                  ],
                ],
              ),
            ),
          ),
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.i18n.purchase.checkout.labels.total,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryText,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            isFree ? context.i18n.purchase.common.free : '\$${price.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 200,
                        child: PrimaryButton(
                          text: _isProcessing ? context.i18n.purchase.checkout.actions.processing : (isFree ? context.i18n.purchase.checkout.actions.confirm : context.i18n.purchase.checkout.actions.payNow),
                          onPressed: _isProcessing ? null : () => _processPayment(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieSummary(BuildContext context, ThemeData theme, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 16,
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.movie.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  widget.movie.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.movie.rating != null) ...[
                  Row(
                    spacing: 8,
                    children: [
                      SvgPicture.asset(
                        ImageConstant.groupIcon,
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(AppColors.primary500, BlendMode.srcIn),
                      ),
                      Text(
                        widget.movie.rating!.toStringAsFixed(1),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(BuildContext context, ThemeData theme, Color textColor, Color secondaryText, double price) {
    if (price == 0.0) {
      return _buildSectionTitle(context.i18n.purchase.checkout.section.priceDetails, theme, textColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.i18n.purchase.checkout.section.priceDetails, theme, textColor),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getSurface(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            spacing: 12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.i18n.purchase.checkout.labels.price,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryText,
                    ),
                  ),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.i18n.purchase.checkout.labels.total,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme, Color textColor) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  Widget _buildVisaOption(BuildContext context, ThemeData theme, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary500,
          width: 2,
        ),
      ),
      child: Row(
        spacing: 16,
        children: [
          SvgPicture.asset(
            ImageConstant.visaIcon,
            width: 40,
            height: 40,
          ),
          Expanded(
            child: Text(
              context.i18n.purchase.checkout.labels.visa,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Radio<String>(
            value: 'visa',
            groupValue: 'visa',
            onChanged: (_) {},
            activeColor: AppColors.primary500,
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    if (_isProcessing) return;

    final price = widget.movie.priceValue ?? 0.0;
    if (price == 0.0) {
      if (context.mounted) {
        Navigator.of(context).pop(true);
        ToastNotification.showSuccess(
          context,
          message: context.i18n.purchase.checkout.toasts.addedSuccess,
          duration: const Duration(seconds: 3),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final stripeService = ref.read(stripeServiceProvider);

      // Step 1: Create Payment Intent via backend
      final paymentIntent = await stripeService.createPaymentIntent(
        movieId: widget.movie.id,
        amount: price,
        movieTitle: widget.movie.title,
        movieImageUrl: widget.movie.imageUrl,
        movieSlug: widget.movie.slug,
      );

      // Step 2: Present Stripe Payment Sheet
      await stripeService.presentPaymentSheet(
        clientSecret: paymentIntent.clientSecret,
        ephemeralKeySecret: paymentIntent.ephemeralKey,
        customerId: paymentIntent.customerId,
      );

      // Step 3: Wait for webhook to update Firestore, then check transaction status
      final transactionStatus = await _waitForTransactionStatus(
        stripeService,
        paymentIntent.transactionId,
      );

      if (context.mounted) {
        if (transactionStatus.isSuccess) {
          Navigator.of(context).pop(true);
          ToastNotification.showSuccess(
            context,
            message: context.i18n.purchase.checkout.toasts.paymentSuccess,
            duration: const Duration(seconds: 3),
          );
        } else if (transactionStatus.isFailed) {
          ToastNotification.showError(
            context,
            message: transactionStatus.errorMessage ?? context.i18n.purchase.checkout.toasts.paymentFailed,
            duration: const Duration(seconds: 3),
          );
        } else if (transactionStatus.isCanceled) {
          ToastNotification.showInfo(
            context,
            message: context.i18n.purchase.checkout.toasts.paymentCanceled,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      final errorMessage = e.toString();
      if (context.mounted) {
        if (errorMessage.contains('canceled') || errorMessage.contains('Payment canceled')) {
          // User canceled - don't show error
          return;
        }
        ToastNotification.showError(
          context,
          message: '${context.i18n.purchase.common.errorPrefix} ${errorMessage.replaceAll('Exception: ', '')}',
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Wait for transaction status to be updated by webhook
  Future<TransactionStatus> _waitForTransactionStatus(
    StripeService stripeService,
    String transactionId, {
    int maxAttempts = 20,
    Duration interval = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final status = await stripeService.getTransactionStatus(transactionId);
        if (status.isSuccess || status.isFailed || status.isCanceled) {
          return status;
        }
        await Future.delayed(interval);
      } catch (e) {
        if (i == maxAttempts - 1) {
          rethrow;
        }
        await Future.delayed(interval);
      }
    }
    throw Exception('Transaction status timeout');
  }
}

