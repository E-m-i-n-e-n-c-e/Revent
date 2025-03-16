import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLog {
  final String id;
  final String collection;
  final String documentId;
  final String operation;
  final DateTime timestamp;
  final String userId;
  final String userEmail;
  final Map<String, dynamic>? beforeData;
  final Map<String, dynamic>? afterData;

  AdminLog({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.operation,
    required this.timestamp,
    required this.userId,
    required this.userEmail,
    this.beforeData,
    this.afterData,
  });

  factory AdminLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminLog(
      id: doc.id,
      collection: data['collection'] ?? '',
      documentId: data['documentId'] ?? '',
      operation: data['operation'] ?? 'unknown',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? 'system',
      userEmail: data['userEmail'] ?? 'system',
      beforeData: data['beforeData'] as Map<String, dynamic>?,
      afterData: data['afterData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collection': collection,
      'documentId': documentId,
      'operation': operation,
      'timestamp': timestamp,
      'userId': userId,
      'userEmail': userEmail,
      'beforeData': beforeData,
      'afterData': afterData,
    };
  }

  String get operationDisplay {
    if (operation.startsWith('create_')) {
      return 'Created';
    } else if (operation.startsWith('update_')) {
      return 'Updated';
    } else if (operation.startsWith('delete_')) {
      return 'Deleted';
    }
    return operation;
  }

  String get collectionDisplay {
    return collection.substring(0, 1).toUpperCase() + collection.substring(1);
  }

  String get changeDescription {
    if (operation.startsWith('create_')) {
      return 'Created new $collection';
    } else if (operation.startsWith('update_')) {
      final changedFields = getChangedFields();
      if (changedFields.isEmpty) {
        return 'Updated $collection';
      }
      return 'Updated ${changedFields.join(', ')} in $collection';
    } else if (operation.startsWith('delete_')) {
      return 'Deleted $collection';
    }
    return operation;
  }

  List<String> getChangedFields() {
    if (beforeData == null || afterData == null) {
      return [];
    }

    final changedFields = <String>[];
    for (final key in afterData!.keys) {
      if (!beforeData!.containsKey(key) || beforeData![key] != afterData![key]) {
        changedFields.add(key);
      }
    }
    return changedFields;
  }
}