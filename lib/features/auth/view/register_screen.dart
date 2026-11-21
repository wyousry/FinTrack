import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/routing/app_router.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/core/widgets/app_checkbox.dart';
import 'package:fintrack/core/widgets/app_text_field.dart';
import 'package:fintrack/core/widgets/field_label.dart';
import 'package:fintrack/core/widgets/password_field.dart';
import 'package:fintrack/core/widgets/primary_button.dart';
import 'package:fintrack/core/widgets/text_link.dart';
import 'package:fintrack/features/auth/model/password_strength.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/auth/viewmodel/register_cubit.dart';
import 'package:fintrack/features/auth/viewmodel/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_button/sign_in_button.dart';

abstract final class _Dims {
  static const double pageH = 14;
  static const double cardPadding = 24;
  static const double cardRadius = 22;
  static const double headerHeight = 104;
  static const double headerOverlap = 20; 
  static const double primaryButtonHeight = 48;
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RegisterCubit(authRepository: context.read<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<RegisterCubit>().register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
  Future<void> _submitGoogle() {
    FocusScope.of(context).unfocus();
    return context.read<RegisterCubit>().registerWithGoogle();
  }

 void _onStateChanged(BuildContext context, RegisterState state) {
  if (state.status == RegisterStatus.success) {
    if (state.method == RegisterMethod.email) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Account created! Please log in.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.home);
    }
  } else if (state.status == RegisterStatus.failure) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: _onStateChanged,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(_Dims.pageH, 4, _Dims.pageH, 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _goBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _buildHeaderAndForm(),
                const SizedBox(height: 18),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 18),
                _buildGoogleCard(),
                const SizedBox(height: 16),
                const _SignInRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAndForm() {
    return Stack(
      children: [
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _Dims.headerHeight,
          child: _Header(),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: _Dims.headerHeight - _Dims.headerOverlap,
          ),
          child: _buildFormCard(),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(_Dims.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_Dims.cardRadius),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Full Name'),
            const SizedBox(height: 6),
            AppTextField(
              controller: _nameController,
              hintText: 'Alex Morgan',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.fullName,
            ),
            const SizedBox(height: 14),
            const FieldLabel('Email Address'),
            const SizedBox(height: 6),
            AppTextField(
              controller: _emailController,
              hintText: 'alex.morgan@example.com',
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            const FieldLabel('Password'),
            const SizedBox(height: 6),
            PasswordField(
              controller: _passwordController,
              hintText: 'Min. 8 characters',
              validator: Validators.newPassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: (value) =>
                  context.read<RegisterCubit>().passwordChanged(value),
            ),
            const SizedBox(height: 10),
            BlocSelector<RegisterCubit, RegisterState, PasswordStrength>(
              selector: (state) => state.passwordStrength,
              builder: (context, strength) =>
                  _PasswordStrengthMeter(strength: strength),
            ),
            const SizedBox(height: 14),
            const FieldLabel('Confirm Password'),
            const SizedBox(height: 6),
            PasswordField(
              controller: _confirmController,
              hintText: 'Repeat your password',
              prefixIcon: Icons.lock_reset_rounded,
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 14),
            const _TermsField(),
            const SizedBox(height: 16),
            BlocBuilder<RegisterCubit, RegisterState>(
              buildWhen: (prev, curr) => prev.status != curr.status,
              builder: (context, state) {
                return PrimaryButton(
                  label: 'Register',
                  trailingIcon: Icons.arrow_forward_rounded,
                  height: _Dims.primaryButtonHeight,
                  isLoading: state.isLoadingWith(RegisterMethod.email),
                  onPressed: state.isLoading ? null : _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_Dims.cardRadius),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: SignInButton(
          Buttons.google,
          text: 'Sign up with Google',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: _submitGoogle,
        ),
      ),
    );
  }
}
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(_Dims.cardRadius),
      ),
      child: Container(
        color: AppColors.surfaceTint.withValues(alpha: 0.6),
        child: Stack(
          children: [
            Positioned(
              right: -36,
              top: -36,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.mint,
                      AppColors.mint.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, _Dims.headerOverlap),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_outlined,
                        size: 20,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Start your financial journey today',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
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

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.strength});

  final PasswordStrength strength;

  Color get _activeColor {
    switch (strength) {
      case PasswordStrength.none:
        return AppColors.textSecondary;
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.fair:
        return AppColors.warning;
      case PasswordStrength.good:
        return AppColors.primary;
      case PasswordStrength.strong:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Security strength',
              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text(
              strength.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _activeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < strength.level
                        ? _activeColor
                        : AppColors.glowBlue.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TermsField extends StatelessWidget {
  const _TermsField();

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: false,
      validator: Validators.termsAccepted,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppCheckbox(
                  value: field.value ?? false,
                  onChanged: field.didChange,
                ),
                const SizedBox(width: 10),
                const Expanded(child: _TermsText()),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 30),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  static const TextStyle _linkStyle = TextStyle(
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
    decoration: TextDecoration.underline,
  );

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        children: [
          TextSpan(text: 'I agree to the '),
          TextSpan(text: 'Terms of Service', style: _linkStyle),
          TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy', style: _linkStyle),
        ],
      ),
    );
  }
}

class _SignInRow extends StatelessWidget {
  const _SignInRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
        TextLink(
          'Sign In',
          fontSize: 12.5,
          onTap: () => context.go(AppRoutes.login),
        ),
      ],
    );
  }
}