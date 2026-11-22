import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/routing/app_router.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/formatters.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/app_header_bar.dart';
import 'package:fintrack/core/widgets/confirmation_dialog.dart';
import 'package:fintrack/core/widgets/error_state.dart';
import 'package:fintrack/core/widgets/primary_button.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/transactions/model/category.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:fintrack/features/transactions/view/category_picker_screen.dart';
import 'package:fintrack/features/transactions/view/category_style.dart';
import 'package:fintrack/features/transactions/view/widgets/edit_amount_card.dart';
import 'package:fintrack/features/transactions/view/widgets/type_segmented_control.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_details_cubit.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_details_state.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_form_cubit.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void _close(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
  }
}

void _showMessage(BuildContext context, String message, {Color? color}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionDetailsCubit(
        authRepository: context.read<AuthRepository>(),
        transactionRepository: context.read<TransactionRepository>(),
      )..start(transactionId),
      child: const _EditLoader(),
    );
  }
}

class _EditLoader extends StatelessWidget {
  const _EditLoader();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + AppHeaderBar.height;

    return BlocConsumer<TransactionDetailsCubit, TransactionDetailsState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == TransactionDetailsStatus.notFound) {
          _showMessage(context, 'This transaction no longer exists');
          _close(context);
        }
      },
      builder: (context, state) {
        final transaction = state.transaction;
        if (transaction != null) return _EditForm(transaction: transaction);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Positioned.fill(
                child: state.status == TransactionDetailsStatus.failure
                    ? Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: ErrorState(
                          message: state.errorMessage ?? 'Please try again.',
                          onRetry: context.read<TransactionDetailsCubit>().retry,
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppHeaderBar(
                  title: 'Edit Transaction',
                  onBack: () => _close(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionFormCubit(
        authRepository: context.read<AuthRepository>(),
        transactionRepository: context.read<TransactionRepository>(),
        editing: transaction,
      ),
      child: const _EditFormView(),
    );
  }
}

class _EditFormView extends StatefulWidget {
  const _EditFormView();

  @override
  State<_EditFormView> createState() => _EditFormViewState();
}

class _EditFormViewState extends State<_EditFormView> {
  static const int _maxNoteLength = 200;

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<TransactionFormCubit>();
    _amountController = TextEditingController(text: cubit.state.amountText);
    _noteController = TextEditingController(text: cubit.initialNote);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }


  Future<void> _pickCategory() async {
    final cubit = context.read<TransactionFormCubit>();
    final picked = await context.push<Category>(
      AppRoutes.selectCategory,
      extra: CategoryPickerArgs(
        type: cubit.state.type,
        selectedId: cubit.state.category?.id,
      ),
    );
    if (picked != null) cubit.categorySelected(picked);
  }

  Future<void> _pickDateTime() async {
    final cubit = context.read<TransactionFormCubit>();
    final current = cubit.state.date;
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: current.isAfter(now) ? now : current,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;

    cubit.dateChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }


  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<TransactionFormCubit>().save(note: _noteController.text);
  }

  Future<void> _discard() async {
    final cubit = context.read<TransactionFormCubit>();
    if (!cubit.hasChanges(note: _noteController.text)) {
      _close(context);
      return;
    }

    final confirmed = await showConfirmationDialog(
      context,
      title: 'Discard changes?',
      message: 'Your changes will not be saved.',
      confirmLabel: 'Discard',
      destructive: true,
    );
    if (confirmed && mounted) _close(context);
  }

  void _onStateChanged(BuildContext context, TransactionFormState state) {
    if (state.status == TransactionFormStatus.success) {
      _showMessage(context, 'Changes saved', color: AppColors.success);
      _close(context);
    } else if (state.status == TransactionFormStatus.failure) {
      _showMessage(
        context,
        state.errorMessage ?? 'Something went wrong.',
        color: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + AppHeaderBar.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<TransactionFormCubit, TransactionFormState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: _onStateChanged,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 32),
                child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
                  builder: (context, state) {
                    final cubit = context.read<TransactionFormCubit>();
                    return Column(
                      children: [
                        TypeSegmentedControl(
                          variant: SegmentedVariant.softArrows,
                          type: state.type,
                          onChanged: cubit.typeChanged,
                        ),
                        const SizedBox(height: 24),
                        EditAmountCard(
                          controller: _amountController,
                          onChanged: cubit.amountChanged,
                          errorText: state.amountError,
                        ),
                        const SizedBox(height: 20),
                        _Labeled(
                          label: 'Category',
                          errorText: state.categoryError,
                          child: _buildCategoryCard(state),
                        ),
                        const SizedBox(height: 12),
                        _Labeled(
                          label: 'Date & Time',
                          errorText: state.dateError,
                          child: _buildDateCard(state),
                        ),
                        const SizedBox(height: 12),
                        _Labeled(label: 'Notes', child: _buildNotesCard()),
                        const SizedBox(height: 24),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Color(0x1A000000), blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
                              BoxShadow(color: Color(0x1A000000), blurRadius: 4, spreadRadius: -2, offset: Offset(0, 2)),
                            ],
                          ),
                          child: PrimaryButton(
                            label: 'Save Changes',
                            leadingIcon: Icons.check_circle_outline_rounded,
                            height: 52,
                            isLoading: state.isSaving,
                            onPressed: _submit,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: TextButton.icon(
                            onPressed: _discard,
                            icon: const Icon(Icons.undo_rounded, size: 16),
                            label: Text(
                              'Discard Changes',
                              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppHeaderBar(
                title: 'Edit Transaction',
                onBack: _discard,
                trailing: IconButton(
                  onPressed: _submit,
                  tooltip: 'Save',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                  icon: const Icon(Icons.check_rounded, size: 20, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(TransactionFormState state) {
    final category = state.category;
    final style = category == null ? null : CategoryStyle.of(category.id);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      radius: 12,
      onTap: _pickCategory,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style?.tint ?? AppColors.lavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                style?.icon ?? Icons.category_outlined,
                size: 18,
                color: style?.iconColor ?? AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Choose a category',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: category == null ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  if (category != null && category.description.isNotEmpty)
                    Text(
                      category.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
            const Text('Change', style: AppTextStyles.label),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(TransactionFormState state) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      radius: 12,
      onTap: _pickDateTime,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.slate),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Formatters.fullDate(state.date), style: AppTextStyles.body),
                  Text(Formatters.time(state.date), style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_outlined, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      radius: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.edit_note_rounded, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _noteController,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(_maxNoteLength)],
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Add a note (optional)',
                    hintStyle: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _noteController,
                    builder: (context, value, _) => Text(
                      '${value.text.length}/$_maxNoteLength',
                      style: AppTextStyles.caption,
                    ),
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

/// عنوان صغير فوق الكارت (زي Figma)
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child, this.errorText});

  final String label;
  final Widget child;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(label, style: AppTextStyles.label),
        ),
        const SizedBox(height: 4),
        child,
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Text(
              errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.negative),
            ),
          ),
      ],
    );
  }
}