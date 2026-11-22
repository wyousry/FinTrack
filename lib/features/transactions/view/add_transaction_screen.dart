import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/routing/app_router.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/amount_input.dart';
import 'package:fintrack/core/utils/formatters.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/core/widgets/app_header_bar.dart';
import 'package:fintrack/core/widgets/sticky_cta.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/transactions/model/category.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';
import 'package:fintrack/features/transactions/repository/transaction_repository.dart';
import 'package:fintrack/features/transactions/view/category_picker_screen.dart';
import 'package:fintrack/features/transactions/view/category_style.dart';
import 'package:fintrack/features/transactions/view/widgets/amount_card.dart';
import 'package:fintrack/features/transactions/view/widgets/transaction_field_card.dart';
import 'package:fintrack/features/transactions/view/widgets/type_segmented_control.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_form_cubit.dart';
import 'package:fintrack/features/transactions/viewmodel/transaction_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
    this.template,
  });

  final TransactionType initialType;
  final TransactionModel? template;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionFormCubit(
        authRepository: context.read<AuthRepository>(),
        transactionRepository: context.read<TransactionRepository>(),
        initialType: initialType,
        template: template,
      ),
      child: const _AddTransactionView(),
    );
  }
}
class _AddTransactionView extends StatefulWidget {
  const _AddTransactionView();

  @override
  State<_AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<_AddTransactionView> {
 late final TextEditingController _amountController;
late final TextEditingController _noteController;

@override
void initState() {
  super.initState();
  final cubit = context.read<TransactionFormCubit>();
  _amountController = TextEditingController(text: cubit.state.amountText);
  _noteController = TextEditingController(text: cubit.initialNote);
}

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _setAmount(String text) {
    _amountController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    context.read<TransactionFormCubit>().amountChanged(text);
  }

  void _quickAdd(double delta) =>
      _setAmount(AmountInput.add(_amountController.text, delta));

  void _backspace() =>
      _setAmount(AmountInput.backspace(_amountController.text));

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

  Future<void> _pickDate() async {
    final cubit = context.read<TransactionFormCubit>();
    final current = cubit.state.date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    cubit.dateChanged(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        current.hour,
        current.minute,
      ),
    );
  }

  Future<void> _pickTime() async {
    final cubit = context.read<TransactionFormCubit>();
    final current = cubit.state.date;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    cubit.dateChanged(
      DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<TransactionFormCubit>().save(note: _noteController.text);
  }

  void _onStateChanged(BuildContext context, TransactionFormState state) {
    if (state.status == TransactionFormStatus.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Transaction saved'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      _close(context);
    } else if (state.status == TransactionFormStatus.failure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Something went wrong.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 110),
                child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
                  builder: (context, state) {
                    final cubit = context.read<TransactionFormCubit>();
                    return Column(
                      children: [
                        TypeSegmentedControl(
                          type: state.type,
                          onChanged: cubit.typeChanged,
                        ),
                        const SizedBox(height: 16),
                        AmountCard(
                          type: state.type,
                          controller: _amountController,
                          onChanged: cubit.amountChanged,
                          onQuickAdd: _quickAdd,
                          onBackspace: _backspace,
                          errorText: state.amountError,
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryCard(state),
                        const SizedBox(height: 12),
                        _buildDateCard(state),
                        const SizedBox(height: 12),
                        _buildNoteCard(),
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
                title: 'Add Transaction',
                onBack: () => _close(context),
                trailing: IconButton(
                  onPressed: _submit,
                  tooltip: 'Save',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlocBuilder<TransactionFormCubit, TransactionFormState>(
                buildWhen: (prev, curr) => prev.status != curr.status,
                builder: (context, state) {
                  return StickyCta(
                    label: 'Save Transaction',
                    trailingIcon: Icons.arrow_forward_rounded,
                    isLoading: state.isSaving,
                    onPressed: _submit,
                  );
                },
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

    return TransactionFieldCard(
      icon: style?.icon ?? Icons.category_outlined,
      iconBackground: style?.tint ?? AppColors.lavender,
      iconColor: style?.iconColor ?? AppColors.textSecondary,
      label: 'Category',
      value: category?.name ?? 'Choose a category',
      valueColor: category == null ? AppColors.textSecondary : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textSecondary,
      ),
      errorText: state.categoryError,
      onTap: _pickCategory,
    );
  }

  Widget _buildDateCard(TransactionFormState state) {
    return TransactionFieldCard(
      icon: Icons.calendar_today_outlined,
      iconBackground: AppColors.blueTint,
      iconColor: AppColors.slate,
      label: 'Date & Time',
      value: Formatters.fullDate(state.date),
      errorText: state.dateError,
      onTap: _pickDate,
      trailing: InkWell(
        onTap: _pickTime,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(Formatters.time(state.date), style: AppTextStyles.label),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              size: 22,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Note', style: AppTextStyles.caption),
                TextField(
                  controller: _noteController,
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(200)],
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2),
                    border: InputBorder.none,
                    hintText: 'Add a note (optional)',
                    hintStyle: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
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
