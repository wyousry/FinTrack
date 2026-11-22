
import 'dart:ui' as ui;

import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/routing/app_router.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/formatters.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/app_header_bar.dart';
import 'package:fintrack/core/widgets/confirmation_dialog.dart';
import 'package:fintrack/core/widgets/error_state.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:fintrack/features/transactions/view/category_style.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_details_cubit.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionDetailsCubit(
        authRepository: context.read<AuthRepository>(),
        transactionRepository: context.read<TransactionRepository>(),
      )..start(transactionId),
      child: const _DetailsView(),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _onStateChanged(BuildContext context, TransactionDetailsState state) {
    if (state.status == TransactionDetailsStatus.notFound) {
      _showMessage(
        context,
        state.isDeleting ? 'Transaction deleted' : 'This transaction no longer exists',
      );
      _close(context);
    } else if (state.status == TransactionDetailsStatus.loaded &&
        state.errorMessage != null) {
      _showMessage(context, state.errorMessage!, isError: true);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<TransactionDetailsCubit>();
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Transaction?',
      message: 'Are you sure you want to delete this transaction?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed) cubit.delete();
  }

  Future<void> _copyReference(BuildContext context, String reference) async {
    await Clipboard.setData(ClipboardData(text: reference));
    if (!context.mounted) return;
    _showMessage(context, 'Reference copied');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionDetailsCubit>();
    final topPadding = MediaQuery.paddingOf(context).top + AppHeaderBar.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<TransactionDetailsCubit, TransactionDetailsState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status || prev.errorMessage != curr.errorMessage,
        listener: _onStateChanged,
        builder: (context, state) {
          final transaction = state.transaction;
          final Widget body;

          if (state.status == TransactionDetailsStatus.failure) {
            body = Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: ErrorState(
                message: state.errorMessage ?? 'Please try again.',
                onRetry: cubit.retry,
              ),
            );
          } else if (transaction == null) {
            body = const Center(child: CircularProgressIndicator());
          } else {
            body = SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 32),
              child: Column(
                children: [
                  _HeroCard(transaction: transaction),
                  const SizedBox(height: 16),
                  _ActionsRow(
                    onEdit: () => context.push(
                      AppRoutes.editTransactionPath(transaction.id),
                    ),
                    onDuplicate: () => context.push(
                      AppRoutes.addTransaction,
                      extra: transaction,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MetadataCard(
                    transaction: transaction,
                    onCopy: (reference) => _copyReference(context, reference),
                  ),
                  const SizedBox(height: 16),
                  _DeleteButton(
                    isDeleting: state.isDeleting,
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Positioned.fill(child: body),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppHeaderBar(
                  title: 'Transaction Details',
                  onBack: () => _close(context),
                  trailing: IconButton(
                    onPressed: () => _close(context),
                    tooltip: 'Done',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                    icon: const Icon(Icons.check_rounded, size: 20, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final style = CategoryStyle.of(t.categoryId);
    final amountColor = t.isIncome ? AppColors.positive : AppColors.negative;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              right: -48,
              top: -48,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.avatarBg.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: style.tint,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Icon(style.icon, size: 26, color: style.iconColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 4),
                    _SoftPill(
                      icon: style.icon,
                      label: t.categoryName,
                      iconColor: AppColors.textSecondary,
                      textStyle: AppTextStyles.label,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Formatters.signedCurrency(t.signedAmount),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.9,
                        height: 44 / 36,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SoftPill(
                      icon: Icons.check_circle_rounded,
                      label: 'Completed',
                      iconColor: AppColors.positive,
                      textStyle: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.positive,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      iconSize: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textStyle,
    required this.padding,
    this.iconSize = 12,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.onEdit, required this.onDuplicate});

  final VoidCallback onEdit;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.content_copy_outlined,
            label: 'Duplicate',
            onTap: onDuplicate,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      radius: 12,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.lavender,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.slate),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}


class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.transaction, required this.onCopy});

  final TransactionModel transaction;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final shortId = t.id.length > 8 ? t.id.substring(0, 8) : t.id;
    final reference = '#FT-${shortId.toUpperCase()}';
    final typeColor = t.isExpense ? AppColors.negative : AppColors.positive;

    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: 12,
      child: Column(
        children: [
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date & Time',
            value: Text(
              Formatters.detailsDateTime(t.date),
              style: AppTextStyles.body,
            ),
          ),
          const _MetaDivider(),
          _MetaRow(
            icon: Icons.swap_horiz_rounded,
            label: 'Type',
            value: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: t.isExpense ? AppColors.expenseTint : AppColors.mintStrong,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t.isExpense ? Icons.north_east_rounded : Icons.south_west_rounded,
                    size: 10,
                    color: typeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t.isExpense ? 'Expense' : 'Income',
                    style: AppTextStyles.body.copyWith(color: typeColor),
                  ),
                ],
              ),
            ),
          ),
          const _MetaDivider(),
          _MetaRow(
            icon: Icons.tag_rounded,
            label: 'Reference',
            value: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => onCopy(reference),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.copy_rounded, size: 14, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: value),
        ),
      ],
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, thickness: 1, color: AppColors.avatarBg),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.isDeleting, required this.onTap});

  final bool isDeleting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.expenseTint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Center(
            child: isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.negative,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.negative),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Transaction',
                        style: AppTextStyles.body.copyWith(color: AppColors.negative),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}