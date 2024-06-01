import 'package:cloud_firestore/cloud_firestore.dart';

class StatusLog {
  final DateTime timestamp;
  final String sleepStatus;
  final String snoozingStatus;
  final int soundLevel;

  StatusLog({required this.timestamp, required this.sleepStatus, required this.snoozingStatus, required this.soundLevel});

  factory StatusLog.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime timestamp = data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : DateTime(2030);
    return StatusLog(
      timestamp: timestamp,
      sleepStatus: data['sleepStatus'] ?? '',
      snoozingStatus: data['snoozingStatus'] ?? '',
      soundLevel: data['soundLevel'] ?? 0,
    );
  }
}