
import 'package:equatable/equatable.dart';

enum SplashDestination { onboarding, login, home }

class SplashState extends Equatable {
  final double progress;
  final SplashDestination? destination;

  const SplashState({
    this.progress = 0.0,
    this.destination,
  });

  SplashState copyWith({double? progress, SplashDestination? destination}) {
    return SplashState(
      progress: progress ?? this.progress,
      destination: destination ?? this.destination,
    );
  }

  @override
  List<Object?> get props => [progress, destination];
}