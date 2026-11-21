// lib/features/splash/viewmodel/splash_cubit.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../onboarding/viewmodel/onboarding_cubit.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState());

  Future<void> checkAppState() async {
    emit(state.copyWith(progress: 0.2));
    await Future.delayed(const Duration(milliseconds: 300));

    final hasSeenOnboarding = await OnboardingCubit.hasSeenOnboarding();
    emit(state.copyWith(progress: 0.6));
    await Future.delayed(const Duration(milliseconds: 200));

    if (!hasSeenOnboarding) {
      emit(state.copyWith(progress: 1.0, destination: SplashDestination.onboarding));
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    emit(state.copyWith(progress: 1.0));
    await Future.delayed(const Duration(milliseconds: 200));

    if (currentUser != null) {
      emit(state.copyWith(destination: SplashDestination.home));
    } else {
      emit(state.copyWith(destination: SplashDestination.login));
    }
  }
}