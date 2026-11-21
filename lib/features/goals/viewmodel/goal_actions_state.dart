import 'package:equatable/equatable.dart';

enum GoalActionStatus { idle, saving, success, failure }

class GoalActionsState extends Equatable {
  const GoalActionsState({this.status = GoalActionStatus.idle, this.errorMessage});

  final GoalActionStatus status;
  final String? errorMessage;

  bool get isSaving => status == GoalActionStatus.saving;

  @override
  List<Object?> get props => [status, errorMessage];
}