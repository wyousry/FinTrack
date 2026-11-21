import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/utils/formatters.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/core/widgets/app_text_field.dart';
import 'package:fintrack/core/widgets/confirmation_dialog.dart';
import 'package:fintrack/core/widgets/field_label.dart';
import 'package:fintrack/core/widgets/primary_button.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/goals/model/savings_goal.dart';
import 'package:fintrack/features/goals/repository/goal_repository.dart';
import 'package:fintrack/features/goals/viewmodel/goal_actions_cubit.dart';
import 'package:fintrack/features/goals/viewmodel/goal_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showCreateGoalSheet(BuildContext context) {
  return _showGoalSheet(context, (_) => const _CreateGoalSheet());
}

Future<void> showAddFundsSheet(BuildContext context, SavingsGoal goal) {
  return _showGoalSheet(context, (_) => _AddFundsSheet(goal: goal));
}

Future<void> _showGoalSheet(BuildContext context, WidgetBuilder childBuilder) {
  final authRepository = context.read<AuthRepository>();
  final goalRepository = context.read<GoalRepository>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => BlocProvider(
      create: (_) => GoalActionsCubit(
        authRepository: authRepository,
        goalRepository: goalRepository,
      ),
      child: childBuilder(sheetContext),
    ),
  );
}


class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet();

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _savedController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<GoalActionsCubit>().createGoal(
          name: _nameController.text,
          targetAmount: Validators.parseAmount(_targetController.text)!,
          savedAmount: Validators.parseAmount(_savedController.text) ?? 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GoalActionsCubit, GoalActionsState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == GoalActionStatus.success) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return _SheetFrame(
          title: 'New savings goal',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('Goal name'),
                const SizedBox(height: 6),
                AppTextField(
                  controller: _nameController,
                  hintText: 'Summer Vacation Fund',
                  prefixIcon: Icons.flag_outlined,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: Validators.goalName,
                ),
                const SizedBox(height: 14),
                const FieldLabel('Target amount'),
                const SizedBox(height: 6),
                AppTextField(
                  controller: _targetController,
                  hintText: '5,000',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: Validators.positiveAmount,
                ),
                const SizedBox(height: 14),
                const FieldLabel('Already saved (optional)'),
                const SizedBox(height: 6),
                AppTextField(
                  controller: _savedController,
                  hintText: '0',
                  prefixIcon: Icons.savings_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  validator: Validators.optionalAmount,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (state.errorMessage != null) _ErrorText(state.errorMessage!),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Create Goal',
                  height: 48,
                  isLoading: state.isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _AddFundsSheet extends StatefulWidget {
  const _AddFundsSheet({required this.goal});

  final SavingsGoal goal;

  @override
  State<_AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<_AddFundsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<GoalActionsCubit>().addFunds(
          goalId: widget.goal.id,
          amount: Validators.parseAmount(_amountController.text)!,
        );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete goal?',
      message: 'Are you sure you want to delete "${widget.goal.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed && mounted) {
      context.read<GoalActionsCubit>().deleteGoal(widget.goal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;

    return BlocConsumer<GoalActionsCubit, GoalActionsState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == GoalActionStatus.success) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return _SheetFrame(
          title: goal.name,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Formatters.currencyShort(goal.savedAmount)} of '
                  '${Formatters.currencyShort(goal.targetAmount)} saved • ${goal.percent}%',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Amount to add'),
                const SizedBox(height: 6),
                AppTextField(
                  controller: _amountController,
                  hintText: '100',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  validator: Validators.positiveAmount,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (state.errorMessage != null) _ErrorText(state.errorMessage!),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Add Funds',
                  height: 48,
                  isLoading: state.isSaving,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: state.isSaving ? null : _confirmDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete goal'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.negative),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.heading),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        style: AppTextStyles.label.copyWith(color: AppColors.negative),
      ),
    );
  }
}