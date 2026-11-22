import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _transactions(String userId) {
    return _db.collection('users').doc(userId).collection('transactions');
  }
  CollectionReference<Map<String, dynamic>> _goals(String userId) {
  return _db.collection('users').doc(userId).collection('goals');
}

Stream<List<Map<String, dynamic>>> watchGoals(String userId) {
  return _goals(userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_toPlainMap).toList());
}

Future<void> addGoal(String userId, Map<String, dynamic> data) async {
  await _goals(userId).add({
    ...data,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> addToGoal(String userId, String goalId, double amount) {
  return _goals(userId).doc(goalId).update({
    'savedAmount': FieldValue.increment(amount),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> deleteGoal(String userId, String goalId) {
  return _goals(userId).doc(goalId).delete();
}

  Stream<List<Map<String, dynamic>>> watchTransactions(String userId) {
    return _transactions(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_toPlainMap).toList());
  }

Future<void> addTransaction(String userId, Map<String, dynamic> data) async {
  await _transactions(userId).add({
    ...data,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
Future<void> setTransactions(
  String userId,
  Map<String, Map<String, dynamic>> transactionsById,
) {
  final batch = _db.batch();
  transactionsById.forEach((id, data) {
    batch.set(_transactions(userId).doc(id), {
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });
  return batch.commit();
}
Map<String, dynamic> _toPlainMap(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data() ?? const <String, dynamic>{};
  return {
    'id': doc.id,
    ...data.map(
      (key, value) => MapEntry(key, value is Timestamp ? value.toDate() : value),
    ),
  };
}

Stream<Map<String, dynamic>?> watchTransaction(String userId, String transactionId) {
  return _transactions(userId)
      .doc(transactionId)
      .snapshots()
      .map((snapshot) => snapshot.exists ? _toPlainMap(snapshot) : null);
}

Future<void> updateTransaction(
  String userId,
  String transactionId,
  Map<String, dynamic> data,
) {
  return _transactions(userId).doc(transactionId).update({
    ...data,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> deleteTransaction(String userId, String transactionId) {
  return _transactions(userId).doc(transactionId).delete();
}
}