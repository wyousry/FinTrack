import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/routing/app_router.dart';
import 'package:fintrack/core/utils/validators.dart';
import 'package:fintrack/core/widgets/app_text_field.dart';
import 'package:fintrack/core/widgets/password_field.dart';
import 'package:fintrack/core/widgets/primary_button.dart';
import 'package:fintrack/features/auth/repository/auth_repository.dart';
import 'package:fintrack/features/auth/viewmodel/login_cubit.dart';
import 'package:fintrack/features/auth/viewmodel/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:fintrack/core/widgets/field_label.dart';
import 'package:fintrack/core/widgets/text_link.dart';

abstract final class _Dims {
  static const double pageH = 14;
  static const double cardPadding = 24;
  static const double cardRadius = 22;
  static const double primaryButtonHeight = 48;

}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginCubit(authRepository: context.read<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _submitGoogle() {
    FocusScope.of(context).unfocus();
    return context.read<LoginCubit>().loginWithGoogle();
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state.status == LoginStatus.success) {
      context.go(AppRoutes.home);
    } else if (state.status == LoginStatus.failure) {
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
      body: BlocListener<LoginCubit, LoginState>(
        listener: _onStateChanged,
        child: Stack(
          children: [
            const _TopGlow(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(_Dims.pageH, 16, _Dims.pageH, 16),
                child: Column(
                  children: [
                    const _Header(),
                    const SizedBox(height: 18),
                    _buildFormCard(),
                    const SizedBox(height: 12),
                    const _YieldIndexBar(),
                    const SizedBox(height: 16),
                    const _SignUpRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
            const FieldLabel('Email Address'),
            const SizedBox(height: 6),
            AppTextField(
              controller: _emailController,
              hintText: 'alex.rivera@example.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                FieldLabel('Password'),
                Spacer(),
                TextLink('Forgot Password?'),
              ],
            ),
            const SizedBox(height: 6),
            PasswordField(
              controller: _passwordController,
              validator: Validators.password,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            _RememberRow(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v),
            ),
            const SizedBox(height: 16),
            BlocBuilder<LoginCubit, LoginState>(
              buildWhen: (prev, curr) => prev.status != curr.status,
              builder: (context, state) {
                return PrimaryButton(
                  label: 'Log In',
                  trailingIcon: Icons.arrow_forward_rounded,
                  height: _Dims.primaryButtonHeight,
                  isLoading: state.isLoadingWith(LoginMethod.email),
                  onPressed: state.isLoading ? null : _submit,
                );
              },
            ),
            const SizedBox(height: 14),
            const _OrDivider(),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: SignInButton(
                Buttons.google,
                text: 'Continue with Google',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: _submitGoogle,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
class _TopGlow extends StatelessWidget {
  const _TopGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -120,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: 380,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 0.9,
              colors: [
                AppColors.primary.withValues(alpha: 0.18),
                AppColors.primary.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'FinTrack',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sign in to access your finances',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '256-bit Bank-Grade Encryption',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _RememberRow extends StatelessWidget {
  const _RememberRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: value ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              const Text(
                'Remember this device',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Icon(Icons.verified_user_outlined, size: 13, color: AppColors.primaryDark),
        const SizedBox(width: 4),
        const Text(
          'Biometrics active',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, height: 1)),
      ],
    );
  }
}



class _YieldIndexBar extends StatelessWidget {
  const _YieldIndexBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.show_chart_rounded, size: 14, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'FinTrack Portfolio Yield Index',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Spacer(),
          Text(
            '+4.28%',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.trending_up_rounded, size: 13, color: AppColors.primaryDark),
        ],
      ),
    );
  }
}

class _SignUpRow extends StatelessWidget {
  const _SignUpRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
        TextLink(
          'Sign Up',
          fontSize: 12.5,
          onTap: () => context.push(AppRoutes.register),
        ),
      ],
    );
  }
}