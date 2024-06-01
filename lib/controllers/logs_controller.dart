import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/LogsResponseModel.dart';
import '../models/RiskLog.dart';

class LogsController extends GetxController{

  Future<Map<String, List<StatusLog>>> fetchStatusLogs() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('status').get();
    List<StatusLog> logs = querySnapshot.docs
        .map((doc) => StatusLog.fromFirestore(doc))
        .where((log) => log.sleepStatus.isNotEmpty && log.snoozingStatus.isNotEmpty) // Filter out empty statuses
        .toList();

    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by timestamp, newest first

    Map<String, List<StatusLog>> groupedLogs = {};
    for (var log in logs) {
      if(log.timestamp.year!=2030){
        String dateKey = log.timestamp.toIso8601String().split('T').first; // Extract the date part
        if (groupedLogs[dateKey] == null) {
          groupedLogs[dateKey] = [];
        }
        groupedLogs[dateKey]!.add(log);
      }
    }

    return groupedLogs;
  }
  Future<Map<String, List<RiskLog>>> fetchRiskLogsGroupedByDate() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('status').get();
    List<StatusLog> logs = querySnapshot.docs
        .map((doc) => StatusLog.fromFirestore(doc))
        .toList();

    // Verileri zamana göre sıralıyoruz
    logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Map<String, List<RiskLog>> groupedRiskLogs = {};
    StatusLog? lastLog;
    DateTime? periodStart;
    int totalSoundLevel = 0;
    int count = 0;
    Duration totalDuration = Duration.zero;

    for (var log in logs) {
      if (log.sleepStatus == "Active" && log.snoozingStatus == "Snoozing" && log.soundLevel > 50 && log.timestamp.year!=2030) {
        if (lastLog != null && lastLog.sleepStatus == "Active" && lastLog.snoozingStatus == "Snoozing" && lastLog.soundLevel > 50) {
          Duration duration = log.timestamp.difference(lastLog.timestamp);
          totalDuration += duration;
          totalSoundLevel += log.soundLevel;
          count++;
        } else {
          if (lastLog != null && periodStart != null) {
            double avgSoundLevel = totalSoundLevel / count;
            if (totalDuration.inSeconds > 0) {
              String dateKey = periodStart!.toIso8601String().split('T').first;
              if (groupedRiskLogs[dateKey] == null) {
                groupedRiskLogs[dateKey] = [];
              }
              groupedRiskLogs[dateKey]!.add(RiskLog(start: periodStart, end: lastLog.timestamp, duration: totalDuration, avgSoundLevel: avgSoundLevel));
            }
          }
          periodStart = log.timestamp;
          totalDuration = Duration.zero;
          totalSoundLevel = log.soundLevel;
          count = 1;
        }
        lastLog = log;
      } else {
        if (lastLog != null && periodStart != null) {
          double avgSoundLevel = totalSoundLevel / count;
          if (totalDuration.inSeconds > 0) {
            String dateKey = periodStart!.toIso8601String().split('T').first;
            if (groupedRiskLogs[dateKey] == null) {
              groupedRiskLogs[dateKey] = [];
            }
            groupedRiskLogs[dateKey]!.add(RiskLog(start: periodStart, end: lastLog.timestamp, duration: totalDuration, avgSoundLevel: avgSoundLevel));
          }
        }
        lastLog = null;
        periodStart = null;
        totalDuration = Duration.zero;
        totalSoundLevel = 0;
        count = 0;
      }
    }

    if (lastLog != null && periodStart != null) {
      double avgSoundLevel = totalSoundLevel / count;
      if (totalDuration.inSeconds > 0) {
        String dateKey = periodStart!.toIso8601String().split('T').first;
        if (groupedRiskLogs[dateKey] == null) {
          groupedRiskLogs[dateKey] = [];
        }
        groupedRiskLogs[dateKey]!.add(RiskLog(start: periodStart, end: lastLog.timestamp, duration: totalDuration, avgSoundLevel: avgSoundLevel));
      }
    }

    // Günleri ters sırada sıralayarak ve her gün içindeki verileri de ters sırada sıralayarak geri dön
    return Map.fromEntries(groupedRiskLogs.entries.toList()..sort((a, b) => b.key.compareTo(a.key))
      ..forEach((entry) => entry.value.sort((a, b) => b.start.compareTo(a.start))));
  }
}