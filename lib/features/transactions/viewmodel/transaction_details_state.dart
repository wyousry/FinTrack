
import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transactions/model/transaction_model.dart';

enum TransactionDetailsStatus { loading, loaded, notFound, failure }

class TransactionDetailsState extends Equatable {
  const TransactionDetailsState({
    this.status = TransactionDetailsStatus.loading,
    this.transaction,
    this.errorMessage,
    this.isDeleting = false,
  });

  final TransactionDetailsStatus status;
  final TransactionModel? transaction;
  final String? errorMessage;
  final bool isDeleting;

  TransactionDetailsState copyWith({
    TransactionDetailsStatus? status,
    TransactionModel? transaction,
    String? errorMessage,
    bool? isDeleting,
  }) {
    return TransactionDetailsState(
      status: status ?? this.status,
      transaction: transaction ?? this.transaction,
      errorMessage: errorMessage,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [status, transaction, errorMessage, isDeleting];
}